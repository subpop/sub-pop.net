+++
date = "2015-12-31T23:52:00-08:00"
draft = false
title = "Fedora 23 on System76 Oryx Pro"
slug = "fedora-23-on-system76-oryx-pro"
aliases = ["fedora-23-on-system76-oryx-pro"]
categories = ["Linux"]
+++
I recently bought a System76 Oryx Pro, and have been getting myself familiar with it. Not satisfied with Ubuntu and Unity, I set out to install Fedora 23.

## Pre-installation ##

In order to boot using the NVIDIA proprietary driver and still have access to a VGA console (rather than a blank screen), I found I needed to disable UEFI in the BIOS setup and install Fedora in BIOS mode. I don't really see what I gain from booting with UEFI here, so I found this to be a pretty easy thing to leave off. In fact, the Intel boot splash that tells you to press F2 for Setup *reappears* when UEFI is disabled, so it seems like a win-win.

While you're in the BIOS, enable the hybrid GPU. This will turn on an Intel integrated GPU that is compatible with [bumblebee](http://bumblebee-project.org).

## Installation ##

Installation works flawlessly.

## Post-installation ##

### Bumblebee ###

Follow the [instructions](http://fedoraproject.org/wiki/Bumblebee) for setting up bumblebee on the Fedora wiki and all the issues described below are avoided. I'm leaving them here for posterity.

### GDM Lag ###

The first thing I noticed upon reboot was GDM was extremely laggy. The mouse and keyboard inputs were jerky, and keystrokes repeated themselves. This appears to be some conflict between the GTX 970M, Wayland, and nouveau (though I didn't research it a ton, because as it turned out, the proprietary `nvidia` driver runs GDM in Wayland smoothly). If you *need* to keep the `nouveau` driver, You can always uncomment the `WaylandEnable` option in `/etc/gdm/custom.conf` to disable Wayland in GDM and have a responsive GDM.

### Proprietary NVIDIA driver ###

Enable [rpmfusion](http://rpmfusion.org) and install `akmod-nvidia`. The `nouveau` driver does not support any form of hardware acceleration on this GPU (GTX 970M), so `gnome-shell` runs in low-performance mode (no animations, etc.). I strongly suggest using the `nvidia` drivers instead of `nouveau`. The `nvidia` drivers don't support Linux KMS though, so the pretty graphical boot "Plymouth" won't run. You'll get a standard VGA boot graphic instead. I figured it's a reasonable tradeoff. That pretty boot screen is only visible for a few seconds, so it's worth disabling in favor of higher-performance graphics inside GNOME.

### Backlight ###

This was the most perplexing thing I encountered. `/sys/class/backlight/acpi_video0` exists, the backlight hotkeys in GNOME change the value in `actual_brightness` as expected, but the backlight itself never adjusts. I found that `xbacklight` *will* adjust the brightness though, and after much research, I found [this wiki article on the Archlinux wiki](https://wiki.archlinux.org/index.php/Backlight#sysfs_modified_but_no_brightness_change). They blame either the BIOS vendor or the GPU vendor, but either way, I'm stuck without a reasonable way to adjust backlight settings. So I created `~/.local/bin/xbacklightd`, containing:

```
#!/bin/bash
max=/sys/class/backlight/acpi_video0/max_brightness
level=/sys/class/backlight/acpi_video0/actual_brightness
factor=$(awk '{print $1/100}' <<< $(<$max)) 

xblevel() { awk '{print int($1/$2)}' <<< "$(<$level) $factor"; }
xbacklight -set $(xblevel)
inotifywait -m -qe modify $level | while read -r file event; do
    xbacklight -set $(xblevel)
done
```

And a corresponding `~/.config/systemd/user/xbacklightd.service`, containing:

```
[Unit]
Description=Monitor backlight file for changes

[Service]
ExecStart=/home/link/.local/bin/xbacklightd

[Install]
WantedBy=default.target
```

This forces `xbacklight` to adjust the backlight setting whenever the file `actual_brightness` changes. You must have have both `xbacklight` and `inotify-tools` installed for this to work.

*Edit*: I'm not sure if this has any effect, but I did add `video.use_native_backlight=1` to `GRUB_CMDLINE_LINUX` in `/etc/default/grub`. It appears to make the backlight behave a little better, but all the above xbacklight stuff is still required.
