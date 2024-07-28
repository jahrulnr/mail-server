FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    RUNLEVEL=1
WORKDIR /tmp
RUN apt-get update \
    && printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d \
    && apt-get install -y \
        inetutils-telnet dnsmasq net-tools procps unzip cmake curl autoconf flex \
        msmtp \
        python3 git \
        vim \
        postfix postfix-policyd-spf-python \
        opendkim opendkim-tools \
        supervisor \
    && curl -L -o postsrsd.zip https://github.com/roehling/postsrsd/archive/main.zip \
    && unzip postsrsd.zip && mkdir postsrsd-main/_build && cd postsrsd-main/ \
    && mkdir pcre && touch pcre/aclocal.m4 pcre/configure pcre/Makefile.am pcre/Makefile.in \
    && cd _build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local \
    && make -j && make install \
    && gpasswd -a postfix opendkim \
    && apt-get purge unzip cmake autoconf flex -y \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /etc/opendkim.conf

WORKDIR /
COPY ./bin/systemctl.py /bin/systemctl
COPY ./config/postsrs/* /usr/local/etc/
COPY ./config/opendkim/* /etc/opendkim/
COPY ./config/postfix/master.cf /etc/postfix/master.cf
COPY ./config/postfix/virtual /etc/postfix/virtual
COPY ./config/postfix/postfix.sh /run/postfix.sh
COPY ./config/supervisord/supervisord.conf /etc/supervisord.conf
COPY ./start.sh /start.sh

COPY ./config/test.txt /tmp/test.txt
COPY ./config/test.sh /tmp/test.sh

RUN chmod +x /bin/systemctl /start.sh /run/postfix.sh /tmp/test.sh \
    && mkdir /etc/opendkim/keys \
    && chown -R opendkim:opendkim /etc/opendkim \
    && ln -s /etc/opendkim/opendkim.conf /etc/opendkim.conf

EXPOSE 25

CMD /start.sh