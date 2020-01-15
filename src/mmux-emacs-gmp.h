/*
  Part of: MMUX Emacs GMP
  Contents: public header file
  Date: Jan 15, 2020

  Abstract

	This is the public  header file of the library, defining  the public API.  It
	must be included in all the code that uses the library.

  Copyright (C) 2020 Marco Maggi <mrc.mgg@gmail.com>

  This program is free  software: you can redistribute it and/or  modify it under the
  terms  of  the  GNU General  Public  License  as  published  by the  Free  Software
  Foundation, either version 3 of the License, or (at your option) any later version.

  This program  is distributed in the  hope that it  will be useful, but  WITHOUT ANY
  WARRANTY; without  even the implied  warranty of  MERCHANTABILITY or FITNESS  FOR A
  PARTICULAR PURPOSE.  See the GNU General Public License for more details.

  You should have received  a copy of the GNU General Public  License along with this
  program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef MMUX_EMACS_GMP_H
#define MMUX_EMACS_GMP_H 1


/** --------------------------------------------------------------------
 ** Preliminary definitions.
 ** ----------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#endif

/* The macro MMUX_EMACS_GMP_UNUSED indicates that a  function, function argument or variable may
   potentially be unused. Usage examples:

   static int unused_function (char arg) MMUX_EMACS_GMP_UNUSED;
   int foo (char unused_argument MMUX_EMACS_GMP_UNUSED);
   int unused_variable MMUX_EMACS_GMP_UNUSED;
*/
#ifdef __GNUC__
#  define MMUX_EMACS_GMP_UNUSED		__attribute__((__unused__))
#else
#  define MMUX_EMACS_GMP_UNUSED		/* empty */
#endif

#ifndef __GNUC__
#  define __attribute__(...)	/* empty */
#endif

/* I found  the following chunk on  the Net.  (Marco Maggi;  Sun Feb 26,
   2012) */
#if defined _WIN32 || defined __CYGWIN__
#  ifdef BUILDING_DLL
#    ifdef __GNUC__
#      define mmux_emacs_gmp_decl		__attribute__((__dllexport__)) extern
#    else
#      define mmux_emacs_gmp_decl		__declspec(dllexport) extern
#    endif
#  else
#    ifdef __GNUC__
#      define mmux_emacs_gmp_decl		__attribute__((__dllimport__)) extern
#    else
#      define mmux_emacs_gmp_decl		__declspec(dllimport) extern
#    endif
#  endif
#  define mmux_emacs_gmp_private_decl	extern
#else
#  if __GNUC__ >= 4
#    define mmux_emacs_gmp_decl		__attribute__((__visibility__("default"))) extern
#    define mmux_emacs_gmp_private_decl	__attribute__((__visibility__("hidden")))  extern
#  else
#    define mmux_emacs_gmp_decl		extern
#    define mmux_emacs_gmp_private_decl	extern
#  endif
#endif


/** --------------------------------------------------------------------
 ** Headers.
 ** ----------------------------------------------------------------- */

/* Enable latest POSIX features. */
#define _POSIX_C_SOURCE		200809L

#if 0
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <stddef.h> /* for offsetof() */
#include <setjmp.h>
#include <errno.h>
#include <unistd.h>
#endif

#include <emacs-module.h>


/** --------------------------------------------------------------------
 ** Constants and preprocessor macros.
 ** ----------------------------------------------------------------- */

#define MMUX_EMACS_GMP_PC(POINTER_TYPE, POINTER_NAME, EXPRESSION)	\
  POINTER_TYPE * POINTER_NAME = (POINTER_TYPE *) (EXPRESSION)


/** --------------------------------------------------------------------
 ** Version functions.
 ** ----------------------------------------------------------------- */

mmux_emacs_gmp_decl char const *	mmux_emacs_gmp_version_string		(void);
mmux_emacs_gmp_decl int		mmux_emacs_gmp_version_interface_current	(void);
mmux_emacs_gmp_decl int		mmux_emacs_gmp_version_interface_revision	(void);
mmux_emacs_gmp_decl int		mmux_emacs_gmp_version_interface_age	(void);


/** --------------------------------------------------------------------
 ** Done.
 ** ----------------------------------------------------------------- */

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* MMUX_EMACS_GMP_H */

/* end of file */
