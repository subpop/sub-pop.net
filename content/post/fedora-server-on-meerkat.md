+++
author = "Link"
date = "2016-02-16T22:24:17-08:00"
description = "Running Fedora Server on System76 Meerkat"
draft = false
title = "Fedora Server on Meerkat"
topics = ["Linux"]
type = "post"

+++

Fedora 23 Server installs with only a couple minor tweaks onto a System76 Meerkat (`meer1`). I chose to install from the closest mirror, and installed the latest updates to get the 4.3.x kernel. I'm not sure this was necessary, but I wanted to make sure I had the latest kernel packages available. Install as normal, but before rebooting, switch to a TTY (`ctrl` + `alt` + `f2`).

```
# chroot /mnt/sysimage
# dnf update
# dnf install iwl7260-firmware NetworkManager-wifi wpa_supplicant
```

Then reboot.

For [whatever reason](http://jorge.fbarr.net/2015/05/22/no-wi-fi-device-found/) NetworkManager has split its wifi bits into another package (`NetworkManager-wifi`) that isn't installed in the default Fedora Server package set. Also, you need to install the right firmware microcode files for this particular Intel Wireless card.
