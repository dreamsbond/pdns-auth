FROM debian:buster

MAINTAINER dreamsbond <info@dreamsbond.com>

ENV PDNSCONF_LOCAL_ADDRESS="0.0.0.0,::" \
    PDNSCONF_LAUNCH="gmysql" \
    PDNSCONF_GMYSQL_HOST="" \
    PDNSCONF_GMYSQL_USER="" \
    PDNSCONF_GMYSQL_DBNAME="" \
    PDNSCONF_GMYSQL_PASSWORD="" \
    PDNSCONF_GMYSQL_DNSSEC="yes" \
    PDNSCONF_INCLUDE_DIR="/etc/powerdns/pdns.d" \
    PDNSCONF_DNSUPDATE="no" \
    PDNSCONF_GUARDIAN="no" \
    PDNSCONF_VERSION_STRING="unspecificed" \
    PDNSCONF_DISTRIBUTOR_THREADS="2" \
    PDNSCONF_MASTER="yes" \
    PDNSCONF_SLAVE="no" \
    PDNSCONF_API_KEY="" \
    SECALLZONES_CRONJOB="no"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -q -y curl gnupg && \
    curl https://repo.powerdns.com/FD380FBB-pub.asc | apt-key add -

ADD ./apt/source.list.d/pdns.list /etc/apt/sources.list.d/pdns.list
ADD ./apt/preference.d/pdns /etc/apt/preferences.d/pdns
ADD ./apt/apt.conf.d/00nosuggests /etc/apt/apt.conf.d/00nosuggests
ADD ./apt/apt.conf.d/00norecommends /etc/apt/apt.conf.d/00norecommends

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -q -y pdns-server pdns-backend-mysql mariadb-client && \
    rm -f /etc/powerdns/pdns.d/*.conf && rm -f /etc/powerdns/*.conf && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends cron jq && \
    rm /etc/cron.daily/* && \
    mkdir /var/run/pdns && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 53/udp 53/tcp

ADD start.sh /usr/local/bin/start.sh
ADD fixdsrrs.sh /usr/local/bin/fixdsrrs.sh
ADD secallzones.sh /usr/local/bin/secallzones.sh
RUN chmod a+x /usr/local/bin/*.sh

CMD ["/usr/local/bin/start.sh"]
