---
layout: post
title: ufw cheat sheet
subtitle: The default firewall configuration tool for Ubuntu is ufw
tags: [iptables, security, ubuntu, ufw]
image: /img/ubuntu-logo.png
---

From [Ubuntu help](https://help.ubuntu.com/community/UFW):

> The default firewall configuration tool for Ubuntu is ufw. Developed to ease iptables firewall configuration, ufw provides a user friendly way to create an IPv4 or IPv6 host-based firewall. By default UFW is disabled.

## Basic ufw usage

{% highlight bash linenos %}
# enable UFW
ufw enable

# To check the status of UFW:
ufw status verbose
ufw status numbered

# Allow ports:
ufw allow 80
ufw allow 443

# Allow ports using /etc/service name:
ufw allow http
ufw allow https

# Allow port/protocol:
ufw allow 53/udp

# Allow port ranges:
ufw allow 1000:2000/tcp

# Deny (port/protocol):
ufw deny 53/tcp

# Delete rules:
# Prepend delete to the rule:
ufw delete allow http
ufw delete deny 53/tcp

# Enable/disable logging:
ufw logging on
ufw logging off

# Allow from IP/subnet:
ufw allow from 192.168.1.1
ufw allow from 192.168.1.0/24
ufw allow from 192.168.1.0/24 to 127.0.0.1 port 445 proto tcp

# Deny by IP:
ufw deny from 192.168.1.100
ufw deny from 192.168.1.0/24
ufw deny from 192.168.1.0/24 to 127.0.0.1 port 445 proto tcp

# Delete specific rules:
ufw status numbered
ufw delete 7


# You can reject instead of deny:
ufw reject 53/tcp

# Reasonable default
ufw default deny incoming
ufw default allow outgoing

# Show details:
ufw show raw

# Start over again:
ufw reset
{% endhighlight %}
