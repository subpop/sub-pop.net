+++
title = "devbox"
date = 2021-07-06T21:59:42-04:00
+++

As part of my development workflow, I have found disposable, reproducible virtual machines indispensable. Over time, I have slowly developed a set of scripts and commands to create and destroy virtual machines. This time, those scripts and tools finally coalesced to something that can be packaged and released as a bit of developer software.

devbox is a simple Makefile that generates disk images and libvirt domains. It is little more than a set of carefully crafted `virt-builder` and `virt-install` commands. See the [https://sr.ht/~spc/devbox](README) for details on how to use it.

After setting it up and defining a domain, I'm able to quickly connect to a centos-7 domain and run my code, jump over to a centos-8 domain and run the same code, and if need be, I can destroy one of these domains quickly and rebuild them.

The real "magic" here is using virtiofsd to export a filesystem from the host to the guest. In the case of these "devbox" domains, the path defined by `CODE_DIR` is exported as a virtiofs filesystem:

```
virt-install [...] \
	--filesystem source=$(CODE_DIR),target=/code,$(FSDEV_FLAGS)
```

`FSDEV_FLAGS` defaults to `driver.type=virtiofs,accessmode=passthrough`. This will export $CODE_DIR into the guest with the mount tag `/code`. The exported filesystem is not mounted by default, so the guest needs to mount it directly by adding an entry to `/etc/fstab`:

```
/code /code virtiofs defaults 0 0
```

This works wonderfully for OS versions that have a kernel that supports virtiofs (CentOS 8 and up). For CentOS 7, I had to go a different, more complicated route.

Since the mainline CentOS kernel does not have the virtiofs driver, we need to use a 9p filesystem export instead. Fortunately, the CentOS Plus kernel ships a `9pnet_virtio` module that does just that. This means that our customization file for CentOS 7 domains needs to be a bit more complicated. Including this snippet in any CentOS 7 domains you create will enable the CentOS Plus kernel, enable the `9pnet_virtio` module and define the mount point in `/etc/fstab`:

```
run-command yum-config-manager --enable centosplus
run-command sed -ie "s/DEFAULTKERNEL=kernel/DEFAULTKERNEL=kernel-plus/" /etc/sysconfig/kernel
append-line /etc/dracut.conf.d/virtio.conf:add_drivers+="virtio_scsi virtio_pci virtio_console"
append-line /etc/modules-load.d/9pnet_virtio.conf:9pnet_virtio
install kernel-plus
append-line /etc/fstab:/code /code 9p trans=virtio 0 0
```

And when defining a centos-7.mk file, you'll need to set `FSDEV_FLAGS` (note we remove the default `driver.type=virtiofs` argument):

```
centos-7.xml: FSDEV_FLAGS = accessmode=passthrough
```

A working example for centos-7 is also included in the devbox repository. Happy developing!