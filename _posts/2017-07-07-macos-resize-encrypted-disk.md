---
layout: post
title:  Resize encrypted disk in macOS
image: '/img/macos-finder-icon.png'
tags: [macOS]
---

To increase size of volume `Encrypted` in 250 MB:

```bash
hdiutil resize -size 250m /Users/me/Encrypted/Encrypted.dmg
```
