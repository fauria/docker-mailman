#! /usr/bin/env python

# Configuration variables - Change these for your site if necessary.
MailmanHome = "/var/lib/mailman"; # Mailman home directory.
MailmanOwner = "postmaster@example.com"; # Postmaster and abuse mail recipient.
MailmanScripts = "/usr/lib/mailman";     # Where mailman scripts reside

# End of configuration variables.

# postfix-to-mailman-2.1.py (to be installed as postfix-to-mailman.py)
#
# Interface mailman to a postfix with a mailman transport. Does not require
# the creation of _any_ aliases to connect lists to your mail system.
#
# Dax Kelson, dkelson@gurulabs.com, Sept 2002.
# coverted from qmail to postfix interface
# Jan 2003: Fixes for Mailman 2.1
# Thanks to Simen E. Sandberg <senilix@gallerbyen.net>
# Feb 2003: Change the suggested postfix transport to support VERP
# Thanks to Henrique de Moraes Holschuh <henrique.holschuh@ima.sp.gov.br>
#
# This script was originally qmail-to-mailman.py by:
# Bruce Perens, bruce@perens.com, March 1999.
# This is free software under the GNU General Public License.
#
# This script is meant to be called from ~mailman/postfix-to-mailman.py. 
# It catches all mail to a virtual domain, eg "lists.example.com".
# It looks at the  recipient for each mail message and decides if the mail is
# addressed to a valid list or not, and bounces the message with a helpful
# suggestion if it's not addressed to a list. It decides if it is a posting, 
# a list command, or mail to the list administrator, by checking for the
#  -admin, -owner, and -request addresses. It will recognize a list as soon
# as the list is created, there is no need to add _any_ aliases for any list.
# It recognizes mail to postmaster, mailman-owner, abuse, mailer-daemon, root,
# and owner, and routes those mails to MailmanOwner as defined in the
# configuration variables, above.
#
# INSTALLATION:
#
# Install this file as ~mailman/postfix-to-mailman.py
#
# To configure a virtual domain to connect to mailman, edit Postfix thusly:
#
# /etc/postfix/main.cf:
#    relay_domains = ... lists.example.com
#    transport_maps = hash:/etc/postfix/transport
#    mailman_destination_recipient_limit = 1
#
# /etc/postfix/transport:
#   lists.example.com   mailman:
#
# /etc/postfix/master.cf
#    mailman unix  -       n       n       -       -       pipe
#      flags=FR user=mailman:mailman 
#      argv=/var/mailman/postfix-to-mailman.py ${nexthop} ${user}
# 
#
# Replace list.example.com above with the name of the domain to be connected
# to Mailman. Note that _all_ mail to that domain will go to Mailman, so you
# don't want to put the name of your main domain here. Typically a virtual
# domain lists.domain.com is used for Mailman, and domain.com for regular
# email.
#

import sys, os, re, string

def main():
    os.nice(5)  # Handle mailing lists at non-interactive priority.
		# delete this if you wish

    os.chdir(MailmanHome + "/lists")

    try:
        local = sys.argv[2]
    except:
        # This might happen if we're not using Postfix
        sys.stderr.write("LOCAL not set?\n")
        sys.exit(1)

    local = string.lower(local)
    local = re.sub("^mailman-","",local)

    names = ("root", "postmaster", "mailer-daemon", "mailman-owner", "owner",
             "abuse")
    for i in names:
        if i == local:
            os.execv("/usr/sbin/sendmail",
                     ("/usr/sbin/sendmail", MailmanOwner))
            sys.exit(0)

    type = "post"
    types = (("-admin$", "admin"),
             ("-owner$", "owner"),
             ("-request$", "request"),
             ("-bounces$", "bounces"),
             ("-confirm$", "confirm"),
             ("-join$", "join"),
             ("-leave$", "leave"),
             ("-subscribe$", "subscribe"),
             ("-unsubscribe$", "unsubscribe"))

    for i in types:
        if re.search(i[0],local):
            type = i[1]
            local = re.sub(i[0],"",local)

    if os.path.exists(local):
        os.execv(MailmanScripts + "/mail/mailman",
                 (MailmanScripts + "/mail/mailman", type, local))
    else:
        bounce()
    sys.exit(75)

def bounce():
    bounce_message = """\
TO ACCESS THE MAILING LIST SYSTEM: Start your web browser on
http://%s/
That web page will help you subscribe or unsubscribe, and will
give you directions on how to post to each mailing list.\n"""
    sys.stderr.write(bounce_message % (sys.argv[1]))
    sys.exit(1)

try:
    sys.exit(main())
except SystemExit, argument:
    sys.exit(argument)

except Exception, argument:
    info = sys.exc_info()
    trace = info[2]
    sys.stderr.write("%s %s\n" % (sys.exc_type, argument))
    sys.stderr.write("Line %d\n" % (trace.tb_lineno))
    sys.exit(75)       # Soft failure, try again later.
