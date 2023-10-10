+++
title = "Go 'pkg' antipattern"
date = 2023-10-10T11:25:56-04:00
+++

I've [written previously](/post/go-package-organization) about organizing Go
project files. I have observed a trend in Go package organization that strikes
me as a clear anti-pattern to project organization. Working under the assertion
that Go packages should be useful when imported by themselves, the usage of a
'pkg' directory is a clear anti-pattern. Remember the top-level of a Go project
_is_ the root of your API. If you want your package to be imported with a path
such as "github.com/subpop/foo", all your code files must exist in the root of
the repository. Let's assume you create a "pkg" directory in your repository and
move your code files into it. Now, consumers of your module will import it as:

```go
import "github.com/subpop/foo/pkg"
```

And using it becomes more puzzling. Is the package identifier now "pkg"? Or is
it still "foo"? We've now introduced ambiguity for the sake of file
organization? Is that a cost worth putting on consumers of your package?

"But no one puts code into 'pkg'; it's just for subpackages" you say. This adds
needless elements to the import path. Let's assume you have a couple of packages
that you want to export as part of your module's public API, but they're [useful
enough in isolation](/post/go-package-organization) to bundle into a package.
You saw a Github repository claiming to be a "golang-standard". That repository
has a "pkg" subdirectory, so it must be okay, right?

If your repository looks like this:
```
.
./pkg
./pkg/djset
./pkg/pqueue
./pkg/queue
./pkg/stack
```

When importing these packages, your imports end up looking like:

```go
import (
    "github.com/subpop/foo/pkg/djset"
    "github.com/subpop/foo/pkg/pqueue"
    "github.com/subpop/foo/pkg/queue"
    "github.com/subpop/foo/pkg/stack"
)
```

This is frivolous. There's no advantage to making your package consumers
needlessly type "pkg" repeatedly. Drop the "pkg" and your import paths become
much more meaningful:

```go
import (
    "github.com/subpop/foo/djset"
    "github.com/subpop/foo/pqueue"
    "github.com/subpop/foo/queue"
    "github.com/subpop/foo/stack"
)
```

The
[golang-standards/project-layout](https://github.com/golang-standards/project-layout)
cautions readers against unnecessary use of a "pkg" directory. I say go one step
further and just don't use it at all.
