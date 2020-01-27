/*
  Part of: MMUX Emacs GMP
  Contents: private header file
  Date: Jan 15, 2020

  Abstract

	This header file is for internal definitions.  It must be included by all the
	source files in this package.

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

#ifndef MMUX_EMACS_GMP_INTERNALS_H
#define MMUX_EMACS_GMP_INTERNALS_H 1


/** --------------------------------------------------------------------
 ** Headers.
 ** ----------------------------------------------------------------- */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif
#include "mmux-emacs-gmp.h"
#include <assert.h>
#include <stdio.h>


/** --------------------------------------------------------------------
 ** Preprocessor macros.
 ** ----------------------------------------------------------------- */

/* These error  strings must match the  error symbols defined with  `define-error' in
   the mdoule source file. */
#undef  MMUX_EMACS_GMP_ERROR
#define MMUX_EMACS_GMP_ERROR			"mmux-gmp-error"

#undef  MMUX_EMACS_GMP_ERROR_NO_MEMORY
#define MMUX_EMACS_GMP_ERROR_NO_MEMORY		"mmux-gmp-no-memory-error"

#undef  MMUX_EMACS_GMP_ERROR_STRING_TOO_LONG
#define MMUX_EMACS_GMP_ERROR_STRING_TOO_LONG	"mmux-gmp-string-too-long"


/** --------------------------------------------------------------------
 ** Type definitions.
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

/* ------------------------------------------------------------------ */

typedef __gmp_randstate_struct *	mmux_gmp_randstate_t;


/** --------------------------------------------------------------------
 ** Constants.
 ** ----------------------------------------------------------------- */

/* This is required by GNU Emacs' API. */
mmux_emacs_gmp_decl int  plugin_is_GPL_compatible;


/** --------------------------------------------------------------------
 ** MMUX Emacs generic inline functions.
 ** ----------------------------------------------------------------- */

static inline void *
mmux_get_ptr (emacs_env * env, emacs_value arg)
{
  return env->get_user_ptr(env, arg);
}

static inline intmax_t
mmux_get_int (emacs_env * env, emacs_value arg)
{
  return env->extract_integer(env, arg);
}

static inline double
mmux_get_float (emacs_env * env, emacs_value arg)
{
  return env->extract_float(env, arg);
}

static inline mmux_ulint_t
mmux_get_ulint (emacs_env * env, emacs_value arg)
{
  return ((mmux_ulint_t)(mmux_get_int(env, arg)));
}

static inline mmux_slint_t
mmux_get_slint (emacs_env * env, emacs_value arg)
{
  return ((mmux_slint_t)(mmux_get_int(env, arg)));
}

static inline mmux_ulint_t
mmux_get_uint (emacs_env * env, emacs_value arg)
{
  return ((mmux_uint_t)(mmux_get_int(env, arg)));
}

static inline mmux_sint_t
mmux_get_sint (emacs_env * env, emacs_value arg)
{
  return ((mmux_sint_t)(mmux_get_int(env, arg)));
}

/* ------------------------------------------------------------------ */

static inline emacs_value
mmux_make_nil (emacs_env * env)
{
  return env->intern(env, "nil");
}

static inline emacs_value
mmux_make_true (emacs_env * env)
{
  return env->intern(env, "t");
}

static inline emacs_value
mmux_make_boolean (emacs_env * env, int val)
{
  return ((val)? mmux_make_true(env) : mmux_make_nil(env));
}

static inline emacs_value
mmux_make_int (emacs_env * env, intmax_t arg)
{
  return env->make_integer(env, arg);
}

static inline emacs_value
mmux_make_float (emacs_env * env, double arg)
{
  return env->make_float(env, arg);
}

static inline emacs_value
mmux_make_uint (emacs_env * env, mmux_uint_t arg)
{
  return mmux_make_int(env, arg);
}

static inline emacs_value
mmux_make_sint (emacs_env * env, mmux_sint_t arg)
{
  return mmux_make_int(env, arg);
}

static inline emacs_value
mmux_make_ulint (emacs_env * env, mmux_ulint_t arg)
{
  return mmux_make_int(env, arg);
}

static inline emacs_value
mmux_make_slint (emacs_env * env, mmux_slint_t arg)
{
  return mmux_make_int(env, arg);
}

static inline emacs_value
mmux_make_string (emacs_env * env, char const * strptr, size_t strlen)
{
  return env->make_string(env, strptr, strlen);
}


/** --------------------------------------------------------------------
 ** MMUX Emacs GMP: inline functions.
 ** ----------------------------------------------------------------- */

static inline mpz_ptr
mmux_get_mpz (emacs_env * env, emacs_value arg)
{
  return ((mpz_ptr)(mmux_get_ptr(env, arg)));
}

static inline mpq_ptr
mmux_get_mpq (emacs_env * env, emacs_value arg)
{
  return ((mpq_ptr)(mmux_get_ptr(env, arg)));
}

static inline mpf_ptr
mmux_get_mpf (emacs_env * env, emacs_value arg)
{
  return ((mpf_ptr)(mmux_get_ptr(env, arg)));
}

static inline mp_bitcnt_t
mmux_get_bitcnt (emacs_env * env, emacs_value arg)
{
  return ((mp_bitcnt_t)(env->extract_integer(env, arg)));
}

static inline mp_bitcnt_t
mmux_get_prec (emacs_env * env, emacs_value arg)
{
  return ((mp_bitcnt_t)(env->extract_integer(env, arg)));
}

static inline mp_size_t
mmux_get_size (emacs_env * env, emacs_value arg)
{
  return ((mp_size_t)(env->extract_integer(env, arg)));
}

static inline mmux_gmp_randstate_t
mmux_get_randstate (emacs_env * env, emacs_value arg)
{
  return ((mmux_gmp_randstate_t)(mmux_get_ptr(env, arg)));
}

/* ------------------------------------------------------------------ */

static inline emacs_value
mmux_make_bitcnt (emacs_env * env, mp_bitcnt_t cnt)
{
  return (mmux_make_int(env, (intmax_t)cnt));
}


/** --------------------------------------------------------------------
 ** Function prototypes.
 ** ----------------------------------------------------------------- */

mmux_emacs_gmp_private_decl void
mmux_emacs_gmp_define_functions_from_table (emacs_env * env, module_function_t const * module_functions, int number_of_module_functions);

mmux_emacs_gmp_private_decl void
mmux_emacs_gmp_user_pointer_objects_init (emacs_env * env);

mmux_emacs_gmp_private_decl void
mmux_emacs_gmp_integer_number_functions_init (emacs_env * env);

mmux_emacs_gmp_private_decl void
mmux_emacs_gmp_rational_number_functions_init (emacs_env * env);

mmux_emacs_gmp_private_decl void
mmux_emacs_gmp_floating_point_number_functions_init (emacs_env * env);

mmux_emacs_gmp_private_decl void
mmux_emacs_gmp_miscellaneous_functions_init (emacs_env * env);


/** --------------------------------------------------------------------
 ** Done.
 ** ----------------------------------------------------------------- */

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* MMUX_EMACS_GMP_INTERNALS_H */

/* end of file */
