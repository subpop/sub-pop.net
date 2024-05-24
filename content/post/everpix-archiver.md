+++
title = "Everpix Archiver"
date = 2023-11-03T06:30:53-04:00
+++

A very long time ago, I was a customer of a startup known as Everpix. They had a vision to solve the "photo mess" problem of the time: before cloud storage was readily available, everybody had photos in local libraries. Everpix provided a service that stored all your photos in a single web-based library and provided intelligent sorting and organization. Sadly, they closed down after a couple of years. In retrospect, they were about 10 years ahead of their time. Their idea was sound, but the technology wasn't cost effective at the time. When they shut down, they offered customers the option to download all their photos, which I did. I've kept `everpix.tar` around in my Downloads folder ever since, waiting for the day to unpack it and restore my old photos to a browsable location.

Fast forward 10 years, and many of the features Everpix offered are now built into Apple's iCloud Photo library. I am now undergoing an effort to consolidate all my family photos into iCloud Photos, so the time has come to finally unpack `everpix.tar` and get those old photos uploaded. This has been an interesting journey into digital archeology.

The contents of `everpix.tar` is a SQLite database and a series of Zip archives, partitioning the photos into separate archives by a hexadecimal prefix.

```
metadata.sqlite
photos-00-22.zip
photos-23-45.zip
[...]
```

Within any given `photos-XX-XX.zip` each photo can be found under a directory further partitioning the files: `photos-00-22/00/000045BFA9C.jp2`, `photos-00-22/01/0187346AC34.jp2`, etc. All the photos are JPEG2000 files, and all the metadata about each photo is stored in the SQLite database, rather than in metadata within the file itself.

I began by exploring the `metadata.sqlite` database myself, examining the table schema and contents. It turns out many of the field names related to "id" contain `BLOB` values of varying lengths, 16 and 24 being the most common. I tried all the fields in `photos` and `photo_instances`, and found one that partially matched a file name. This was not looking like it would be an easy thing to script. For each photo, I would have to truncate the filename to the shorter ID length, convert it to binary from hexadecimal, and the find the row with that ID. When I did this for a sample file, I found that it had 3 rows in the `photo_instances` table.

This began to feel like one of those problems that someone else has already solved, so I started searching the Internet for Everpix metadata-related topics. I did not have high expectations. This is a database created by a startup from 10 years ago that lasted only 2 years. I eventually stumbled onto some GitHub repostories from Everpix, including [an HTML page](https://github.com/everpix/everpix.github.io/blob/ccc07bec15109f8dd88013e6102afeb5402fb602/archives.html) describing the database schema. Amazing! I looked over some other repositories in the Everpix organization and found exactly what I needed. It turns out Everpix developers published an [open source version of an Unarchiver tool](https://github.com/everpix/Everpix-Unarchiver). This Mac OS X application would take a `metadata.sqlite` file and convert all the photos from JPEG2000 into JPEG, as well as writing the metadata into the JPEG as Exif tags.

I recently acquired myself a MacBook, so I decided to try and get this application built and running on my M1 MacBook. Xcode immediately opened the project and attempted to configure the project. Unsurprisingly, it didn't work. I looked over the build errors and noticed that it links against some in-tree libraries: `libexiv2` and `libjpeg-turbo` are both bundled as static libraries. Certain these wouldn't build on an ARM MacBook, I removed their paths from the `HEADER_SEARCH_PATHS` and `LIBRARY_SEARCH_PATHS` values. I installed both libraries from MacPorts and added `/opt/local/include` and `/opt/local/lib` to the header and library search paths instead. It also links against Python.framework version 2.7. Modern macOS does not ship Python.framework anymore, but MacPorts saves the day again; I was able to install python2.7, including Python.framework. Updating the search paths entry to replace `$(SYSTEM_LIBRARY_PATH)` with `/opt/local/Library` solved that. Finally, the `MACOSX_DEPLOYMENT_TARGET` value was set to 10.7 (an unsupported value in Xcode today). I updated that to the new minimum, 10.13. After that, it succeeded to build and run!

![everpix-unarchiver.png](/images/everpix-unarchiver.png)

This was a really interesting exploration into an old, obscure part of my personal digital history. I'm very grateful that Everpix Unarchiver was published as source code to GitHub. It would have been a much more arduous path to extracting these photos without this project.
