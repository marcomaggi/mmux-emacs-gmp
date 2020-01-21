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
#undef  MMUX_EMAC_GMP_ERROR
#define MMUX_EMAC_GMP_ERROR			"mmux-gmp-error"

#undef  MMUX_EMAC_GMP_ERROR_NO_MEMORY
#define MMUX_EMAC_GMP_ERROR_NO_MEMORY		"mmux-gmp-no-memory-error"

#undef  MMUX_EMAC_GMP_ERROR_STRING_TOO_LONG
#define MMUX_EMAC_GMP_ERROR_STRING_TOO_LONG	"mmux-gmp-string-too-long"

/* ------------------------------------------------------------------ */

#undef  mmux_get_ptr
#define mmux_get_ptr(ENV, ARG)		((ENV)->get_user_ptr((ENV), (ARG)))

#undef  mmux_get_int
#define mmux_get_int(ENV, ARG)		((ENV)->extract_integer((ENV), (ARG)))

#undef  mmux_get_flo
#define mmux_get_flo(ENV, ARG)		((ENV)->extract_float((ENV), (ARG)))
#undef  mmux_get_float
#define mmux_get_float(ENV, ARG)	((ENV)->extract_float((ENV), (ARG)))
#undef  mmux_get_double
#define mmux_get_double(ENV, ARG)	((ENV)->extract_float((ENV), (ARG)))

#undef  mmux_get_ulint
#define mmux_get_ulint(ENV, ARG)	((mmux_ulint_t)(mmux_get_int((ENV), (ARG))))

#undef  mmux_get_slint
#define mmux_get_slint(ENV, ARG)	((mmux_slint_t)(mmux_get_int((ENV), (ARG))))

#undef  mmux_get_uint
#define mmux_get_uint(ENV, ARG)		((mmux_uint_t)(mmux_get_int((ENV), (ARG))))

#undef  mmux_get_sint
#define mmux_get_sint(ENV, ARG)		((mmux_sint_t)(mmux_get_int((ENV), (ARG))))

/* ------------------------------------------------------------------ */

#undef  mmux_make_nil
#define mmux_make_nil(ENV)		((env)->intern((env), "nil"))

#undef  mmux_make_true
#define mmux_make_true(ENV)		((env)->intern((env), "t"))

#undef  mmux_make_int
#define mmux_make_int(ENV, ARG)		((ENV)->make_integer((ENV), (intmax_t)(ARG)))

#undef  mmux_make_float
#define mmux_make_float(ENV, ARG)	((ENV)->make_integer((ENV), (ARG)))

#undef  mmux_make_ulint
#define mmux_make_ulint(ENV, ARG)	(mmux_make_int((ENV), (ARG)))

#undef  mmux_make_slint
#define mmux_make_slint(ENV, ARG)	(mmux_make_int((ENV), (ARG)))

/* ------------------------------------------------------------------ */

#undef  mmux_get_mpz
#define mmux_get_mpz(ENV, ARG)		((mpz_ptr)(mmux_get_ptr((ENV), (ARG))))

#undef  mmux_get_mpq
#define mmux_get_mpq(ENV, ARG)		((mpq_ptr)(mmux_get_ptr((ENV), (ARG))))

#undef  mmux_get_mpf
#define mmux_get_mpf(ENV, ARG)		((mpf_ptr)(mmux_get_ptr((ENV), (ARG))))

#undef  mmux_get_bitcnt
#define mmux_get_bitcnt(ENV, ARG)	((mp_bitcnt_t)((ENV)->extract_integer((ENV), (ARG))))

#undef  mmux_get_prec
#define mmux_get_prec(ENV, ARG)		((mp_prec_t)((ENV)->extract_integer((ENV), (ARG))))


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


/** --------------------------------------------------------------------
 ** Constants.
 ** ----------------------------------------------------------------- */

/* This is required by GNU Emacs' API. */
mmux_emacs_gmp_decl int  plugin_is_GPL_compatible;


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


/** --------------------------------------------------------------------
 ** Done.
 ** ----------------------------------------------------------------- */

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* MMUX_EMACS_GMP_INTERNALS_H */

/* end of file */
