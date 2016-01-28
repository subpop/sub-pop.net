+++
date = "2015-12-31T23:57:00-08:00"
draft = false
title = "Better Font Rendering in Fedora"
slug = "better-font-rendering-in-fedora"
aliases = ["better-font-rendering-in-fedora"]
topics = ["Linux"]
+++
I'm not going to go into the philosophical argument about free software. If you want better font rendering, this is what I do.

* Enable [rpmfusion](http://rpmfusion.org) and install `freetype-freeworld`
* Copy `/usr/share/fontconfig/conf.avail/10-autohint.conf` to `/etc/fonts/conf.d/`
* Edit `/etc/fonts/conf.d/10-autohint.conf` and replace "append" with "assign"
* In GNOME Tweak Tool -> Fonts, set Hinting to 'Slight' and Antialiasing to 'Rgba'
