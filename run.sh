#!/bin/bash
# By Fer Uría <fauria@gmail.com>
# See: http://www.exim.org/howto/mailman21.html
# and: https://help.ubuntu.com/community/Mailman
# and: https://debian-administration.org/article/718/DKIM-signing_outgoing_mail_with_exim4
mailmancfg='/etc/mailman/mm_cfg.py'

cat << EOB
    
    ***********************************************
    *                                             *
    *   Docker image: fauria/mailman              *
    *   https://github.com/fauria/docker-mailman  *
    *                                             *
    ***********************************************

EOB

# Fill debconf files with proper runtime values:
/bin/sed -i "s/lists\.example\.com/${EMAIL_FQDN}/" /exim4-config.cfg
if [ $LIST_LANGUAGE_CODE != "en" ]; then
	/bin/sed -i "s/default_server_language\ select\ en\ (English)/default_server_language\ select\ ${LIST_LANGUAGE_CODE}\ (${LIST_LANGUAGE_NAME})/" /mailman-config.cfg
	/bin/sed -i "/^mailman mailman\/site_languages/ s/$/\,\ ${LIST_LANGUAGE_CODE}\ \(${LIST_LANGUAGE_NAME}\)/" /mailman-config.cfg
fi

# Set debconf values and reconfigure Exim and Mailman. For some reason, dpkg-reconfigure exim4-config does not seem to work.
echo -n "Setting up Exim..."
{
	apt-get remove --purge -y exim4 exim4-base exim4-config exim4-daemon-light
	debconf-set-selections /exim4-config.cfg
	echo ${EMAIL_FQDN} > /etc/mailname
	apt-get install -y exim4
} &>/dev/null
echo ' Done.'	

echo -n "Setting up Mailman..."
{
	debconf-set-selections /mailman-config.cfg
	dpkg-reconfigure mailman
} &>/dev/null
echo ' Done.'

# Replace default hostnames with runtime values:
/bin/sed -i "s/lists\.example\.com/${EMAIL_FQDN}/" /etc/exim4/conf.d/main/00_local_macros
/bin/sed -i "s/lists\.example\.com/${EMAIL_FQDN}/" /etc/exim4/conf.d/main/04_exim4-config_mailman
/bin/sed -i "s/lists\.example\.com/${URL_FQDN}/" /etc/apache2/sites-available/mailman.conf
/bin/sed -i "s/DEFAULT_EMAIL_HOST.*\=.*/DEFAULT_EMAIL_HOST\ \=\ \'${EMAIL_FQDN}\'/" $mailmancfg
/bin/sed -i "s/DEFAULT_URL_HOST.*\=.*/DEFAULT_URL_HOST\ \=\ \'${URL_FQDN}\'/" $mailmancfg
/bin/sed -i "s/DEFAULT_SERVER_LANGUAGE.*\=.*/DEFAULT_SERVER_LANGUAGE\ \=\ \'${LIST_LANGUAGE_CODE}\'/" $mailmancfg

# Add some directives to Mailman config:
echo "MTA = None" >> $mailmancfg
echo 'DELIVERY_MODULE = "SMTPDirect"' >> $mailmancfg
echo 'SMTP_MAX_RCPTS = 500' >> $mailmancfg
echo 'MAX_DELIVERY_THREADS = 0' >> $mailmancfg
echo 'SMTPHOST = "localhost"' >> $mailmancfg
echo 'SMTPPORT = 0' >> $mailmancfg

echo -n "Initializing mailing lists..."
{
	/usr/sbin/mmsitepass ${MASTER_PASSWORD}
	/usr/sbin/newlist -q -l ${LIST_LANGUAGE_CODE} mailman ${LIST_ADMIN} ${MASTER_PASSWORD}
} &>/dev/null
echo ' Done.'

echo -n "Setting up Apache web server..."
{
	a2enmod cgi
	a2ensite mailman.conf
} &>/dev/null

echo -n "Generating RSA keys for DKIM..."
{
	openssl genrsa -out private.pem 2048 -outform PEM
	openssl rsa -in private.pem -out public.pem -pubout -outform PEM
} &>/dev/null
echo ' Done.'

key=$(sed -e '/^-/d' public.pem|paste -sd '' -)
ts=$(date +%Y%m%d)

echo -n "Fixing permissons and finishing setup..."
{
	update-exim4.conf
	/usr/lib/mailman/bin/check_perms -f
} &>/dev/null
echo ' Done.'

echo -n "Starting up services..."
{
	/etc/init.d/exim4 start
	/etc/init.d/mailman start
} &>/dev/null
echo ' Done.'

cat << EOB
    
    ***********************************************
    *                                             *
    *   TO COMPLETE DKIM SETUP, COPY THE          *
    *   FOLLOWING CODE INTO A NEW TXT RECORD      *
    *   IN YOUR DNS SERVER:                       *
    *                                             *
    ***********************************************

EOB
echo "${ts}._domainkey.${EMAIL_FQDN} IN TXT \"k=rsa; p=$key\""
echo
echo
echo '------------- CONTAINER UP AND RUNNING! -------------'

apachectl -DFOREGROUND -k start