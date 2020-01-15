## Process this file with automake to produce Makefile.in

ACLOCAL_AMFLAGS		= -I meta/autotools
AUTOMAKE_OPTIONS	= foreign
EXTRA_DIST		= INSTALL			\
			  meta/slackware/slack-desc.in
dist_doc_DATA		= README COPYING
AM_CFLAGS		= $(MMUX_CFLAGS)
AM_CPPFLAGS		= -I$(srcdir)/src

## --------------------------------------------------------------------

nodist_pkgconfig_DATA	= meta/scripts/mmux-emacs-gmp.pc


#### documentation

AM_MAKEINFOFLAGS	= --no-split
AM_MAKEINFOHTMLFLAGS	= --split=node -c WORDS_IN_PAGE=0 \
	-c PRE_BODY_CLOSE="<p>This document describes version <tt>$(PACKAGE_VERSION)</tt> of <em>$(PACKAGE_NAME)</em>.</p>"

info_TEXINFOS		= doc/mmux-emacs-gmp.texi
doc_mmux_emacs_gmp_TEXINFOS = \
	doc/macros.texi			\
	doc/overview-linking.texi	\
	doc/gpl-3.0.texi		\
	doc/fdl-1.3.texi


#### libraries

mmux_emacs_gmp_CURRENT		= @mmux_emacs_gmp_VERSION_INTERFACE_CURRENT@
mmux_emacs_gmp_REVISION		= @mmux_emacs_gmp_VERSION_INTERFACE_REVISION@
mmux_emacs_gmp_AGE			= @mmux_emacs_gmp_VERSION_INTERFACE_AGE@
mmux_emacs_gmp_LINKER_VERSION	= -version-info $(mmux_emacs_gmp_CURRENT):$(mmux_emacs_gmp_REVISION):$(mmux_emacs_gmp_AGE)

include_HEADERS		= src/mmux-emacs-gmp.h

lib_LTLIBRARIES		= libmmux-emacs-gmp.la
libmmux_emacs_gmp_la_CPPFLAGS	= $(AM_CPPFLAGS)
libmmux_emacs_gmp_la_CFLAGS	= $(AM_CFLAGS)
libmmux_emacs_gmp_la_LDFLAGS	= $(mmux_emacs_gmp_LINKER_VERSION) $(AM_LDFLAGS)
libmmux_emacs_gmp_la_SOURCES	= \
	src/mmux-emacs-gmp.h				\
	src/mmux-emacs-gmp-internals.h			\
	src/mmux-emacs-gmp-library.c			\
	src/mmux-emacs-gmp-user-pointer-objects.c	\
	src/mmux-emacs-gmp-integer-functions.c


#### Emacs code

# This  variable is  reserved to  the  package author.   Users of  the
# package can set ELCFLAGS.
AM_ELCFLAGS	= --quick --directory $(PWD)/.libs

dist_lisp_LISP	= src/mmux-emacs-gmp.el

src/mmux-emacs-gmp.elc: libmmux-emacs-gmp.la


#### tests

MMUX_EMACS_GMP_TESTS = \
	tests/version.el		\
	tests/user-pointer-objects.el	\
	tests/integer-functions.el

EXTRA_DIST	+= $(MMUX_EMACS_GMP_TESTS)
TESTS		 = $(MMUX_EMACS_GMP_TESTS)

# We must make sure that this ends with a semicolon!!!
AM_TESTS_ENVIRONMENT	=
TEST_EXTENSIONS		= .el
EL_LOG_COMPILER		= $(EMACS)
AM_EL_LOG_FLAGS		= --batch --quick --directory $(builddir)/.libs --directory $(builddir)/src -l

## --------------------------------------------------------------------

MMUX_EMACS_INSTALLCHECK	= $(EMACS) --batch --quick --directory $(libdir) --directory $(lispdir) -l

installcheck-local: $(TESTS)
	@for f in $(TESTS); do $(MMUX_EMACS_INSTALLCHECK) $(srcdir)/$$f; done


#### common rules

include $(top_srcdir)/meta/automake/mmux-makefile-rules

### end of file
