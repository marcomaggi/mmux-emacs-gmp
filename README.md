# MMUX Emacs GMP

## Introduction

This package  provides a  dynamic module for  GNU Emacs  implementing an
interface to the GMP library on top of a C11 language library.

The library targets  POSIX systems.  This package is meant  to work with
GNU Emacs version 26+ and GMP version 6.2.0+.  This package depends upon
the  external packages:  cl-lib.  To  run the  test suite:  this package
requires the ERT package.

The  package uses  the GNU  Autotools and  it is  tested on  a GNU+Linux
system.  The  package relies  on `pkg-config`  to find  the dependencies
installed on the system.

  Here is a usage snippet:

```
(require 'gmp)

(let ((rop      (mpf))
      (op1      (mpf 1.2))
      (op2      (mpf 3.4)))
  (mpf-add rop op1 op2)
  (let ((base           10)
        (ndigits        17))
    (mpf-get-str* base ndigits rop)))
=> "+0.45999999999999999e+1"
```

## License

Copyright (c) 2020, 2024 Marco Maggi<br/>
`mrc.mgg@gmail.com`<br/>
All rights reserved.

This program is free software: you  can redistribute it and/or modify it
under the  terms of the GNU  General Public License as  published by the
Free Software Foundation,  either version 3 of the License,  or (at your
option) any later version.

This program  is distributed  in the  hope that it  will be  useful, but
WITHOUT   ANY   WARRANTY;  without   even   the   implied  warranty   of
MERCHANTABILITY  or  FITNESS FOR  A  PARTICULAR  PURPOSE.  See  the  GNU
General Public License for more details.

You should have received a copy  of the GNU General Public License along
with this program.  If not, see <http://www.gnu.org/licenses/>.

## Install

First make sure that your GNU Emacs installation has enabled support for
dynamic modules.   Check the elisp variable  `module-file-suffix': if it
is set to nil, modules are disabled and we need to rebuild and reinstall
the GNU Emacs package.

To install from a proper release tarball, do this:

```
$ cd mmux-emacs-gmp-0.1.0
$ mkdir build
$ cd build
$ ../configure
$ make
$ make check
$ make install
```

to inspect the available configuration options:

```
$ ../configure --help
```

The Makefile is designed to allow parallel builds, so we can do:

```
$ make -j4 all && make -j4 check
```

which,  on  a  4-core  CPU,   should  speed  up  building  and  checking
significantly.

The Makefile supports the DESTDIR  environment variable to install files
in a temporary location, example: to see what will happen:

```
$ make -n install DESTDIR=/tmp/mmux-emacs-gmp
```

to really do it:

```
$ make install DESTDIR=/tmp/mmux-emacs-gmp
```

After the  installation it is  possible to verify the  installed library
against the test suite with:

```
$ make installcheck
```

From a repository checkout or snapshot  (the ones from the Github site):
we  must install  the GNU  Autotools  (GNU Automake,  GNU Autoconf,  GNU
Libtool), then  we must first run  the script `autogen.sh` from  the top
source directory, to generate the needed files:

```
$ cd mmux-emacs-gmp
$ sh autogen.sh

```

notice  that  `autogen.sh`  will   run  the  programs  `autoreconf`  and
`libtoolize`; the  latter is  selected through the  environment variable
`LIBTOOLIZE`,  whose  value  can  be  customised;  for  example  to  run
`glibtoolize` rather than `libtoolize` we do:

```
$ LIBTOOLIZE=glibtoolize sh autogen.sh
```

After this  the procedure  is the same  as the one  for building  from a
proper release tarball, but we have to enable maintainer mode:

```
$ ../configure --enable-maintainer-mode [options]
$ make
$ make check
$ make install
```

The C language shared library is installed under `$libdir`, for example:

```
/usr/local/lib64
```

while the Emacs code goes under `$lispdir`, for example:

```
/usr/local/share/emacs/site-lisp
```

so to load the module we should do something like:

```
(add-to-list 'load-path "/usr/local/lib64"
                        "/usr/local/share/emacs/site-lisp")
(require gmp)
```

## Usage

Read the documentation generated from  the Texinfo sources.  The package
installs the documentation  in Info format; we can  generate and install
documentation in HTML format by running:

```
$ make html
$ make install-html
```

## Credits

The  stuff was  written by  Marco Maggi.   If this  package exists  it's
because of the great GNU software tools that he uses all the time.

## Bugs, vulnerabilities and contributions

Bug  and vulnerability  reports are  appreciated, all  the vulnerability
reports  are  public; register  them  using  the  Issue Tracker  at  the
project's GitHub  site.  For  contributions and  patches please  use the
Pull Requests feature at the project's GitHub site.

## Resources

The latest release of this package can be downloaded from:

[https://bitbucket.org/marcomaggi/mmux-emacs-gmp/downloads](https://bitbucket.org/marcomaggi/mmux-emacs-gmp/downloads)

development takes place at:

[http://github.com/marcomaggi/mmux-emacs-gmp/](http://github.com/marcomaggi/mmux-emacs-gmp/)

and as backup at:

[https://bitbucket.org/marcomaggi/mmux-emacs-gmp/](https://bitbucket.org/marcomaggi/mmux-emacs-gmp/)

the documentation is available online:

[http://marcomaggi.github.io/docs/mmux-emacs-gmp.html](http://marcomaggi.github.io/docs/mmux-emacs-gmp.html)

the GNU Project software can be found here:

[http://www.gnu.org/](http://www.gnu.org/)

we can find GMP here:

[https://gmplib.org/](https://gmplib.org/)

