#!/bin/bash

if [ ! -f /etc/nginx/certsdhparam.pem ] ; then
    openssl dhparam -out /etc/nginx/certsdhparam.pem 2048
fi

if [[ -z $ENPWL_CLIENT_MAX_BODY_SIZE ]] ; then
    ENPWL_CLIENT_MAX_BODY_SIZE=1M
fi

if [[ -z $ENPWL_DOMAIN_WWW ]] ; then
    ENPWL_DOMAIN_WWW="false"
fi

curl https://get.acme.sh | sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade

if [ ! -d /root/.acme.sh/$ENPWL_DOMAIN ] ; then
    cp /default.conf /etc/nginx/conf.d/
    sed -i "s:daemon off;:daemon on;:g" /etc/nginx/nginx.conf
    nginx

    if [ $ENPWL_DOMAIN_WWW = "true" ] ; then
        /root/.acme.sh/acme.sh --issue -d $ENPWL_DOMAIN -d www.$ENPWL_DOMAIN -w /var/www
    else
        /root/.acme.sh/acme.sh --issue -d $ENPWL_DOMAIN -w /var/www
    fi
    
    killall nginx
fi

cat /default-domain.conf | sed 's:%%DOMAIN%%:'$ENPWL_DOMAIN':g' | sed 's:%%MAXBODYSIZE%%:'$ENPWL_CLIENT_MAX_BODY_SIZE':g' | sed 's:%%PORT%%:'$ENPWL_APP_PORT':g' | sed 's:%%HOST%%:'$ENPWL_APP_HOST':g' > /etc/nginx/conf.d/default.conf
kill -HUP $(/bin/pidof crond)
crond
sed -i "s:daemon on;:daemon off;:g" /etc/nginx/nginx.conf
kill -HUP $(/bin/pidof nginx)
nginx
