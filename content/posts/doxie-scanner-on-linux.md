+++
date = "2015-12-06T22:53:00-08:00"
draft = false
title = "Doxie Scanner on Linux"
slug = "doxie-scanner-on-linux"
aliases = [
	"doxie-scanner-on-linux"
]
categories = [
	"Linux"
]
+++
I forget where I found this, but I'm documenting here for posterity. In order to get a Doxie scanner running under Linux, install the `sane-backends-drivers-scanners` package is installed. Then put the following into a local udev rule:

```
$ cat /etc/udev/rules.d/10-doxie-scanner.rules
# udevadm info -a -p $(udevadm info -q path -n /dev/bus/usb/001/009)

SUBSYSTEMS=="usb", ATTRS{manufacturer}=="Document Capture Technologies Inc.", ATTRS{idProduct}=="4812", GROUP="scanner"
```

Create a `scanner` group and add your user to it.

```
sudo groupadd -r scanner
sudo usermod -G scanner -a link
```
