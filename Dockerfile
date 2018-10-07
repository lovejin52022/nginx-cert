FROM debian:stretch-slim

MAINTAINER Rollong "330913734@qq.com"

ENV NGINX_VERSION 1.15.5
ENV NPS_VERSION 1.13.35.2-stable
ENV PSOL_VERSION 1.13.35.2-x64
ENV LIBRESSL_VERSION 2.7.4
ENV OPENSSL_VERSION 1.1.1
ENV LIBPRCE_VERSION 8.42
ENV ZLIB_VERSION 1.2.11

RUN apt-get update && \
    apt-get install -y \
    wget \
    build-essential \
    unzip \
    libgeoip-dev \
    uuid-dev \
    curl \
    git autoconf automake libtool \
    && apt-get upgrade -y \
    && rm -r /var/lib/apt/lists/* \
    && adduser --system --no-create-home --disabled-password --group nginx && \
    mkdir /var/cache/nginx/ && \
    mkdir /sources && cd /sources && \
    wget https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}.zip -O ngx_pagespeed.zip && \
    unzip ngx_pagespeed.zip && \
    cd /sources/incubator-pagespeed-ngx-${NPS_VERSION} && \
    wget https://dl.google.com/dl/page-speed/psol/${PSOL_VERSION}.tar.gz -O psol.tar.gz && \
    tar -xzvf psol.tar.gz && \
    cd /sources && \
    ######################################## OPENSSL INSTALLATION ########################################
    apt-get remove -y openssl && \
    wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz -O openssl.tar.gz && \
    tar -xzvf openssl.tar.gz && \
    mv openssl-${OPENSSL_VERSION} openssl && \
    cd openssl && ./config enable-tls1_3 && make && make install && ldconfig && \
    cd /sources && \
    ######################################## END OF OPENSSL INSTALLATION ########################################
    ######################################## LIBRESSL INSTALLATION ########################################
    # wget https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VERSION}.tar.gz -O libressl.tar.gz && \
    # tar -xzvf libressl.tar.gz && \
    # mv libressl-${LIBRESSL_VERSION} openssl && \
    ######################################## END OF LIBRESSL INSTALLATION ########################################
    wget https://ftp.pcre.org/pub/pcre/pcre-${LIBPRCE_VERSION}.zip -O pcre.zip && \
    unzip pcre.zip && mv pcre-${LIBPRCE_VERSION} pcre && \
    wget http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz -O zlib.tar.gz && \
    tar -xzvf zlib.tar.gz && mv zlib-${ZLIB_VERSION} zlib && \
    ######################################## NGINX RTMP MODULE ########################################
    cd /sources && \
    wget https://github.com/arut/nginx-rtmp-module/archive/master.zip -O nginx-rtmp-module.zip && \
    unzip nginx-rtmp-module.zip && \
    mv nginx-rtmp-module-master nginx-rtmp-module && \
    ######################################## NGINX-CT ########################################
    cd /sources && \
    wget -O nginx-ct.zip -c https://github.com/grahamedgecombe/nginx-ct/archive/v1.3.2.zip && \
    unzip nginx-ct.zip && mv nginx-ct-1.3.2 nginx-ct && \
    ######################################## NGINX-CT ########################################
    ######################################## NGINX-brotli ########################################
    cd /sources && \
    git clone https://github.com/bagder/libbrotli && \
    cd libbrotli && \
    ./autogen.sh && \
    ./configure && make && make install && \
    cd /sources && \
    git clone https://github.com/google/ngx_brotli.git && \
    cd ngx_brotli && \
    git submodule update --init && \
    cd /sources && \
    ## git clone https://github.com/cloudflare/sslconfig.git && \
    ######################################## NGINX-brotli ########################################
    ######################################## NGINX INSTALLATION ########################################
    cd /sources && \
    wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar -xvf nginx-${NGINX_VERSION}.tar.gz && cd nginx-${NGINX_VERSION} && \
    ## patch -p1 < /sources/sslconfig/patches/nginx__1.11.5_dynamic_tls_records.patch && \
    ./configure --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-compat \
        --with-file-aio \
        --with-threads \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_mp4_module \
        --with-http_dav_module \
        --with-http_random_index_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_v2_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-stream \
        --with-stream_realip_module \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        ## --with-openssl=/sources/openssl \
        ## --with-openssl-opt=enable-tls1_3 \
        --add-module=/sources/nginx-rtmp-module \
        --add-module=/sources/nginx-ct \
        --add-module=/sources/ngx_brotli \
        --with-pcre=/sources/pcre \
        --with-zlib=/sources/zlib \
        --add-module=/sources/incubator-pagespeed-ngx-${NPS_VERSION} \
        --with-http_geoip_module && \
    make && make install && \
    rm -rf /sources && \
    ## GeoIP database
    mkdir /var/geoip && cd /var/geoip && \
    wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz && \
    gunzip GeoIP.dat.gz && rm -rf GeoIP.dat.gz && \
    wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz && \
    gunzip GeoLiteCity.dat.gz && rm -rf GeoLiteCity.dat.gz && \
    ## cleanup
    apt-get remove -y build-essential unzip curl wget git autoconf automake libtool && apt-get autoremove -y

# add /tmp/ngx_pagespeed_cache/
RUN mkdir -p /tmp/ngx_pagespeed_cache && chown -R nginx:nginx /tmp/ngx_pagespeed_cache

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY ./conf/nginx /etc/nginx
COPY ./scripts/ /scripts
COPY ./ct-submit /usr/local/bin/ct-submit

EXPOSE 80 443

VOLUME /etc/nginx/vhost
VOLUME /etc/nginx/global

STOPSIGNAL SIGQUIT

CMD ["/scripts/start.sh"]