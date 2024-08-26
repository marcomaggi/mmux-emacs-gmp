# @configure_input@
#

AC_PREREQ([2.69])
MMUX_PKG_VERSIONS([0],[1],[0],[devel.1])
AC_INIT([MMUX Emacs GMP],[MMUX_PACKAGE_VERSION],
  [mrc.mgg@gmail.com],
  [mmux-emacs-gmp],[http://github.com/marcomaggi/mmux-emacs-gmp])
MMUX_INIT
MMUX_LIBTOOL_LIBRARY_VERSIONS([mmux_emacs_gmp],1,0,0)
AC_REVISION([0.1])
AC_COPYRIGHT([Copyright (c) 2020, 2024 Marco Maggi <mrc.mgg@gmail.com>

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
])
AC_CONFIG_SRCDIR([src/])
AC_CONFIG_MACRO_DIR([meta/autotools])
AC_CONFIG_AUX_DIR([meta/autotools])
AC_CANONICAL_BUILD
AC_CANONICAL_HOST
AC_CANONICAL_TARGET
AM_INIT_AUTOMAKE([1.16 foreign subdir-objects])
AM_MAINTAINER_MODE

AM_PROG_AR
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_MKDIR_P

AX_PROG_EMACS
AM_PATH_LISPDIR
AC_CHECK_HEADER([emacs-module.h],,[AC_MSG_ERROR([missing emacs-module.h],1)])

LT_PREREQ([2.4])
LT_INIT


#### basic system inspection

MMUX_CHECK_TARGET_OS
AX_IS_RELEASE([git-directory])

AC_LANG([C])
MMUX_LANG_C11

AM_PROG_AS
AM_PROG_CC_C_O
AC_HEADER_STDC
AC_HEADER_SYS_WAIT
AC_CHECK_HEADERS([assert.h stdint.h strings.h errno.h])

AC_CACHE_SAVE


#### external libraries

PKG_PREREQ([0.29])
PKG_INSTALLDIR
MMUX_CHECK_PKG_CONFIG_MACROS

AC_CHECK_HEADERS([gmp.h],,[AC_MSG_ERROR([Cannot find libgmp.])])
AC_CHECK_LIB([gmp],[__gmpn_add],,[AC_MSG_ERROR([Cannot find libgmp.])])

AC_CACHE_SAVE


#### finish

AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([Makefile]
   [meta/scripts/mmux-emacs-gmp.pc]
   [meta/slackware/slack-desc])
MMUX_OUTPUT
AC_OUTPUT

### end of file
