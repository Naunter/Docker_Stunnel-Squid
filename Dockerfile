FROM debian
MAINTAINER savps
RUN apt-get -qq update
RUN apt-get -qqy install stunnel4 squid3 openssl 
WORKDIR /tmp
RUN openssl genrsa -out privatekey.pem 4096
RUN openssl req -new -x509 -batch -key privatekey.pem -out publickey.pem -days 365
RUN cat privatekey.pem publickey.pem > stunnel.pem
RUN cp stunnel.pem /etc/stunnel/stunnel_https.pem
RUN sed -i 's/^ENABLED=0/ENABLED=1/' /etc/default/stunnel4
ADD stunnel.conf /etc/stunnel/stunnel.conf
RUN echo "\nhttp_access allow all\nhttp_port 3128\ncache_access_log /tmp/squid_access.log\ncache_log /tmp/squid_cache.log\ncoredump_dir /tmp/squid" >> /etc/squid3/squid.conf
RUN sed -i 's/^http_access deny all/#http_access deny all/' /etc/squid3/squid.conf
EXPOSE 13128/tcp
RUN /etc/init.d/stunnel4 restart
RUN /etc/init.d/squid3 restart
