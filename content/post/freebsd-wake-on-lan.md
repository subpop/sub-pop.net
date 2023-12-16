+++
title = "Freebsd Wake on Lan"
date = 2023-12-15T21:52:48-05:00
+++

I could not find clear documentation anywhere on the Internet on how exactly to
enable wake-on-lan capabilities on a system76 `meer1` running FreeBSD, so here
goes:

```
sysctl dev.em.0.wake=1
```

To make this change permanent across reboots:

```
echo 'dev.em.0.wake=1' >> /etc/sysctl.conf
```
