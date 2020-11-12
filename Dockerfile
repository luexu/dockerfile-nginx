FROM aario/centos:7

ENV NginxVer nginx-1.18.0

WORKDIR /usr/local/src
ADD ./src/* /usr/local/src/
 
RUN mkdir -p /var/cache/nginx && chown -R Aa:Aa /var/cache/nginx

# --with-pcre  rewrite 功能
RUN yum install -y gcc gcc-c++ lua-devel lua-static zlib-devel openssl openssl-devel which geoip-devel


WORKDIR /usr/local/src/${NginxVer}

RUN sed -Ei "s/\"Server:\s*(nginx\"|\"\s*NGINX_VER|\"\s*NGINX_VER_BUILD)\s*CRLF;/\"Server: luexu.com\" CRLF;/" /usr/local/src/${NginxVer}/src/http/ngx_http_header_filter_module.c

#--add-module=/usr/local/src/${NGX_NJS_VER}/nginx				\
RUN ./configure                                 \
    --prefix=/usr/local/nginx                      \
    --sbin-path=/usr/sbin/nginx                 \
    --conf-path=/etc/aa/nginx/nginx.conf                \
    --error-log-path=/var/log/nginx/error.log   \
    --http-log-path=/var/log/nginx/access.log   \
    --pid-path=/etc/aa/lock/nginx.pid           \
    --lock-path=/etc/aa/lock/nginx.lock         \
    --http-client-body-temp-path=/var/cache/nginx/client_temp   \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp          \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp      \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp          \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp            \
    --user=Aa                                   \
    --group=Aa                                  \
    --with-http_ssl_module                      \
    --with-threads                              \
    --with-file-aio                             \
    --with-http_v2_module                       \
	--with-http_stub_status_module 				\ 
	--with-http_gzip_static_module 				\ 
	--with-http_geoip_module 					\
    --with-ipv6									\
	--with-stream								\
	--with-stream_ssl_module 					\
	--with-stream_ssl_preread_module
RUN make && make install

RUN yum clean all  && rm -rf /var/cache/yum && rm -rf /usr/local/src/*
RUN ln -sf /dev/stdout /var/log/dockervol/stdout.log && ln -sf /dev/stderr /var/log/dockervol/stderr.log

# COPY 只能复制当前目录，不复制子目录内容
COPY --chown=Aa:Aa ./etc/aa/*  /etc/aa/

VOLUME /etc/aa/nginx

ENTRYPOINT ["/etc/aa/entrypoint", "/usr/sbin/nginx"]
 