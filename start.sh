#!/bin/bash

mkdir -p /etc/powerdns/pdns.d

PDNSVARS=$(echo ${!PDNSCONF_*})
touch /etc/powerdns/pdns.conf

for var in $PDNSVARS; do
  varname=$(echo ${var#"PDNSCONF_"} | awk '{print tolower($0)}' | sed 's/_/-/g')
  value=$(echo ${!var} | sed 's/^$\(.*\)/\1/')
  echo "$varname=$value" >>/etc/powerdns/pdns.conf
done

if [ ! -z $PDNSCONF_API_KEY ]; then
  cat >/etc/powerdns/pdns.d/api.conf <<EOF
api=yes
webserver=yes
webserver-address=0.0.0.0
webserver-allow-from=0.0.0.0/0
EOF

fi

if [ "$SECALLZONES_CRONJOB" == "yes" ]; then
  cat >/etc/crontab <<EOF
PDNSCONF_API_KEY=$PDNSCONF_API_KEY
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
# m  h dom mon dow user    command
0,30 *  *   *   *  root    /usr/local/bin/secallzones.sh > /var/log/cron.log 2>&1
EOF
  ln -sf /proc/1/fd/1 /var/log/cron.log
  cron -f &
fi

# Start PowerDNS
# same as /etc/init.d/pdns monitor
echo "Starting PowerDNS..."

if [ "$#" -gt 0 ]; then
  exec /usr/sbin/pdns_server "$@"
else
  exec /usr/sbin/pdns_server
fi
