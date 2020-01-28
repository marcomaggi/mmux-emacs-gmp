/*
  Part of: MMUX Emacs modules
  Contents: private header file, generic definitions
  Date: Jan 28, 2020

  Abstract

	This header file is for internal definitions.  It must be included by all the
	source files in  this package.  This file  is not specific for  a package: it
	contains  generic definitions  used by  all the  packages in  the MMUX  Emacs
	project.

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

#ifndef MMUX_EMACS_INTERNALS_H
#define MMUX_EMACS_INTERNALS_H 1


/** --------------------------------------------------------------------
 ** Headers.
 ** ----------------------------------------------------------------- */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif
#include <emacs-module.h>
#include <assert.h>
#include <stdio.h>


/** --------------------------------------------------------------------
 ** Preliminary definitions.
 ** ----------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#endif

/* The macro MMUX_EMACS_UNUSED indicates that a  function, function argument or variable may
   potentially be unused. Usage examples:

   static int unused_function (char arg) MMUX_EMACS_UNUSED;
   int foo (char unused_argument MMUX_EMACS_UNUSED);
   int unused_variable MMUX_EMACS_UNUSED;
*/
#ifdef __GNUC__
#  define MMUX_EMACS_UNUSED		__attribute__((__unused__))
#else
#  define MMUX_EMACS_UNUSED		/* empty */
#endif

#ifndef __GNUC__
#  define __attribute__(...)	/* empty */
#endif

/* I found  the following chunk on  the Net.  (Marco Maggi;  Sun Feb 26,
   2012) */
#if defined _WIN32 || defined __CYGWIN__
#  ifdef BUILDING_DLL
#    ifdef __GNUC__
#      define mmux_emacs_decl		__attribute__((__dllexport__)) extern
#    else
#      define mmux_emacs_decl		__declspec(dllexport) extern
#    endif
#  else
#    ifdef __GNUC__
#      define mmux_emacs_decl		__attribute__((__dllimport__)) extern
#    else
#      define mmux_emacs_decl		__declspec(dllimport) extern
#    endif
#  endif
#  define mmux_emacs_private_decl	extern
#else
#  if __GNUC__ >= 4
#    define mmux_emacs_decl		__attribute__((__visibility__("default"))) extern
#    define mmux_emacs_private_decl	__attribute__((__visibility__("hidden")))  extern
#  else
#    define mmux_emacs_decl		extern
#    define mmux_emacs_private_decl	extern
#  endif
#endif


/** --------------------------------------------------------------------
 ** Preprocessor macros.
 ** ----------------------------------------------------------------- */



/** --------------------------------------------------------------------
 ** MMUX Emacs generic type definitions.
 ** ----------------------------------------------------------------- */

typedef emacs_value function_implementation_t (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void *data);

typedef struct module_function_t	module_function_t;

struct module_function_t {
  char const			* name;
  function_implementation_t	* implementation;
  ptrdiff_t			min_arity;
  ptrdiff_t			max_arity;
  char const			* documentation;
};

/* ------------------------------------------------------------------ */

typedef signed   int		mmux_sint_t;
typedef unsigned int		mmux_uint_t;
typedef signed   long int	mmux_slint_t;
typedef unsigned long int	mmux_ulint_t;


/** --------------------------------------------------------------------
 ** Constants.
 ** ----------------------------------------------------------------- */

/* This is required by GNU Emacs' API. */
mmux_emacs_decl int  plugin_is_GPL_compatible;


/** --------------------------------------------------------------------
 ** MMUX Emacs generic inline functions: argument getters.
 ** ----------------------------------------------------------------- */

static inline void *
mmux_emacs_get_ptr (emacs_env * env, emacs_value arg)
{
  return env->get_user_ptr(env, arg);
}

static inline intmax_t
mmux_emacs_get_int (emacs_env * env, emacs_value arg)
{
  return env->extract_integer(env, arg);
}

static inline double
mmux_emacs_get_float (emacs_env * env, emacs_value arg)
{
  return env->extract_float(env, arg);
}

static inline mmux_ulint_t
mmux_emacs_get_ulint (emacs_env * env, emacs_value arg)
{
  return ((mmux_ulint_t)(mmux_emacs_get_int(env, arg)));
}

static inline mmux_slint_t
mmux_emacs_get_slint (emacs_env * env, emacs_value arg)
{
  return ((mmux_slint_t)(mmux_emacs_get_int(env, arg)));
}

static inline mmux_ulint_t
mmux_emacs_get_uint (emacs_env * env, emacs_value arg)
{
  return ((mmux_uint_t)(mmux_emacs_get_int(env, arg)));
}

static inline mmux_sint_t
mmux_emacs_get_sint (emacs_env * env, emacs_value arg)
{
  return ((mmux_sint_t)(mmux_emacs_get_int(env, arg)));
}


/** --------------------------------------------------------------------
 ** MMUX Emacs generic inline functions: object makers.
 ** ----------------------------------------------------------------- */

static inline emacs_value
mmux_emacs_make_nil (emacs_env * env)
{
  return env->intern(env, "nil");
}

static inline emacs_value
mmux_emacs_make_true (emacs_env * env)
{
  return env->intern(env, "t");
}

static inline emacs_value
mmux_emacs_make_boolean (emacs_env * env, int val)
{
  return ((val)? mmux_emacs_make_true(env) : mmux_emacs_make_nil(env));
}

static inline emacs_value
mmux_emacs_make_int (emacs_env * env, intmax_t arg)
{
  return env->make_integer(env, arg);
}

static inline emacs_value
mmux_emacs_make_float (emacs_env * env, double arg)
{
  return env->make_float(env, arg);
}

static inline emacs_value
mmux_emacs_make_uint (emacs_env * env, mmux_uint_t arg)
{
  return mmux_emacs_make_int(env, (intmax_t)arg);
}

static inline emacs_value
mmux_emacs_make_sint (emacs_env * env, mmux_sint_t arg)
{
  return mmux_emacs_make_int(env, (intmax_t)arg);
}

static inline emacs_value
mmux_emacs_make_ulint (emacs_env * env, mmux_ulint_t arg)
{
  return mmux_emacs_make_int(env, (intmax_t)arg);
}

static inline emacs_value
mmux_emacs_make_slint (emacs_env * env, mmux_slint_t arg)
{
  return mmux_emacs_make_int(env, (intmax_t)arg);
}

static inline emacs_value
mmux_emacs_make_string (emacs_env * env, char const * strptr, size_t strlen)
{
  return env->make_string(env, strptr, strlen);
}


/** --------------------------------------------------------------------
 ** Done.
 ** ----------------------------------------------------------------- */

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* MMUX_EMACS_INTERNALS_H */

/* end of file */
