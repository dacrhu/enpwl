FROM alpine:latest

RUN apk add bash
RUN apk add curl
RUN apk add nginx
RUN apk add openssl
RUN apk add socat

RUN mkdir /run/nginx

COPY start.sh /
COPY acme-upgrade.sh /
COPY nginx.conf /etc/nginx/
COPY default.conf /
COPY default-domain.conf /
COPY root /etc/crontabs/

RUN chmod +x /*.sh

EXPOSE 80
EXPOSE 443

CMD ["/start.sh"]