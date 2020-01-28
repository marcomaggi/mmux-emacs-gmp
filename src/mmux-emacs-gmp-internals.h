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

#include "mmux-emacs-internals.h"
#include "mmux-emacs-gmp.h"


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
 ** MMUX Emacs GMP type definitions.
 ** ----------------------------------------------------------------- */

typedef __gmp_randstate_struct *	mmux_gmp_randstate_t;


/** --------------------------------------------------------------------
 ** Constants.
 ** ----------------------------------------------------------------- */



/** --------------------------------------------------------------------
 ** MMUX Emacs GMP: inline functions.
 ** ----------------------------------------------------------------- */

static inline mpz_ptr
mmux_emacs_get_gmp_mpz (emacs_env * env, emacs_value arg)
{
  return ((mpz_ptr)(mmux_emacs_get_ptr(env, arg)));
}

static inline mpq_ptr
mmux_emacs_get_gmp_mpq (emacs_env * env, emacs_value arg)
{
  return ((mpq_ptr)(mmux_emacs_get_ptr(env, arg)));
}

static inline mpf_ptr
mmux_emacs_get_gmp_mpf (emacs_env * env, emacs_value arg)
{
  return ((mpf_ptr)(mmux_emacs_get_ptr(env, arg)));
}

static inline mp_bitcnt_t
mmux_emacs_get_gmp_bitcnt (emacs_env * env, emacs_value arg)
{
  return ((mp_bitcnt_t)(env->extract_integer(env, arg)));
}

static inline mp_bitcnt_t
mmux_emacs_get_gmp_prec (emacs_env * env, emacs_value arg)
{
  return ((mp_bitcnt_t)(env->extract_integer(env, arg)));
}

static inline mp_size_t
mmux_emacs_get_gmp_size (emacs_env * env, emacs_value arg)
{
  return ((mp_size_t)(env->extract_integer(env, arg)));
}

static inline mp_exp_t
mmux_emacs_get_gmp_exp (emacs_env * env, emacs_value arg)
{
  return ((mp_exp_t)(env->extract_integer(env, arg)));
}

static inline mmux_gmp_randstate_t
mmux_emacs_get_gmp_randstate (emacs_env * env, emacs_value arg)
{
  return ((mmux_gmp_randstate_t)(mmux_emacs_get_ptr(env, arg)));
}

/* ------------------------------------------------------------------ */

static inline emacs_value
mmux_emacs_make_gmp_bitcnt (emacs_env * env, mp_bitcnt_t cnt)
{
  return mmux_emacs_make_int(env, (intmax_t)cnt);
}

static inline emacs_value
mmux_emacs_make_gmp_prec (emacs_env * env, mp_bitcnt_t cnt)
{
  return mmux_emacs_make_int(env, (intmax_t)cnt);
}

static inline emacs_value
mmux_emacs_make_gmp_mp_exp (emacs_env * env, mp_exp_t exponent)
{
  return mmux_emacs_make_int(env, (intmax_t)exponent);
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
