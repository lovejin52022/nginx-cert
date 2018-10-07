# README #

nginx 1.13.8

pagespeed 1.12.34.3-stable

0 5 * * 1 docker exec -it nginx /scripts/certbot-renew.sh > /dev/null 2>&1

ct-submit ct1.digicert-ct.com/log </etc/acme.sh/ljts.zhonghuixz.com/fullchain.cer >/etc/nginx/vhost/sct/ljts.zhonghuixz.com/ct.sct

ct-submit ct.googleapis.com/pilot <fullchain.cer >ct.sct