---
title: "Connecting to the IRCCloud bouncer using Polari (or any Telepathy-based client)"
date: 2020-07-10T07:22:06-04:00
categories: ["Linux"]
tags: ["telepathy", "irc", "mission control", "mc-tool", "polari", "bnc", "bouncer"]
---

Polari is my preferred IRC client. Its dead-simple interface makes it the
perfect choice for a client to avoid all the embedded images and animations that
riddle chat platforms these days.

IRCCloud is a excellent service that modernizes IRC with some features that are
nice to have in an IRC client (persistent connections, message history).

On top of that IRCCloud offers a bouncer to which other clients can connect.
Getting Polari connected to the IRCCloud bouncer isn't straightforward however.
The new connection UI in Polari doesn't expose the required fields that 
Telepathy requires in order to connect to the bouncer. To do this, we have to
drop down to `mc-tool` to add the connections.

`mc-tool` has a pretty easy interface to get the hang of, but I thought future
self (and anyone else who hits this page using web searches) might find these
complete examples helpful.

```
mc-tool add idle/irc <display-name> string:account=<nickname> string:server=bnc.irccloud.com string:username=<nickname> string:password=bnc@XXXXXXXXXXXXXXXXXXXXXX bool:use-ssl=true uint:port=6697 bool:password-prompt=false
```
