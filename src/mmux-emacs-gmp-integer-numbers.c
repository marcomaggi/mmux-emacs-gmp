/*
  Part of: MMUX Emacs GMP
  Contents: integer functions
  Date: Jan 15, 2020

  Abstract

	This module implements adapters for the integer functions.

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
Fmmux_gmp_c_mpz_set (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  mpz_ptr	op  = env->get_user_ptr(env, args[1]);

  mpz_set(rop, op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpz_set_si (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  intmax_t	op  = env->extract_integer(env, args[1]);

  mpz_set_si(rop, (signed long int)op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpz_set_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  intmax_t	op  = env->extract_integer(env, args[1]);

  mpz_set_ui(rop, (unsigned long int)op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpz_set_d (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  double	op  = env->extract_float(env, args[1]);

  mpz_set_d(rop, op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpz_set_q (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  mpq_ptr	op  = env->get_user_ptr(env, args[1]);

  mpz_set_q(rop, op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpz_set_f (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  mpf_ptr	op  = env->get_user_ptr(env, args[1]);

  mpz_set_f(rop, op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpz_set_str (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop  = env->get_user_ptr    (env, args[0]);
  intmax_t	base = env->extract_integer (env, args[2]);
  ptrdiff_t	len  = 0;

  env->copy_string_contents(env, args[1], NULL, &len);
  if (len <= 4096) {
    char	buf[len];
    int		rv;

    env->copy_string_contents(env, args[1], buf, &len);
    rv = mpz_set_str(rop, buf, (int)base);
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
Fmmux_gmp_c_mpz_swap (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	op1 = env->get_user_ptr(env, args[0]);
  mpz_ptr	op2 = env->get_user_ptr(env, args[1]);

  mpz_swap(op1, op2);
  return env->intern(env, "nil");
}


/** --------------------------------------------------------------------
 ** Conversion functions.
 ** ----------------------------------------------------------------- */

static emacs_value
Fmmux_gmp_c_mpz_get_ui (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpz_ptr	op   = env->get_user_ptr    (env, args[0]);

  return env->make_integer(env, (intmax_t)mpz_get_ui(op));
}

static emacs_value
Fmmux_gmp_c_mpz_get_si (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpz_ptr	op   = env->get_user_ptr    (env, args[0]);

  return env->make_integer(env, (intmax_t)mpz_get_si(op));
}

static emacs_value
Fmmux_gmp_c_mpz_get_d (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpz_ptr	op   = env->get_user_ptr    (env, args[0]);

  return env->make_float(env, (intmax_t)mpz_get_d(op));
}

static emacs_value
Fmmux_gmp_c_mpz_get_d_2exp (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			    emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpz_ptr	op   = env->get_user_ptr    (env, args[0]);
  double	rv;
  mp_exp_t	exponent;

  rv = mpz_get_d_2exp(&exponent, op);
  {
    emacs_value Qcons       = env->intern(env, "cons");
    emacs_value operands[2] = {
      env->make_float(env, rv),
      env->make_integer(env, (intmax_t)exponent)
    };

    return env->funcall(env, Qcons, 2, operands);
  }
}

static emacs_value
Fmmux_gmp_c_mpz_get_str (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			 emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  intmax_t	base = env->extract_integer (env, args[0]);
  mpz_ptr	op   = env->get_user_ptr    (env, args[1]);

  {
    int		maxlen = 2 + mpz_sizeinbase(op, (int)base);
    char	str[maxlen];

    mpz_get_str(str, base, op);
    return env->make_string(env, str, strlen(str));
  }
}


/** --------------------------------------------------------------------
 ** Arithmetic functions.
 ** ----------------------------------------------------------------- */

static emacs_value
Fmmux_gmp_c_mpz_add (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  mpz_ptr	op1 = env->get_user_ptr(env, args[1]);
  mpz_ptr	op2 = env->get_user_ptr(env, args[2]);

  mpz_add(rop, op1, op2);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpz_add_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  mpz_ptr	op1 = env->get_user_ptr(env, args[1]);
  intmax_t	op2 = env->extract_integer(env, args[2]);

  mpz_add_ui(rop, op1, (unsigned long int)op2);
  return env->intern(env, "nil");
}

/* ------------------------------------------------------------------ */

static emacs_value
Fmmux_gmp_c_mpz_sub (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  mpz_ptr	op1 = env->get_user_ptr(env, args[1]);
  mpz_ptr	op2 = env->get_user_ptr(env, args[2]);

  mpz_sub(rop, op1, op2);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpz_sub_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  mpz_ptr	op1 = env->get_user_ptr(env, args[1]);
  intmax_t	op2 = env->extract_integer(env, args[2]);

  mpz_sub_ui(rop, op1, (unsigned long int)op2);
  return env->intern(env, "nil");
}

/* ------------------------------------------------------------------ */

static emacs_value
Fmmux_gmp_c_mpz_addmul (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  mpz_ptr	op1 = env->get_user_ptr(env, args[1]);
  mpz_ptr	op2 = env->get_user_ptr(env, args[2]);

  mpz_addmul(rop, op1, op2);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpz_addmul_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  mpz_ptr	op1 = env->get_user_ptr(env, args[1]);
  intmax_t	op2 = env->extract_integer(env, args[2]);

  mpz_addmul_ui(rop, op1, (unsigned long int)op2);
  return env->intern(env, "nil");
}

/* ------------------------------------------------------------------ */

static emacs_value
Fmmux_gmp_c_mpz_submul (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  mpz_ptr	op1 = env->get_user_ptr(env, args[1]);
  mpz_ptr	op2 = env->get_user_ptr(env, args[2]);

  mpz_submul(rop, op1, op2);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpz_submul_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  mpz_ptr	op1 = env->get_user_ptr(env, args[1]);
  intmax_t	op2 = env->extract_integer(env, args[2]);

  mpz_submul_ui(rop, op1, (unsigned long int)op2);
  return env->intern(env, "nil");
}

/* ------------------------------------------------------------------ */

static emacs_value
Fmmux_gmp_c_mpz_mul (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  mpz_ptr	op1 = env->get_user_ptr(env, args[1]);
  mpz_ptr	op2 = env->get_user_ptr(env, args[2]);

  mpz_mul(rop, op1, op2);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpz_mul_si (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  mpz_ptr	op1 = env->get_user_ptr(env, args[1]);
  intmax_t	op2 = env->extract_integer(env, args[2]);

  mpz_mul_si(rop, op1, (signed long int)op2);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpz_mul_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  mpz_ptr	op1 = env->get_user_ptr(env, args[1]);
  intmax_t	op2 = env->extract_integer(env, args[2]);

  mpz_mul_ui(rop, op1, (unsigned long int)op2);
  return env->intern(env, "nil");
}

/* ------------------------------------------------------------------ */

static emacs_value
Fmmux_gmp_c_mpz_mul_2exp (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  mpz_ptr	op1 = env->get_user_ptr(env, args[1]);
  intmax_t	op2 = env->extract_integer(env, args[2]);

  mpz_mul_2exp(rop, op1, (mp_bitcnt_t)op2);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpz_neg (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  mpz_ptr	op  = env->get_user_ptr(env, args[1]);

  mpz_neg(rop, op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpz_abs (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	rop = env->get_user_ptr(env, args[0]);
  mpz_ptr	op  = env->get_user_ptr(env, args[1]);

  mpz_abs(rop, op);
  return env->intern(env, "nil");
}


/** --------------------------------------------------------------------
 ** Elisp functions table.
 ** ----------------------------------------------------------------- */

#define NUMBER_OF_MODULE_FUNCTIONS	27
static module_function_t const module_functions_table[NUMBER_OF_MODULE_FUNCTIONS] = {
  /* Assignment function. */
  {
    .name		= "mmux-gmp-c-mpz-set",
    .implementation	= Fmmux_gmp_c_mpz_set,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of an `mpz' object to another `mpz' object."
  },
  {
    .name		= "mmux-gmp-c-mpz-set-si",
    .implementation	= Fmmux_gmp_c_mpz_set_si,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of a signed integer to an `mpz' object."
  },
  {
    .name		= "mmux-gmp-c-mpz-set-ui",
    .implementation	= Fmmux_gmp_c_mpz_set_ui,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of an unsigned integer to an `mpz' object."
  },
  {
    .name		= "mmux-gmp-c-mpz-set-d",
    .implementation	= Fmmux_gmp_c_mpz_set_d,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of floating-point object to an `mpz' object."
  },
  {
    .name		= "mmux-gmp-c-mpz-set-q",
    .implementation	= Fmmux_gmp_c_mpz_set_q,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of an `mpq' object to an `mpz' object."
  },
  {
    .name		= "mmux-gmp-c-mpz-set-f",
    .implementation	= Fmmux_gmp_c_mpz_set_f,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of an `mpf' object to an `mpz' object."
  },
  {
    .name		= "mmux-gmp-c-mpz-set-str",
    .implementation	= Fmmux_gmp_c_mpz_set_str,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Assign the value of a string object to an `mpz' object."
  },
  {
    .name		= "mmux-gmp-c-mpz-swap",
    .implementation	= Fmmux_gmp_c_mpz_swap,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Swap the values of two `mpz' objects."
  },

  /* Conversion functions */
  {
    .name		= "mmux-gmp-c-mpz-get-ui",
    .implementation	= Fmmux_gmp_c_mpz_get_ui,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Convert an object of type `mpz' to an unsigned exact integer number."
  },
  {
    .name		= "mmux-gmp-c-mpz-get-si",
    .implementation	= Fmmux_gmp_c_mpz_get_si,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Convert an object of type `mpz' to a signed exact integer number."
  },
  {
    .name		= "mmux-gmp-c-mpz-get-d",
    .implementation	= Fmmux_gmp_c_mpz_get_d,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Convert an object of type `mpz' to a floating-point number."
  },
  {
    .name		= "mmux-gmp-c-mpz-get-d-2exp",
    .implementation	= Fmmux_gmp_c_mpz_get_d_2exp,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Convert an object of type `mpz' to a floating-point number, returning the exponent separately."
  },
  {
    .name		= "mmux-gmp-c-mpz-get-str",
    .implementation	= Fmmux_gmp_c_mpz_get_str,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Convert an `mpz' object to a string."
  },

  /* Arithmetic functions. */
  {
    .name		= "mmux-gmp-c-mpz-add",
    .implementation	= Fmmux_gmp_c_mpz_add,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Add two `mpz' objects."
  },
  {
    .name		= "mmux-gmp-c-mpz-add-ui",
    .implementation	= Fmmux_gmp_c_mpz_add_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Add an `mpz' object to an unsigned exact iteger number.",
  },
  {
    .name		= "mmux-gmp-c-mpz-sub",
    .implementation	= Fmmux_gmp_c_mpz_sub,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Subtract an `mpz' object from another `mpz' object.",
  },
  {
    .name		= "mmux-gmp-c-mpz-sub-ui",
    .implementation	= Fmmux_gmp_c_mpz_sub_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Subtract an unsigned exact integer number from an `mpz' object.",
  },
  {
    .name		= "mmux-gmp-c-mpz-addmul",
    .implementation	= Fmmux_gmp_c_mpz_addmul,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Multiply two `mpz' objects, then add the result to another `mpz' object.",
  },
  {
    .name		= "mmux-gmp-c-mpz-addmul-ui",
    .implementation	= Fmmux_gmp_c_mpz_addmul_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Multiply an `mpz' object by an unsigned exact integer number, then add the result to another `mpz' object."
  },
  {
    .name		= "mmux-gmp-c-mpz-submul",
    .implementation	= Fmmux_gmp_c_mpz_submul,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Multiply two `mpz' objects, then subtract the result from another `mpz' object.",
  },
  {
    .name		= "mmux-gmp-c-mpz-submul-ui",
    .implementation	= Fmmux_gmp_c_mpz_submul_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Multiply an `mpz' object with an unsigned exact integer number, then subtract the result from another `mpz' object.",
  },
  {
    .name		= "mmux-gmp-c-mpz-mul",
    .implementation	= Fmmux_gmp_c_mpz_mul,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Multiply two `mpz' objects."
  },
  {
    .name		= "mmux-gmp-c-mpz-mul-si",
    .implementation	= Fmmux_gmp_c_mpz_mul_si,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Multiply an `mpz' object by a signed exact integer number."
  },
  {
    .name		= "mmux-gmp-c-mpz-mul-ui",
    .implementation	= Fmmux_gmp_c_mpz_mul_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Multiply an `mpz' object by an unsigned exact integer number."
  },
  {
    .name		= "mmux-gmp-c-mpz-mul-2exp",
    .implementation	= Fmmux_gmp_c_mpz_mul_2exp,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Left shift an `mpz'.",
  },
  {
    .name		= "mmux-gmp-c-mpz-neg",
    .implementation	= Fmmux_gmp_c_mpz_neg,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Negate an `mpz' object.",
  },
  {
    .name		= "mmux-gmp-c-mpz-abs",
    .implementation	= Fmmux_gmp_c_mpz_abs,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Compute the absolute value of an `mpz' object",
  },
};


/** --------------------------------------------------------------------
 ** Module initialisation.
 ** ----------------------------------------------------------------- */

void
mmux_emacs_gmp_integer_number_functions_init (emacs_env * env)
{
  mmux_emacs_gmp_define_functions_from_table(env, module_functions_table, NUMBER_OF_MODULE_FUNCTIONS);
}

/* end of file */
