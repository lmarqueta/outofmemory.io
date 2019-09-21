---
layout: post
title:  Resize encrypted disk in macOS
date: 2017-07-07
tags: [macOS]
---

To increase size of volume `Encrypted` in 250 MB:

```bash
hdiutil resize -size 250m /Users/me/Encrypted/Encrypted.dmg
```
