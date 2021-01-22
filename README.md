# Get Real Visitor IP Address (Restoring Visitor IPs) with Apache and CloudFlare
This project aims to modify your Apache configuration to let you get the real ip address of your visitors for your web applications that behind of Cloudflare's reverse proxy network. Bash script can be scheduled to create an automated up-to-date Cloudflare ip list file.

To provide the client (visitor) IP address for every request to the origin, Cloudflare adds the "CF-Connecting-IP" header. We will catch the header and get the real ip address of the visitor.

## Apache Configuration
With a small configuration modification we can integrate replacing the real ip address of the visitor instead of getting CloudFlare's load balancers' ip addresses.

First, enable *mod_remoteip* by issuing the following command:

```sh
sudo a2enmod remoteip
```

Update the site configuration to include *RemoteIPHeader CF-Connecting-IP*, e.g. /etc/apache2/sites-available/000-default.conf

```apache
<VirtualHost *:80>
ServerAdmin webmaster@localhost
DocumentRoot /var/www/html
ServerName server.example.com
RemoteIPHeader CF-Connecting-IP
ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```
Update combined *LogFormat* entry in apache.conf, replacing *%h* with *%a* in /etc/apache2/apache2.conf. For example, if your current *LogFormat* appeared as follows:

```apache
LogFormat "%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combined
```
you would update *LogFormat* to the following:

```apache
LogFormat "%a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combined
```

The bash script may run manually or can be scheduled to refresh the ip list of CloudFlare automatically.
```sh
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
```

## Output
Your "/etc/apache2/conf-available/remoteip.conf" file may look like as below;

```apache
RemoteIPHeader CF-Connecting-IP
set_real_ip_from 173.245.48.0/20;
set_real_ip_from 103.21.244.0/22;
set_real_ip_from 103.22.200.0/22;
set_real_ip_from 103.31.4.0/22;
set_real_ip_from 141.101.64.0/18;
set_real_ip_from 108.162.192.0/18;
set_real_ip_from 190.93.240.0/20;
set_real_ip_from 188.114.96.0/20;
set_real_ip_from 197.234.240.0/22;
set_real_ip_from 198.41.128.0/17;
set_real_ip_from 162.158.0.0/15;
set_real_ip_from 104.16.0.0/12;
set_real_ip_from 172.64.0.0/13;
set_real_ip_from 131.0.72.0/22;
set_real_ip_from 2400:cb00::/32;
set_real_ip_from 2606:4700::/32;
set_real_ip_from 2803:f800::/32;
set_real_ip_from 2405:b500::/32;
set_real_ip_from 2405:8100::/32;
set_real_ip_from 2a06:98c0::/29;
set_real_ip_from 2c0f:f248::/32;

```

## Crontab
Change the location of "/opt/scripts/cloudflare-ip-whitelist-sync.sh" anywhere you want. 
CloudFlare IP addresses are automatically refreshed every day, and Apache will be reloaded when synchronization is completed.
```sh
# Auto sync ip addresses of Cloudflare and reload Apache
30 2 * * * /opt/scripts/cloudflare-ip-whitelist-sync.sh >/dev/null 2>&1
```

### License

[Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0)


### DISCLAIMER
----------
Please note: all tools/scripts in this repo are released for use "AS IS" **without any warranties of any kind**,
including, but not limited to their installation, use, or performance.  We disclaim any and all warranties, either 
express or implied, including but not limited to any warranty of noninfringement, merchantability, and/ or fitness 
for a particular purpose.  We do not warrant that the technology will meet your requirements, that the operation 
thereof will be uninterrupted or error-free, or that any errors will be corrected.

Any use of these scripts and tools is **at your own risk**.  There is no guarantee that they have been through 
thorough testing in a comparable environment and we are not responsible for any damage or data loss incurred with 
their use.

You are responsible for reviewing and testing any scripts you run *thoroughly* before use in any non-testing 
environment.

Thanks,   
[muncherelli](https://muncherelli.com?utm_source=github&utm_medium=web&utm_campaign=apache-cloudflare-real-ip&utm_term=muncherelli.com&utm_content=README.md)
