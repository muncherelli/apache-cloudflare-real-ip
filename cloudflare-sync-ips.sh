#!/bin/bash

CLOUDFLARE_FILE_PATH=/etc/apache2/conf-available/remoteip.conf

echo "RemoteIPHeader CF-Connecting-IP" > $CLOUDFLARE_FILE_PATH;

for i in `curl https://www.cloudflare.com/ips-v4`; do
    echo "set_real_ip_from $i;" >> $CLOUDFLARE_FILE_PATH;
done

for i in `curl https://www.cloudflare.com/ips-v6`; do
    echo "set_real_ip_from $i;" >> $CLOUDFLARE_FILE_PATH;
done

#test configuration and reload apache
apache2ctl configtest && systemctl restart apache2
