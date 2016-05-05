FROM centos:7
MAINTAINER Fer Uria <fauria@gmail.com>

ENV URL_FQDN lists.example.com
ENV EMAIL_FQDN lists.example.com
ENV MASTER_PASSWORD example
ENV LIST_LANGUAGE en
ENV LIST_ADMIN admin@lists.example.com

RUN yum -y update && yum clean all
RUN yum -y install mailman httpd postfix

COPY run.sh /
COPY postfix-to-mailman.py /usr/lib/mailman/bin/

RUN chmod +x /run.sh
RUN chmod +x /usr/lib/mailman/bin/postfix-to-mailman.py

# VOLUME /var/log/mailman
# VOLUME /usr/lib/mailman/mail