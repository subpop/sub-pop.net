+++
author = "author"
date = "2016-02-11T07:49:09-08:00"
description = "description"
draft = false
tags = ["superdrive", "apple"]
title = "Using an Apple Superdrive on Fedora"
topics = ["Linux"]
type = "post"

+++

As described on [christianmoser.me](https://christianmoser.me/use-apples-usb-superdrive-with-linux/), in order to use the Apple Superdrive on Linux, you need to add a custom udev rule (`/etc/udev/rules.d/99-superdrive.rules`).

```
# Initialise Apple SuperDrive
ACTION=="add", ATTRS{idProduct}=="1500", ATTRS{idVendor}=="05ac", DRIVERS=="usb", RUN+="/usr/bin/sg_raw /dev/$kernel EA 00 00 00 00 00 01"
```

However, by default Fedora doesn't ship with `sg3_utils` installed by default, so you'll need to install it.
