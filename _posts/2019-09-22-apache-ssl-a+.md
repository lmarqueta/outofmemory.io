---
layout: post
title: Qualys SSL A+
subtitle: Getting an A+ with Apache and Let's Encrypt
tags: [apache, ssl]
comments: true
---

Basic Apache configuration to get an A+ rating in Qualys SSL test.

Background:

* Ubuntu 18.04 LTS
* Apache 2.4
* Let's Encrypt certificates

## Apache SSL module configuration

{% highlight conf %}
# Created by certbot
SSLEngine on

# Intermediate configuration, tweak to your needs
SSLProtocol             all -SSLv2 -SSLv3
SSLCipherSuite          ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS

# If only TLSv1.2 is needed:
# SSLCipherSuite EECDH+AESGCM:EDH+AESGCM

SSLHonorCipherOrder     on
SSLCompression          off

SSLOptions +StrictRequire

# Add vhost name to log entries:
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"" vhost_combined
LogFormat "%v %h %l %u %t \"%r\" %>s %b" vhost_common

#CustomLog /var/log/apache2/access.log vhost_combined
#LogLevel warn
#ErrorLog /var/log/apache2/error.log

# Always ensure Cookies have "Secure" set (JAH 2012/1)
#Header edit Set-Cookie (?i)^(.*)(;\s*secure)??((\s*;)?(.*)) "$1; Secure$3$4"
{% endhighlight %}


## Virtual Hosts

{% highlight conf %}
<VirtualHost *:80>
  ServerName <servername>
  ServerAlias <serveralias>
  RewriteEngine On
  RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R,L]
  RewriteCond %{SERVER_NAME} =<servername> [OR]
  RewriteCond %{SERVER_NAME} =<serveralias>
  RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>

<VirtualHost *:443>
  ServerName <servername>
  ServerAlias <serveralias>
  DocumentRoot /var/www/<path>
  Header always set Strict-Transport-Security "max-age=63072000;"
  SSLEngine on
  Include /etc/letsencrypt/options-ssl-apache.conf
  SSLCertificateFile /etc/letsencrypt/live/<domainname>/fullchain.pem
  SSLCertificateKeyFile /etc/letsencrypt/live/<domainname>/privkey.pem
</VirtualHost>
{% endhighlight %}


Get the files at [GIST](https://gist.github.com/lmarqueta):

* [virtualhost.conf](https://gist.githubusercontent.com/lmarqueta/c83fca0512f546cf6f5e5d1041fc4d77/raw/fd199c7b4345effa5ab0d2c7891a15e4d6ec8d3c/virtualhost.conf)
* [options-ssl-apache.conf](https://gist.githubusercontent.com/lmarqueta/c83fca0512f546cf6f5e5d1041fc4d77/raw/fd199c7b4345effa5ab0d2c7891a15e4d6ec8d3c/options-ssl-apache.conf)
