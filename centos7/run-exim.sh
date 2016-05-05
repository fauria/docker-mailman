#!/bin/bash
# See: http://minhtech.com/featuredlinux/install-and-configure-mailman/

echo "ServerName ${URL_FQDN}:80" >> /etc/httpd/conf/httpd.conf

echo "RedirectMatch ^/mailman[/]*$ http://${URL_FQDN}/mailman/listinfo" >> /etc/httpd/conf.d/mailman.conf
/usr/bin/sed -i "s/DEFAULT_URL_HOST[ ]*\=[ ]*fqdn/DEFAULT_URL_HOST\ \=\ \'${URL_FQDN}\'/" /etc/mailman/mm_cfg.py
/usr/bin/sed -i "s/DEFAULT_EMAIL_HOST[ ]*\=[ ]*fqdn/DEFAULT_EMAIL_HOST\ \=\ \'${EMAIL_FQDN}\'/" /etc/mailman/mm_cfg.py
echo "DEFAULT_SERVER_LANGUAGE = '${LIST_LANGUAGE}'" >> /etc/mailman/mm_cfg.py
echo "DELIVERY_MODULE = 'SMTPDirect'" >> /etc/mailman/mm_cfg.py
echo "MTA = None" >> /etc/mailman/mm_cfg.py



/usr/lib/mailman/bin/mailmanctl start
/usr/lib/mailman/bin/check_perms -f
# ./run.sh 
# /usr/sbin/apachectl -k start

# docker run -i -t --rm -h lists.aedeti.es -e URL_FQDN=lists.aedeti.es -e EMAIL_FQDN=lists.aedeti.es -e MASTER_PASSWORD=Aedeti2016 -e LIST_LANGUAGE=es -e LIST_ADMIN=info@lists.aedeti.es -p 49780:80 -p 25:25 fauria/mailman bash

# Docs:
# First: http://minhtech.com/featuredlinux/install-and-configure-mailman/
# Ubuntu: https://help.ubuntu.com/community/Mailman
# Centos: http://samiam.org/blog/2014-03-23.html
# Check: http://www.yolinux.com/TUTORIALS/LinuxTutorialMailman.html
# Check: http://baldric.net/mailman-with-postfix/
# With Exim: http://www.exim.org/howto/mailman21.html