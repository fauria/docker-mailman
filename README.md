fauria/mailman
==========

![docker_logo](https://googledrive.com/host/0B7q6BLMXak9VfkpQY3YzNldlSmtxRTZCMEtEVlhhR3QtMFc3aEYzVzA5YlM5MWw5OXhqV0U/docker_139x115.png)![docker_fauria_logo](https://googledrive.com/host/0B7q6BLMXak9VfkpQY3YzNldlSmtxRTZCMEtEVlhhR3QtMFc3aEYzVzA5YlM5MWw5OXhqV0U/docker_fauria_161x115.png)

This Docker container ships a full [GNU Mailman](https://www.gnu.org/software/mailman/) solution based on Ubuntu 16.04. It allows the deployment of a working mailing list service with a single command line.

It does not depend on any other service, everything needed is contained in the Docker image. The system is automatically initialised with options supplied through environment variables defined at run time.

The following components are included:

 * Ubuntu 16.04 LTS base image
 * Mailman 2.1
 * Apache HTTP Server 2.4
 * Exim 4.8

Installation from [Docker registry hub](https://registry.hub.docker.com/u/fauria/mailman/).
----

You can download the image using the following command:

```bash
docker pull fauria/lap
```

Host name
----

The image should be launched specifying a hostname, that is, with ```-h lists.example.com``` docker argument.

Environment variables
----

This image uses several environment variables to define different values to be used at run time:

* Variable name: URL_FQDN
* Default value: lists.example.com
* Accepted values: Any fully qualified domain name.
* Description: Domain that will be used to access Mailman user interface through a web server. Usually the same as ```EMAIL_FQDN```.

----

* Variable name: EMAIL_FQDN
* Default value: lists.example.com
* Accepted values: Any fully qualified domain name.
* Description: Domain that will originate the emails of the list. Should match the hostname specified in the command line throuhg ```-h``` modifier, and usually will be the same as ```URL_FQDN``` as well.

----

* Variable name: LIST_ADMIN
* Default value: admin@lists.example.com
* Accepted values: Any valid email address.
* Description: List administrator email address. Used in the automatically created, mandatory ```mailman``` mailing list.

----

* Variable name: MASTER_PASSWORD
* Default value: example
* Accepted values: Any string.
* Description: List administrator password. Used in the automatically created, mandatory ```mailman``` mailing list.

----

* Variable name: LIST_LANGUAGE_CODE
* Default value: en
* Accepted values: Any of the [supported ISO-639 codes](https://wiki.list.org/DEV/Languages) by Mailman.
* Description: Used to determine a language to be used in addition to English. Currently supports only one more language. Does not override ```en```.

----

* Variable name: LIST_LANGUAGE_NAME
* Default value: English
* Accepted values: Any of the [supported language names](https://wiki.list.org/DEV/Languages) by Mailman.
* Description: Used to determine a language to be used in addition to English. Currently supports only one more language. Does not override ```English``.

----

* Variable name: DEBUG_CONTAINER
* Default value: false
* Accepted values: false, true
* Description: Used to control the output of the container. By default, only relevant information will be displayed. If you want to output every command executed during setup, run the container with `-e DEBUG_CONTAINER=true`.

Exposed port and volumnes
----

The image exposes ports `80` and `25 and exports `four volumes: `XXX/var/log/httpd`, which contains Apache's logs, and `/var/www/html`, used as Apache's [DocumentRoot directory](http://httpd.apache.org/docs/2.4/en/mod/core.html#documentroot). 

The user and group owner id for this directory are both 48 (`uid=48(apache) gid=48(apache) groups=48(apache)`).

uid=38(list) gid=38(list) groups=38(list)

Recommendations
----

1. Use an specific subdomain for your mailing list, such as `lists.example.com`.

2. Make sure you can add TXT records in your domain's DNS master zone. 

3. In addition to [DKIM](https://www.linode.com/docs/networking/dns/dns-records-an-introduction#dkim), consider adding an [SPF](https://www.linode.com/docs/networking/dns/dns-records-an-introduction#spf) to set your server as the only one originating email for the list domain.

Use cases
----

1. Create a temporary container for testing purposes:
 
```
	docker run --rm fauria/lap
```

2. Create a temporary container to debug a web app:
 
```
	docker run --rm -p 8080:80 -e LOG_STDOUT=true -e LOG_STDERR=true -e LOG_LEVEL=debug -v /my/data/directory:/var/www/html fauria/lap
```

3. Create a container linking to another [MySQL container](https://registry.hub.docker.com/_/mysql/):

```
	docker run -d --link my-mysql-container:mysql -p 8080:80 -v /my/data/directory:/var/www/html -v /my/logs/directory:/var/log/httpd --name my-lap-container fauria/lap
```



uid=105(Debian-exim) gid=108(Debian-exim) groups=108(Debian-exim)
uid=38(list) gid=38(list) groups=38(list)
uid=33(www-data) gid=33(www-data) groups=33(www-data)