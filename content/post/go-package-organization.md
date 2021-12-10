+++
title = "Go package organization"
date = 2021-12-10T15:10:53-05:00
+++

There are numerous blog posts and articles on the topic of how to organize Go
projects, but nearly all of them have missed the point: Go is already telling you how
to organize your project. Go doesn't want you to organize your source code files
by any sort of taxonomy; it wants you to organize your source code files by
usefulness.

Let's start with some things you already know. Within a Go project, all your
code lives under the top-level module path. Conventionally, this is a "go
get"-able repository name like "github.com/subpop/foo". A module also includes a
top-level package name, such as "foo" (or "main" if the project is a program).
All Go source code files within this directory must have the same package
identifier. It is possible to create additional packages within your module by
creating a directory and putting Go source code files in that directory.
Likewise, these files must also all have the same package identifier. In this
way, Go packages are like tiny, embedded libraries that exist inside your
project.

And therein lies the answer. Go packages exist because they are useful not only
to the project they exist in, but also to external projects; that's why they
exist as a separate package, importable under a separate import path. A Go
package should be useful when imported by itself. If you find that your package
is only useful if you also import its parent package, then it should not exist
as a separate package.
