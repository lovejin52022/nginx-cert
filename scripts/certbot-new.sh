#!/bin/bash

domains=""
for arg in "$@"
do
 domains="$domains -d $arg"
done
certbot certonly --webroot -w /acme $domains