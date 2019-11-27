---
title: 'Egregious Python Type Violations'
date: '2019-11-26'
type: 'post'
draft: false
---

`requests.exceptions.ConnectionError` inherits from `requests.exceptions.RequestException`,
which in turn inherits from `IOError` which in turn inherits from `EnvironmentError`.
`EnvironmentError` is described as containing a 2-tuple value: on element 0, 
`errno` and on element 1, `strerror` (presumably a string description of the 
error). For example:

```python
try:
    f = open("/foo")
except IOError as e:
    print("errno: %s" % e.errno)
    print("strerror: %s" % e.strerror)
```

However, `requests` seems to take this concept of the 2-tuple errno/strerror pair
to the extreme. Instead of an integer and string, a `ConnectionError` gets as its
pair a `requests.package.urllib3.exceptions.ProtocolError` on element 0 and `None`
on element 1. `ProtocolError` similarly violates the errno/strerror tuple promise,
setting a string on element 0 and a `socket.gaierror` on element 1. Neither
`ConnectionError` nor `ProtocolError` set their `errno` or `strerror` attributes,
so to actually get a string description of a `ConnectionError` returned by `requests`,
we have to access the `args` attribute directly: `e.args[0].args[0]` (or more
cryptically: `e[0][0]`). Don't forget to `except` the inevitable `IndexError`
inside your `except` block for when indexes change out from under you without
warning.