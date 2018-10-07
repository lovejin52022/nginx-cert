#!/bin/bash

mkdir -p /acme/.well-known
chown -R nginx:nginx /acme/.well-known

# Pass real-ip to logs when behind ELB, etc
if [[ "$REAL_IP_HEADER" == "1" ]] ; then
 sed -i "s/#real_ip_header X-Forwarded-For;/real_ip_header X-Forwarded-For;/" /etc/nginx/nginx.conf
 sed -i "s/#set_real_ip_from/set_real_ip_from/" /etc/nginx/nginx.conf
 if [ ! -z "$REAL_IP_FROM" ]; then
  sed -i "s#172.16.0.0/12#$REAL_IP_FROM#" /etc/nginx/nginx.conf
 fi
fi

# Start supervisord and services
# exec /usr/bin/supervisord -n -c /etc/supervisord.conf
/usr/sbin/nginx -g "daemon off; error_log /dev/stderr info;"