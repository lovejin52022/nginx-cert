#!/bin/bash

certbot renew --webroot-path /acme
supervisorctl restart nginx