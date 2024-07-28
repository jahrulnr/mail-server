#!/bin/bash

/etc/init.d/postfix start

sleep 5
if [ ! -f /var/spool/postfix/private/smtp ]; then
    echo "[warning] private/smtp not found"
    if [ -e /var/spool/postfix/public/smtp ]; then
        echo "[info] create symlink from public/smtp to private/smtp"
        ln -s /var/spool/postfix/public/smtp /var/spool/postfix/private/smtp
    fi
    /etc/init.d/postfix restart
fi

tail -f /var/mail/postfix.log