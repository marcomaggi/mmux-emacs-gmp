# @configure_input@
#

AC_PREREQ([2.69])
MMUX_PKG_VERSIONS([0],[1],[0],[devel.0])
AC_INIT([MMUX Emacs GMP],[MMUX_PACKAGE_VERSION],
  [mrc.mgg@gmail.com],
  [mmux-emacs-gmp],[http://github.com/marcomaggi/mmux-emacs-gmp])
MMUX_INIT
MMUX_LIBTOOL_LIBRARY_VERSIONS([mmux_emacs_gmp],1,0,0)
AC_REVISION([0.1])
AC_COPYRIGHT([Copyright (c) 2020 Marco Maggi <mrc.mgg@gmail.com>

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
AC_CHECK_HEADERS([assert.h stdint.h strings.h errno.h stddef.h unistd.h])

dnl AC_CHECK_SIZEOF(void *)
dnl AC_C_CONST
dnl AC_C_INLINE
dnl AC_C_RESTRICT
dnl AC_TYPE_LONG_LONG_INT
dnl AC_TYPE_UNSIGNED_LONG_LONG_INT
dnl AC_TYPE_SIZE_T
dnl AC_TYPE_SSIZE_T
dnl AC_TYPE_INT8_T
dnl AC_TYPE_INT16_T
dnl AC_TYPE_INT32_T
dnl AC_TYPE_INT64_T
dnl AC_TYPE_UINT8_T
dnl AC_TYPE_UINT16_T
dnl AC_TYPE_UINT32_T
dnl AC_TYPE_UINT64_T

dnl MMUX_CHECK_PAGE_SIZE
dnl MMUX_CHECK_PAGE_SHIFT($mmux_cv_page_size)

dnl MMUX_DETERMINE_SIZEOF([SIZE_T],[size_t],[MMUX_INCLUDE_STDDEF_H])
dnl MMUX_DETERMINE_SIZEOF([SSIZE_T],[ssize_t],[MMUX_INCLUDE_UNISTD_H])
dnl MMUX_DETERMINE_SIZEOF([PTRDIFF_T],[ptrdiff_t],[MMUX_INCLUDE_STDDEF_H])

dnl AC_LANG([C++])
dnl AC_PROG_CXX

AC_CACHE_SAVE


#### checks for library functions

dnl AC_FUNC_MALLOC
dnl AC_FUNC_MEMCMP
dnl AC_CHECK_FUNCS([memmove memset strerror])
dnl AC_CHECK_FUNCS([mmap munmap msync mremap madvise mlock munlock mlockall munlockall mprotect])
dnl AC_CHECK_FUNCS([getenv])

dnl AC_CACHE_SAVE


#### external libraries

PKG_PREREQ([0.29])
PKG_INSTALLDIR
MMUX_CHECK_PKG_CONFIG_MACROS

dnl PKG_CHECK_MODULES([GSL],[gsl >= 1.16],[gsl=yes],[gsl=no])
dnl GSL_CPPFLAGS=$(pkg-config gsl --cflags)
dnl GSL_LDFLAGS=$(pkg-config gsl --libs)

dnl AC_CHECK_HEADERS([gmp.h],,[AC_MSG_ERROR([Cannot find libgmp.])])
dnl AC_CHECK_LIB([gmp],[__gmpn_add],,[AC_MSG_ERROR([Cannot find libgmp.])])

AC_CACHE_SAVE


#### finish

AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([Makefile]
   [meta/scripts/mmux-emacs-gmp.pc]
   [meta/slackware/slack-desc])
MMUX_OUTPUT
AC_OUTPUT

### end of file
