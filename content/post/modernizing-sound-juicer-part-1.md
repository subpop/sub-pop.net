+++
title = "Modernizing Sound Juicer, Part 1"
date = 2023-06-15T23:26:39-04:00
+++

I have long been interested in modernizing a [venerable open source project](https://gitlab.gnome.org/GNOME/sound-juicer). While some may argue that ripping CDs is no longer relevant, I personally do still purchase some music on CD, and want to listen to them in digital formats.

Sound Juicer is an old piece of software. Its first commit dates back over 20 years.

```
commit 36ff0dc5f60f5d69ba2b4f6179f5f129945e6f53
Author: Ross Burton <rburton@src.gnome.org>
Date:   Sun Mar 30 20:28:32 2003 +0000

    Initial revision
```

It began as a GTK2 application, and in 2010, was ported to GTK3.

```
commit 54aee97ed8bcc988b78d159a23b3ef5e994d5b8e
Author: Matthias Clasen <mclasen@redhat.com>
Date:   Tue Jul 13 22:30:15 2010 +0200

    Port to GTK+ 3
```

This week, thanks to a hackathon at work, I was able to begin preparation for porting Sound Juicer to GTK4. I spent some time studying the code base and, while I am not an expert with it, I feel pretty comfortable navigating my way around. I identified two portions of the project that need changing before porting to GTK4.

* Removing the dependency on [libcanberra](https://0pointer.de/lennart/projects/libcanberra/)
* Removing the dependency on [Brasero](https://gitlab.gnome.org/GNOME/brasero)

Both `libcanberra` and Brasero link against GTK3, so in order to port Sound Juicer to GTK4, it became apparently I would have to either drop these two dependencies, or port them to GTK4 first. I opted for the former, since neither project provide extensive or critical functionality. `libcanberra` is used to play a sound notification when CD extraction is complete. `libbrasero-media` is used to detect optical CD-ROM drives.

Initially, I tried to replace `BraseroMediumMonitor` with `GVolumeMonitor` and react to the `drive-changed`, `drive-connected` and `drive-disconnected` signals. That was a fairly straightforward port, but `GDrive` does not expose details about optical drives that Sound Juicer really needs (things like device paths, media availability, audio tracks). I began to integrate `libcdio` in order to discover more CD-specific information about the drives, but found the API cumbersome.

It then occurred to me that GNOME's _Disk Utility_ app can identify optical drives. When I looked into how it gets drive information, discovered a remarkable piece of software called [UDisks](http://storaged.org/doc/udisks2-api/latest/index.html). This daemon exposes a highly detailed D-Bus API that can be used to inspect all sorts of information about system disks, including optical media detection! I dropped the `libcdio` and `GVolumeMontior` approach and started implementing a `UDisksClient`-based solution. This turned out to work exceptionally well; so well that I was able to drop libbrasero-media from the dependency list.

Initially, I replaced all the `libbrasero-media` includes and function calls with equivalent `UDisksClient`-based implementations. The code was messy, but it worked. Going through this initial "find and replace", I was able to quickly identify the patterns of code that `UDisksClient` encourages. This allowed me to consolidate a lot of the `UDisksClient` code into a new `SjDriveMonitor` class. `SjDriveMonitor` emits signals when an optical drive is added, when media in a drive becomes available, or when an optical drive is removed. Internally, `SjDriveMonitor` connects to signals emitted by the `GDBusObjectManager` instance of a `UDisksClient` instance. When a device is added or removed, `SjDriveMonitor` inspects the device and determines whether or not it is an optical drive. It provides and API that the rest of the application can use to get information about a drive or its associated block device. Replacing the "find and replace" code with calls to `SjDriveMonitor` was very straightforward.

Overall, this was an interesting learning project. I discovered UDisks and learned a lot about how to discover disk information on a system. I was successful at removing one of the two obstacles preventing me from porting Sound Juicer to GTK4. The resulting changes can be seen in the [MR](https://gitlab.gnome.org/GNOME/sound-juicer/-/merge_requests/34).

Since there are no flashy screenshots of under-the-hood changes like this, I'll leave a teaser here. This is a UI mockup I did of what a GTK4/libadwaita-based Sound Juicer could look like.

{{< figure src="/images/sound-juicer-ui-mockup.png" >}}
