---
layout: post
title:  Uso de netcat
excerpt: Uso básico de netcat
comments: true
tags: [netcat, nc]
---
## netcat

Netcat es una utilidad que permite el envío y recepción de datos vía TCP/UDP desde la consola. Inicialmente desarrollada para Unix, se ha portado al menos a Windows y OS X. Hay varios _forks_ con distintas capacidades; en resumen, está en todas partes y sirve para... muchas cositas.

## Sintaxis

De la versión instalada por defecto en Debian Jessie:

```shell
root@jessie:~# nc -h
[v1.10-41]
connect to somewhere:	nc [-options] hostname port[s] [ports] ...
listen for inbound:	nc -l -p port [-options] [hostname] [port]
options:
	-c shell commands	as `-e'; use /bin/sh to exec [dangerous!!]
	-e filename		program to exec after connect [dangerous!!]
	-b			allow broadcasts
	-g gateway		source-routing hop point[s], up to 8
	-G num			source-routing pointer: 4, 8, 12, ...
	-h			this cruft
	-i secs			delay interval for lines sent, ports scanned
        -k                      set keepalive option on socket
	-l			listen mode, for inbound connects
	-n			numeric-only IP addresses, no DNS
	-o file			hex dump of traffic
	-p port			local port number
	-r			randomize local and remote ports
	-q secs			quit after EOF on stdin and delay of secs
	-s addr			local source address
	-T tos			set Type Of Service
	-t			answer TELNET negotiation
	-u			UDP mode
	-v			verbose [use twice to be more verbose]
	-w secs			timeout for connects and final net reads
	-C			Send CRLF as line-ending
	-z			zero-I/O mode [used for scanning]
port numbers can be individual or ranges: lo-hi [inclusive];
hyphens in port names must be backslash escaped (e.g. 'ftp\-data').
```

Con las opciones mínimas, `netcat` abrirá una conexión TCP (UDP si se utiliza la opción `-u`) al host y puerto indicado. Tened en cuenta que, en general, `nc` y `netcat` son alias del mismo comando (vamos, que se puede usar uno u otro indistintamente).

## Comunicación a través de netcat

Uno de los usos más habituales es el establecimiento de conexiones entre dos sistemas -dos _netcats_- en modo cliente-servidor. Para ello, tenemos que hacer escuchar a una máquina (opción -l) en el puerto pertinente mientras enviamos datos desde la otra.

Por ejemplo, nos ponemos a escuchar en el puerto 8090...

```shell
root@rxhost-a# netcat -l -p 8090
```

...y transmitimos desde otro sistema a ese puerto:

```shell
root@txhost-b# nc rxhost-a 8090
```

Si ahora escribimos algo en la consola de txhost-a, aparecerá en la de rxhost-b. Muy bien, pero la gracia está en que esto permite enviar ficheros. Por ejemplo, supongamos que queremos transferir el contenido de un fichero arbitrario desde txhost-b a rxhost-a. Pues haremos lo siguiente en el host donde lo vamos a recibir:

```shell
root@rxhost-a# netcat -l -p 8090 > recibido.txt
```

y lo transmitimos:

```shell
root@txhost-b# netcat rxhost-a 8090 < /etc/passwd
```

Utilizando _pipes_ podremos hacer cosas interesantes, como enviar ficheros o directorios completos en un _tarball_:

```shell
root@rxhost-a# netcat -l -p 8090 | tar zxvf -
```

```shell
root@txhost-b# tar -czf - * | netcat rxhost-a 8090
```

Otra forma es utilizando `dd`, que permite enviar no ya ficheros, sino dispositivos de bloque enteros. Por ejemplo, una adquisición forense de un disco, un backup bit a bit...

```shell
root@rxhost-a# netcat -l -p 8090 >id_rsa.pub
```

```shell
root@txhost-b# dd if=.ssh/id_rsa.pub | nc rxhost-a 8090
```

Se puede servir un fichero vía "web":

```shell
root@hosta:~# nc -l -p 80 <index.html
GET / HTTP/1.1
Host: 192.168.56.100
User-Agent: curl/7.49.1
Accept: */*
```

Y, en el otro extemo recibirlo:

```
user@hostb:~$ curl 192.168.56.100:80
<h1>Hola, mundo!</h1>
```

Otro clásico: _backdoor shells_

```shell
user@host-a:~$ nc -l -p 8090 -e /bin/bash
```

¡También en Windows!

```shell
c:\> nc -l -p 8090 -e cmd.exe
```

En el sistema remoto:

```shell
user@host-a:~$ nc host-a -p 8090
hostname
host-b
```

Más adelante añadiré otro post con cosas sobre shells inversas...

Un poquito más complejo: extracción del disco completo de un dispositivo Android. Partimos de un dispositivo _rooteado_ (necesitaremos acceder al disco en modo bloque con `dd`) y conectado vía USB con `adb`. El dispositivo móvil tiene `busybox` instalado.

Primero, haremos forward de un socket mediante adb usando un puerto arbitrario:

```shell
santoku@santoku:~$ adb forward tcp:8888 tcp:8888
santoku@santoku:~$ nc 127.0.0.1 8888 > dd.img
```

En el dispositivo (vía shell):

```shell
santoku@santoku:~$ adb shell
shell@android:/ $ su
shell@android:/ # dd if=/dev/block/mmcblk0 | busybox nc -l -p 8888
```

Y a esperar que se transfiera...
