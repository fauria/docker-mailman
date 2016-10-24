FROM ubuntu:16.04
MAINTAINER Fer Uria <fauria@gmail.com>

ENV URL_FQDN lists.example.com
ENV EMAIL_FQDN lists.example.com
ENV MASTER_PASSWORD example
ENV LIST_LANGUAGE_CODE en
ENV LIST_LANGUAGE_NAME English
ENV LIST_ADMIN admin@lists.example.com
ENV DEBUG_CONTAINER false

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get update
RUN apt-get -y upgrade

RUN apt-get install -y mailman exim4 apache2

COPY 00_local_macros /etc/exim4/conf.d/main/
COPY 04_exim4-config_mailman /etc/exim4/conf.d/main/
COPY 40_exim4-config_mailman /etc/exim4/conf.d/transport/
COPY 101_exim4-config_mailman /etc/exim4/conf.d/router/
COPY mailman.conf /etc/apache2/sites-available/

COPY exim4-config.cfg /
COPY mailman-config.cfg /
COPY run.sh /

RUN chmod +x /run.sh

VOLUME /var/log/mailman
VOLUME /var/log/exim4
VOLUME /var/log/apache2
VOLUME /var/lib/mailman/archives
VOLUME /var/lib/mailman/lists
VOLUME /etc/exim4/tls.d

EXPOSE 25 80

CMD ["/run.sh"]