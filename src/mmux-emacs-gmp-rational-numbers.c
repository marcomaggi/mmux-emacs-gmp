/*
  Part of: MMUX Emacs GMP
  Contents: rational number functions
  Date: Jan 16, 2020

  Abstract

	This module implements adapters for the rational number functions.

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


/** --------------------------------------------------------------------
 ** Headers.
 ** ----------------------------------------------------------------- */

#include "mmux-emacs-gmp-internals.h"
#include <string.h>


/** --------------------------------------------------------------------
 ** Assignment functions.
 ** ----------------------------------------------------------------- */

static emacs_value
Fmmux_gmp_c_mpq_set (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpq_ptr	rop = env->get_user_ptr(env, args[0]);
  mpq_ptr	op  = env->get_user_ptr(env, args[1]);

  mpq_set(rop, op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpq_set_si (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpq_ptr	rop = env->get_user_ptr(env, args[0]);
  intmax_t	op1 = env->extract_integer(env, args[1]);
  intmax_t	op2 = env->extract_integer(env, args[2]);

  mpq_set_si(rop, (signed long int)op1, (signed long int)op2);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpq_set_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpq_ptr	rop = env->get_user_ptr(env, args[0]);
  intmax_t	op1 = env->extract_integer(env, args[1]);
  intmax_t	op2 = env->extract_integer(env, args[2]);

  mpq_set_ui(rop, (unsigned long int)op1, (unsigned long int)op2);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpq_set_d (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpq_ptr	rop = env->get_user_ptr(env, args[0]);
  double	op  = env->extract_float(env, args[1]);

  mpq_set_d(rop, op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpq_set_z (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpq_ptr	rop = env->get_user_ptr(env, args[0]);
  mpz_ptr	op  = env->get_user_ptr(env, args[1]);

  mpq_set_z(rop, op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpq_set_f (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpq_ptr	rop = env->get_user_ptr(env, args[0]);
  mpf_ptr	op = env->get_user_ptr(env, args[1]);

  mpq_set_f(rop, op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpq_set_str (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpq_ptr	rop  = env->get_user_ptr    (env, args[0]);
  intmax_t	base = env->extract_integer (env, args[2]);
  ptrdiff_t	len  = 0;

  env->copy_string_contents(env, args[1], NULL, &len);
  if (len <= 4096) {
    char	buf[len];
    int		rv;

    env->copy_string_contents(env, args[1], buf, &len);
    rv = mpq_set_str(rop, buf, (int)base);
    return env->make_integer(env, rv);
  } else {
    char const *	errmsg  = "input string exceeds maximum length";
    emacs_value		Serrmsg = env->make_string(env, errmsg, strlen(errmsg));

    /* Signal an error,  then immediately return.  In the "elisp"  Info file: see the
       node "Standard Errors" for a list of  the standard error symbols; see the node
       "Error Symbols"  for methods to define  error symbols.  (Marco Maggi;  Jan 14,
       2020) */
    env->non_local_exit_signal(env, env->intern(env, MMUX_EMAC_GMP_ERROR_STRING_TOO_LONG), Serrmsg);
    return env->intern(env, "nil");
  }
}

static emacs_value
Fmmux_gmp_c_mpq_swap (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpq_ptr	op1 = env->get_user_ptr(env, args[0]);
  mpq_ptr	op2 = env->get_user_ptr(env, args[1]);

  mpq_swap(op1, op2);
  return env->intern(env, "nil");
}


/** --------------------------------------------------------------------
 ** Conversion functions.
 ** ----------------------------------------------------------------- */

static emacs_value
Fmmux_gmp_c_mpq_get_d (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpq_ptr	op   = env->get_user_ptr    (env, args[0]);

  return env->make_float(env, mpq_get_d(op));
}

static emacs_value
Fmmux_gmp_c_mpq_get_str (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			 emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  intmax_t	base = env->extract_integer (env, args[0]);
  mpq_ptr	op   = env->get_user_ptr    (env, args[1]);

  {
    int		maxlen = 3 + mpz_sizeinbase(mpq_numref(op), base) + mpz_sizeinbase(mpq_denref(op), base) + 3;
    char	str[maxlen];

    mpq_get_str(str, base, op);
    return env->make_string(env, str, strlen(str));
  }
}


/** --------------------------------------------------------------------
 ** Arithmetic functions.
 ** ----------------------------------------------------------------- */

static emacs_value
Fmmux_gmp_c_mpq_add (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpq_ptr	rop = env->get_user_ptr(env, args[0]);
  mpq_ptr	op1 = env->get_user_ptr(env, args[1]);
  mpq_ptr	op2 = env->get_user_ptr(env, args[2]);

  mpq_add(rop, op1, op2);
  return env->intern(env, "nil");
}


/** --------------------------------------------------------------------
 ** Elisp functions table.
 ** ----------------------------------------------------------------- */

#define NUMBER_OF_MODULE_FUNCTIONS	11
static module_function_t const module_functions_table[NUMBER_OF_MODULE_FUNCTIONS] = {
  /* Assignment function. */
  {
    .name		= "mmux-gmp-c-mpq-set",
    .implementation	= Fmmux_gmp_c_mpq_set,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of an `mpq' object to another `mpq' object."
  },
  {
    .name		= "mmux-gmp-c-mpq-set-si",
    .implementation	= Fmmux_gmp_c_mpq_set_si,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Assign the values of two signed integers to an `mpq' object."
  },
  {
    .name		= "mmux-gmp-c-mpq-set-ui",
    .implementation	= Fmmux_gmp_c_mpq_set_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Assign the values of two unsigned integers to an `mpq' object."
  },
  {
    .name		= "mmux-gmp-c-mpq-set-d",
    .implementation	= Fmmux_gmp_c_mpq_set_d,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of a floating-point object to an `mpq' object."
  },
  {
    .name		= "mmux-gmp-c-mpq-set-z",
    .implementation	= Fmmux_gmp_c_mpq_set_z,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of an `mpz' object to an `mpq' object."
  },
  {
    .name		= "mmux-gmp-c-mpq-set-f",
    .implementation	= Fmmux_gmp_c_mpq_set_f,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the values of an mmux-gmp-mpf object to an `mpq' object."
  },
  {
    .name		= "mmux-gmp-c-mpq-set-str",
    .implementation	= Fmmux_gmp_c_mpq_set_str,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Assign the value of a string object to an `mpq' object."
  },
  {
    .name		= "mmux-gmp-c-mpq-swap",
    .implementation	= Fmmux_gmp_c_mpq_swap,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Swap the values of two `mpq' objects."
  },

  /* Conversion functions */
  {
    .name		= "mmux-gmp-c-mpq-get-d",
    .implementation	= Fmmux_gmp_c_mpq_get_d,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Convert an object of type `mpq' to a floating-point number."
  },
  {
    .name		= "mmux-gmp-c-mpq-get-str",
    .implementation	= Fmmux_gmp_c_mpq_get_str,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Convert an `mpq' object to a string."
  },

  /* Arithmetic functions. */
  {
    .name		= "mmux-gmp-c-mpq-add",
    .implementation	= Fmmux_gmp_c_mpq_add,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Add two `mpq' objects."
  },
};


/** --------------------------------------------------------------------
 ** Module initialisation.
 ** ----------------------------------------------------------------- */

void
mmux_emacs_gmp_rational_number_functions_init (emacs_env * env)
{
  mmux_emacs_gmp_define_functions_from_table(env, module_functions_table, NUMBER_OF_MODULE_FUNCTIONS);
}

/* end of file */
