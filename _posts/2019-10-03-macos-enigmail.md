---
layout: post
title: Thunderbird + Enigmail in macOS
subtitle: Dance Like Nobody's Watching. Encrypt Like Everyone Is.
tags: [macOS, enigmail, pgp, thunderbird]
image: '/img/enigmail.png'
comments: true
---

Since some time ago [Enigmail](https://www.enigmail.net/) plugin for Thunderbird requires a working installation of GPG tools, including a graphical pinentry to be able to ask for the key passphrase.

It seems not to be available by default.

To solve it, install a graphical pinentry:

```bash
brew install pinentry-mac
echo "use-standard-socket
pinentry-program /usr/local/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
killall gpg-agent
```

And you are good to go.

## References

* [Engimail, gnupg & pinentry on Mac OS X using Homebrew](http://www.harpojaeger.com/2017/09/20/enigmail-gnupg-pinentry-on-mac-os-x-using-homebrew)
