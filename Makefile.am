## Process this file with automake to produce Makefile.in

ACLOCAL_AMFLAGS		= -I meta/autotools
AUTOMAKE_OPTIONS	= foreign
EXTRA_DIST		= INSTALL			\
			  meta/slackware/slack-desc.in
dist_doc_DATA		= README COPYING
AM_CFLAGS		= $(MMUX_CFLAGS)
AM_CPPFLAGS		= -I$(srcdir)/src
CLEANFILES		=

## --------------------------------------------------------------------

nodist_pkgconfig_DATA	= meta/scripts/mmux-emacs-gmp.pc


#### documentation

EXTRA_DIST		+= doc/mmux-emacs-gmp.style.css
CLEANFILES		+= doc/mmux-emacs-gmp.css

AM_MAKEINFOFLAGS	= --no-split
AM_MAKEINFOHTMLFLAGS	= --split=node -c WORDS_IN_PAGE=0 --css-ref=mmux-emacs-gmp.css \
	-c PRE_BODY_CLOSE="<p>This document describes version <tt>$(PACKAGE_VERSION)</tt> of <em>$(PACKAGE_NAME)</em>.</p>"

info_TEXINFOS		= doc/mmux-emacs-gmp.texi
doc_mmux_emacs_gmp_TEXINFOS = \
	doc/macros.texi			\
	doc/elisp-macros.texi		\
	doc/overview-linking.texi	\
	doc/gpl-3.0.texi		\
	doc/fdl-1.3.texi

## --------------------------------------------------------------------

doc/mmux-emacs-gmp.html/$(am__dirstamp): doc/$(am__dirstamp)
	@$(MKDIR_P) doc/mmux-emacs-gmp.html/
	@: > doc/mmux-emacs-gmp.html/$(am__dirstamp)

doc/mmux-emacs-gmp.html/mmux-emacs-gmp.css: doc/mmux-emacs-gmp.style.css doc/mmux-emacs-gmp.html/$(am__dirstamp)
	$(INSTALL) -m 0444 "$(top_srcdir)/doc/mmux-emacs-gmp.style.css" "$(builddir)/doc/mmux-emacs-gmp.html/mmux-emacs-gmp.css"

## --------------------------------------------------------------------

html-local: doc/mmux-emacs-gmp.html/mmux-emacs-gmp.css

install-html-local:
	$(MKDIR_P) "$(DESTDIR)$(htmldir)/mmux-emacs-gmp.html/"
	$(INSTALL) -m 0444 $(builddir)/doc/mmux-emacs-gmp.html/mmux-emacs-gmp.css "$(DESTDIR)$(htmldir)/mmux-emacs-gmp.html/"


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
	src/mmux-emacs-internals.h			\
	src/mmux-emacs-gmp-internals.h			\
	src/mmux-emacs-gmp-library.c			\
	src/mmux-emacs-gmp-user-pointer-objects.c	\
	src/mmux-emacs-gmp-integer-numbers.c		\
	src/mmux-emacs-gmp-rational-numbers.c		\
	src/mmux-emacs-gmp-floating-point-numbers.c	\
	src/mmux-emacs-gmp-miscellaneous.c


#### Emacs code

# This  variable is  reserved to  the  package author.   Users of  the
# package can set ELCFLAGS.
AM_ELCFLAGS	= --quick --directory $(builddir)/src --directory $(PWD)/.libs

dist_lisp_LISP	= src/gmp.el

src/gmp.elc: libmmux-emacs-gmp.la


#### tests

MMUX_EMACS_GMP_TESTS_SRC = \
	tests/version.el			\
	tests/user-pointer-objects.el		\
	tests/integer-numbers.el		\
	tests/rational-numbers.el		\
	tests/floating-point-numbers.el		\
	tests/random-numbers-generators.el

MMUX_EMACS_GMP_TESTS = \
	tests/version.elc			\
	tests/user-pointer-objects.elc		\
	tests/integer-numbers.elc		\
	tests/rational-numbers.elc		\
	tests/floating-point-numbers.elc	\
	tests/random-numbers-generators.elc

EXTRA_DIST	+= $(MMUX_EMACS_GMP_TESTS_SRC)
TESTS		 = $(MMUX_EMACS_GMP_TESTS)

# We must make sure that this ends with a semicolon!!!
AM_TESTS_ENVIRONMENT	=
TEST_EXTENSIONS		= .elc
ELC_LOG_COMPILER	= $(EMACS)
AM_ELC_LOG_FLAGS	= --batch --quick --directory $(builddir)/.libs --directory $(builddir)/src --load
CLEANFILES		+= $(MMUX_EMACS_GMP_TESTS)

.PHONY: test

## --------------------------------------------------------------------

MMUX_EMACS_INSTALLCHECK	= $(EMACS) --batch --quick --directory $(libdir) --directory $(lispdir) --load

installcheck-local:
	@for f in $(MMUX_EMACS_GMP_TESTS_SRC); do $(MMUX_EMACS_INSTALLCHECK) $(srcdir)/$$f; done

## --------------------------------------------------------------------

MMUX_EMACS_GMP_TEST_SELECTED_TESTS	= $(srcdir)/tests/*$(file)*.el
MMUX_EMACS_GMP_TEST_RUNTESTS		= $(EMACS) --batch --quick --directory $(builddir)/.libs --directory $(builddir)/src --load

test:
	for f in $(MMUX_EMACS_GMP_TEST_SELECTED_TESTS) ; do $(MMUX_EMACS_GMP_TEST_RUNTESTS) $$f; done


#### common rules

include $(top_srcdir)/meta/automake/mmux-makefile-rules

### end of file
