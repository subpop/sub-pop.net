+++
date = "2015-09-20T22:17:00-08:00"
draft = false
title = "Fedora 22 on MacBook Pro"
slug = "fedora-22-on-macbook-pro"
aliases = ["fedora-22-on-macbook-pro"]
topics = ["Linux"]
+++
My main laptop happens to be a MacBookPro8,2. I found that Fedora 22 does not install seamlessly on this machine, given the nature of two key pieces of hardware: wireless and hybrid graphics.

#### Broadcom BCM4331 ####

I decided to use the proprietary `broadcom-wl` driver for my wireless; I tried the `b43` driver, but found that it has some connectivity issues when using a 2.4GHz router (dropping and reconnecting every minute or so). For posterity, here's how to set up `b43`.

```
# dnf install b43-fwcutter
# wget http://www.lwfinger.com/b43-firmware/broadcom-wl-5.100.138.tar.bz2
# tar xjf broadcom-wl-5.100.138.tar.bz2
# b43-fwcutter -w "/lib/firmware" broadcom-wl-5.100.138/linux/wl_apsta.o
```

To set up the `broadcom-wl` driver, first set up [rpmfusion](http://rpmfusion.org/Configuration):

```
# echo "blacklist b43" >> /etc/modprobe.d/blacklist.conf
# dnf install akmod-wl
```

#### Graphics ####
The MacBookPro8,2 model doesn't handle hybrid graphics very well under Linux. vga_switcheroo doesn't switch between the two, so you have to configure your boot steps to only load one card. See [this bug](https://bugzilla.redhat.com/show_bug.cgi?id=765954#c62) for details.

###### Discrete ATI Radeon ######
Disabling the Intel card can be done by simply by disabling KMS. Edit `/etc/default/grub`, changing the `GRUB_CMDLINE_LINUX` variable to: `rhgb quiet radeon.modeset=1 i915.modeset=0 radeon.dpm=1`. This will boot the laptop with the ATI Radeon enabled.

###### Integrated Intel ######
Disabling the ATI card is more involved, but worth the heat & power savings you gain by keeping the ATI card off.

First, copy the grub-efi modules into your EFI partition: `cp -R /usr/lib/grub/x86_64-efi /boot/efi/EFI/fedora/`
Then edit `/etc/default/grub` and add `GRUB_PRELOAD_MODULES="iorw"`. This makes the `outb` command we use below available to GRUB at runtime. Next, edit `/etc/grub.d/10_linux` and add the following lines below each occurrence of `echo " set gfxpayload=`:

    echo " outb 0x728 1"
    echo " outb 0x710 2"
    echo " outb 0x740 2"
    echo " outb 0x750 0"

Then regenerate your grub.cfg: `grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg`. Once done, you shouldn't need to redo these steps each time you upgrade your kernel.
