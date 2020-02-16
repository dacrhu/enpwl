#!/bin/bash

minimumsize=160000
actualsize=$(wc -c < /root/.acme.sh/acme.sh)

if [ $actualsize -ge $minimumsize ]; then
    "/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh"
else
    curl https://get.acme.sh | sh
    /root/.acme.sh/acme.sh --upgrade --auto-upgrade
fi

/bin/kill -HUP $(/bin/pidof nginx)
