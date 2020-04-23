fauria/mailman
==========

![docker_logo](https://raw.githubusercontent.com/fauria/docker-mailman/master/docker_139x115.png)![docker_fauria_logo](https://raw.githubusercontent.com/fauria/docker-mailman/master/docker_fauria_161x115.png)

[![Docker Pulls](https://img.shields.io/docker/pulls/fauria/mailman.svg?style=plastic)](https://hub.docker.com/r/fauria/mailman/)
[![Docker Build Status](https://img.shields.io/docker/build/fauria/mailman.svg?style=plastic)](https://hub.docker.com/r/fauria/mailman/builds/)
[![](https://images.microbadger.com/badges/image/fauria/mailman.svg)](https://microbadger.com/images/fauria/mailman "fauria/mailman")

This Docker container ships a full [GNU Mailman](https://www.gnu.org/software/mailman/) solution based on Ubuntu 16.04. It allows the deployment of a working mailing list service with a single command line.

It does not depend on any other service, everything needed is provided by the Docker image. The system is automatically initialised with options supplied through environment variables defined at run time.

The following components are included:

 * Ubuntu 16.04 LTS base image
 * Mailman 2.1
 * Apache HTTP Server 2.4
 * Exim 4.8

Installation from [Docker registry hub](https://registry.hub.docker.com/r/fauria/mailman/).
----

You can download the image using the following command:

```bash
docker pull fauria/mailman
```

Host name
----

The image should be launched specifying a hostname, that is, using `-h lists.example.com` `docker` modifier.

Environment variables
----

This image uses several environment variables to define different values to be used at run time:

* Variable name: `URL_FQDN`
* Default value: `lists.example.com`
* Accepted values: Any fully qualified domain name.
* Description: Domain that will be used to access Mailman user interface through a web server. Usually the same as ```EMAIL_FQDN```.

----

* Variable name: `EMAIL_FQDN`
* Default value: `lists.example.com`
* Accepted values: Any fully qualified domain name.
* Description: Domain that will originate the emails of the list. Should match the hostname specified in the command line throuhg `-h` modifier, and usually will be the same as `URL_FQDN` as well.

----

* Variable name: `LIST_ADMIN`
* Default value: `admin@lists.example.com`
* Accepted values: Any valid email address.
* Description: List administrator email address. Used to create the mandatory `mailman` mailing list.

----

* Variable name: `MASTER_PASSWORD`
* Default value: `example`
* Accepted values: Any string.
* Description: List administrator password. Used to create the mandatory ```mailman``` mailing list.

----

* Variable name: `LIST_LANGUAGE_CODE`
* Default value: `en`
* Accepted values: Any of the [supported ISO-639 codes](https://wiki.list.org/DEV/Languages) by Mailman.
* Description: Used to determine a language to be used in addition to English. Currently supports only one more language. Does not override ```en```.

----

* Variable name: `LIST_LANGUAGE_NAME`
* Default value: `English`
* Accepted values: Any of the [supported language names](https://wiki.list.org/DEV/Languages) by Mailman.
* Description: Used to determine one more language to be used in addition to English. Note that it does not replace `English`, but adds one more language to be used on the lists.

----

* Variable name: `DEBUG_CONTAINER`
* Default value: `false`
* Accepted values: `false`, `true`
* Description: Used to control the output of the container. By default, only relevant information will be displayed. If you want to output every command executed during setup, run the container with `-e DEBUG_CONTAINER=true`.

Exposed port and volumes
----

The image exposes ports `80` and `25`, corresponding to Apache and Exim respectively.

Also exports six volumes:

- `/var/log/mailman`: Logs for Mailman.
- `/var/log/exim4`: Logs for Exim MTA.
- `/var/log/apache2`: Logs for Apache webserver.
- `/var/lib/mailman/archives`: Mailman mailing lists archives.
- `/var/lib/mailman/lists`: Mailman mailing lists.
- `/etc/exim4/tls.d`: Exim DKIM keys. Expected to contain `private.pem` and `public.pem` files. If omitted, a new pair of keys will be created on runtime.

Recommendations
----

1. Use an specific subdomain for your mailing list, such as `lists.example.com`.

2. Make sure you can add TXT records in your domain's DNS master zone. 

3. In addition to [DKIM](https://www.linode.com/docs/networking/dns/dns-records-an-introduction#dkim), consider adding an [SPF](https://www.linode.com/docs/networking/dns/dns-records-an-introduction#spf) to set your server as the only one originating email for the list domain.

4. If you want to use your own pair of RSA keys for DKIM, create a diretory in the host containing two files named `private.pem` and `public.pem` respectively. Then run the container attaching that directory to `/etc/exim4/tls.d`, i.e. `-v /my/local/dir/keys:/etc/exim4/tls.d`.

Use cases
----

1. Run a temporary container for testing purposes with default values:
 
```
	docker run -i -t --rm -h lists.example.com -e DEBUG_CONTAINER=true fauria/mailman
```

2. Run a production container for domain `whatever.example.com` without exported volumes:
 
```
	docker run -d --restart=always -h whatever.example.com -e URL_FQDN=whatever.example.com -e EMAIL_FQDN=whatever.example.com -e MASTER_PASSWORD=SecretPassword -e LIST_ADMIN=whoever@example.com -p 49780:80 -p 25:25 fauria/mailman
```

3. Run a production container, with exported volumes and support for Spanish language:

```
	docker run -d --restart=always --name my-mailing-list -h whatever.example.com -e URL_FQDN=whatever.example.com -e EMAIL_FQDN=whatever.example.com -e MASTER_PASSWORD=SecretPassword -e LIST_LANGUAGE_CODE=es -e LIST_LANGUAGE_NAME=Spanish -e LIST_ADMIN=whoever@example.com -e DEBUG_CONTAINER=false -p 49780:80 -p 25:25 -v /my/local/dir/archives:/var/lib/mailman/archives -v /my/local/dir/lists:/var/lib/mailman/lists -v /my/local/dir/keys:/etc/exim4/tls.d -v /my/local/dir/log/apache2:/var/log/apache2 -v /my/local/dir/log/exim4:/var/log/exim4 -v /my/local/dir/log/mailman:/var/log/mailman fauria/mailman
```

In this case, we are using directories outside the container to [persist data](https://docs.docker.com/engine/userguide/containers/dockervolumes/). The following commands were run in the host system to initialize the shared volumes:

```bash
	mkdir -p /my/local/dir/archives/{private,public}
	mkdir -p /my/local/dir/lists
	chown -R 0:38 /my/local/dir/{archives,lists}
	chown 33 /my/local/dir/archives/private
	mkdir -p /my/local/dir/log/{apache2,exim4,mailman}
	chown 0:4 /my/local/dir/log/apache2
	chown 105:4 /my/local/dir/log/exim4
	chown 0:38 /my/local/dir/log/mailman
```

This will create the host directories and set their permissions according to the following IDs:

```
	uid=33(www-data) gid=33(www-data) groups=33(www-data)
	uid=38(list) gid=38(list) groups=38(list)
	uid=105(Debian-exim) gid=108(Debian-exim) groups=108(Debian-exim)
```
