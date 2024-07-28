#!/bin/bash

if [ -z "$DOMAIN" ]; then
    echo "[error] domain cannot be empty"
    exit 1
fi

echo "[info] set hostname"
hostname ${DOMAIN}

echo "[info] setup opendkim"
sed -i "s/--domain--/${DOMAIN}/g"  /etc/opendkim/opendkim.conf
sed -i "s/--domain--/${DOMAIN}/g"  /etc/opendkim/signing.table
sed -i "s/--domain--/${DOMAIN}/g"  /etc/opendkim/key.table
sed -i "s/--domain--/${DOMAIN}/g"  /etc/opendkim/trusted.hosts
mkdir -p /var/spool/postfix/opendkim
chown opendkim:postfix /var/spool/postfix/opendkim

echo "[info] setup postsrs"
sed -i "s/--domain--/${DOMAIN}/g"  /usr/local/etc/postsrsd.conf

if [ ! -d "/etc/opendkim/keys/${DOMAIN}" ]; then
    echo "[info] setup opendkim keys"
    mkdir -p "/etc/opendkim/keys/${DOMAIN}"
    opendkim-genkey -b 2048 -d $DOMAIN -D "/etc/opendkim/keys/${DOMAIN}" -s default -v
    chown opendkim:opendkim "/etc/opendkim/keys/${DOMAIN}/default.private"
    chmod 600 "/etc/opendkim/keys/${DOMAIN}/default.private"
fi

echo "[info] test opendkim"
opendkim-testkey -d $DOMAIN -s default -vvv

echo "[info] setup postfix"
echo $DOMAIN > /etc/mailname

postconf -e "smtpd_tls_cert_file = /etc/ssl/certs/ssl-cert-snakeoil.pem"
postconf -e "smtpd_tls_key_file = /etc/ssl/private/ssl-cert-snakeoil.key"
postconf -e "smtpd_tls_security_level = may"
postconf -e "home_mailbox = ${MAIL_BOX}/"
postconf -e "smtpd_use_tls = yes"
postconf -e "smtpd_tls_auth_only = yes"
postconf -e "smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination"
postconf -e "smtp_tls_CApath = /etc/ssl/certs"
postconf -e "smtp_tls_security_level = encrypt"
postconf -e "smtp_tls_session_cache_database = btree:\${data_directory}/smtp_scache"
postconf -e "myhostname = ${DOMAIN}"
postconf -e "alias_maps = hash:/etc/aliases"
postconf -e "alias_database = hash:/etc/aliases"
postconf -e "myorigin = /etc/mailname"
postconf -e "mydestination = \$myhostname, ${DOMAIN}, localhost.localdomain, localhost"
postconf -e "relayhost = "
postconf -e "mynetworks = 127.0.0.0/8 172.0.0.0/8"
postconf -e "mailbox_size_limit = 0"
postconf -e "recipient_delimiter = +"
postconf -e "inet_interfaces = all"
postconf -e "inet_protocols = ipv4"
postconf -e "smtpd_milters = inet:127.0.0.1:8891"
postconf -e "non_smtpd_milters = \$smtpd_milters"
postconf -e "milter_protocol = 6"
postconf -e "milter_default_action = accept"
postconf -e "receive_override_options = no_address_mappings"
postconf -e "policyd-spf_time_limit = 3600"
postconf -e "smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination, check_policy_service unix:private/policyd-spf"
postconf -e 'smtpd_tls_protocols = !SSLv2, !SSLv3'
postconf -e 'smtp_tls_protocols = !SSLv2, !SSLv3'

postconf -e "maillog_file = /var/mail/postfix.log"
chmod 600 /etc/postfix/virtual
touch /etc/postfix/virtual.db
chown postfix:postfix /etc/postfix/virtual.db
postfix set-permissions
postmap /etc/postfix/master.cf
postmap /etc/postfix/main.cf
postmap /etc/postfix/virtual

sed -i "s/--mail-test--/${MAIL_TEST}/g"  /tmp/test.txt

echo ""
echo "[info] cat /etc/opendkim/keys/${DOMAIN}/default.txt"
cat "/etc/opendkim/keys/${DOMAIN}/default.txt"

echo ""
echo "[info] start supervisord"
supervisord -nc /etc/supervisord.conf