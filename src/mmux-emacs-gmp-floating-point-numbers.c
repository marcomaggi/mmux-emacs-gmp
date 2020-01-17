/*
  Part of: MMUX Emacs GMP
  Contents: floating-point number functions
  Date: Jan 16, 2020

  Abstract

	This module implements adapters for the floating-point number functions.

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
#include <stdlib.h>
#include <errno.h>


/** --------------------------------------------------------------------
 ** Initialisation functions.
 ** ----------------------------------------------------------------- */

static emacs_value
Fmmux_gmp_c_mpf_set_default_prec (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mp_bitcnt_t	prec = env->extract_integer(env, args[0]);

  mpf_set_default_prec(prec);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpf_get_default_prec (emacs_env *env, ptrdiff_t nargs,
				  emacs_value args[] MMUX_EMACS_GMP_UNUSED, void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(0 == nargs);

  return env->make_integer(env, (intmax_t)mpf_get_default_prec());
}

static emacs_value
Fmmux_gmp_c_mpf_set_prec (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop  = env->get_user_ptr(env, args[0]);
  mp_bitcnt_t	prec = env->extract_integer(env, args[1]);

  mpf_set_prec(rop, prec);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpf_get_prec (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpf_ptr	rop  = env->get_user_ptr(env, args[0]);

  return env->make_integer(env, (intmax_t)mpf_get_prec(rop));
}


/** --------------------------------------------------------------------
 ** Assignment functions.
 ** ----------------------------------------------------------------- */

static emacs_value
Fmmux_gmp_c_mpf_set (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop = env->get_user_ptr(env, args[0]);
  mpf_ptr	op  = env->get_user_ptr(env, args[1]);

  mpf_set(rop, op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpf_set_si (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop = env->get_user_ptr(env, args[0]);
  intmax_t	op  = env->extract_integer(env, args[1]);

  mpf_set_si(rop, (signed long int)op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpf_set_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop = env->get_user_ptr(env, args[0]);
  intmax_t	op  = env->extract_integer(env, args[1]);

  mpf_set_ui(rop, (unsigned long int)op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpf_set_d (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop = env->get_user_ptr(env, args[0]);
  double	op  = env->extract_float(env, args[1]);

  mpf_set_d(rop, op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpf_set_z (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop = env->get_user_ptr(env, args[0]);
  mpz_ptr	op  = env->get_user_ptr(env, args[1]);

  mpf_set_z(rop, op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpf_set_q (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop = env->get_user_ptr(env, args[0]);
  mpq_ptr	op  = env->get_user_ptr(env, args[1]);

  mpf_set_q(rop, op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpf_set_str (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr	rop  = env->get_user_ptr    (env, args[0]);
  intmax_t	base = env->extract_integer (env, args[2]);
  ptrdiff_t	len  = 0;

  env->copy_string_contents(env, args[1], NULL, &len);
  if (len <= 4096) {
    char	buf[len];
    int		rv;

    env->copy_string_contents(env, args[1], buf, &len);
    rv = mpf_set_str(rop, buf, (int)base);
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
Fmmux_gmp_c_mpf_swap (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	op1 = env->get_user_ptr(env, args[0]);
  mpf_ptr	op2 = env->get_user_ptr(env, args[1]);

  mpf_swap(op1, op2);
  return env->intern(env, "nil");
}


/** --------------------------------------------------------------------
 ** Conversion functions.
 ** ----------------------------------------------------------------- */

static emacs_value
Fmmux_gmp_c_mpf_get_ui (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpf_ptr	op   = env->get_user_ptr    (env, args[0]);

  return env->make_integer(env, (intmax_t)mpf_get_ui(op));
}

static emacs_value
Fmmux_gmp_c_mpf_get_si (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpf_ptr	op   = env->get_user_ptr    (env, args[0]);

  return env->make_integer(env, (intmax_t)mpf_get_si(op));
}

static emacs_value
Fmmux_gmp_c_mpf_get_d (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpf_ptr	op   = env->get_user_ptr    (env, args[0]);

  return env->make_float(env, (intmax_t)mpf_get_d(op));
}

static emacs_value
Fmmux_gmp_c_mpf_get_d_2exp (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			    emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpf_ptr	op   = env->get_user_ptr    (env, args[0]);
  double	rv;
  mp_exp_t	exponent;

  rv = mpf_get_d_2exp(&exponent, op);
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
Fmmux_gmp_c_mpf_get_str (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  intmax_t	base      = env->extract_integer (env, args[0]);
  intmax_t	ndigits   = env->extract_integer (env, args[1]);
  mpf_ptr	op        = env->get_user_ptr    (env, args[2]);

  emacs_value	Srv;
  mp_exp_t	exponent;

  {
    char	*mantissa_string;
    size_t	mantissa_string_len;

    /* When  the first  argument  is NULL:  allocate memory  using  the configured  GMP
       allocator.  According to GMP's specification: the allocator cannot fail and will
       always return a non-NULL pointer. */
    mantissa_string     = mpf_get_str(NULL, &exponent, (int)base, (size_t)ndigits, op);
    mantissa_string_len = strlen(mantissa_string);
    Srv = env->make_string(env, mantissa_string, mantissa_string_len);
    {
      void (*freefunc) (void *, size_t);

      mp_get_memory_functions (NULL, NULL, &freefunc);
      freefunc(mantissa_string, 1+mantissa_string_len);
    }
  }

  {
    emacs_value Qcons       = env->intern(env, "cons");
    emacs_value operands[2] = { Srv, env->make_integer(env, (intmax_t)exponent) };

    return env->funcall(env, Qcons, 2, operands);
  }
  return Srv;
}


/** --------------------------------------------------------------------
 ** Arithmetic functions.
 ** ----------------------------------------------------------------- */

static emacs_value
Fmmux_gmp_c_mpf_add (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr	rop = env->get_user_ptr(env, args[0]);
  mpf_ptr	op1 = env->get_user_ptr(env, args[1]);
  mpf_ptr	op2 = env->get_user_ptr(env, args[2]);

  mpf_add(rop, op1, op2);
  return env->intern(env, "nil");
}


/** --------------------------------------------------------------------
 ** Elisp functions table.
 ** ----------------------------------------------------------------- */

#define NUMBER_OF_MODULE_FUNCTIONS	18
static module_function_t const module_functions_table[NUMBER_OF_MODULE_FUNCTIONS] = {
  /* Assignment function. */
  {
    .name		= "mmux-gmp-c-mpf-set-default-prec",
    .implementation	= Fmmux_gmp_c_mpf_set_default_prec,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Set the default precision of `mpf' objects."
  },
  {
    .name		= "mmux-gmp-c-mpf-get-default-prec",
    .implementation	= Fmmux_gmp_c_mpf_get_default_prec,
    .min_arity		= 0,
    .max_arity		= 0,
    .documentation	= "Get the default precision of `mpf' objects."
  },
  {
    .name		= "mmux-gmp-c-mpf-set-prec",
    .implementation	= Fmmux_gmp_c_mpf_set_prec,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Set the default precision of an `mpf' object."
  },
  {
    .name		= "mmux-gmp-c-mpf-get-prec",
    .implementation	= Fmmux_gmp_c_mpf_get_prec,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Get the default precision of an `mpf' object."
  },

  /* Assignment function. */
  {
    .name		= "mmux-gmp-c-mpf-set",
    .implementation	= Fmmux_gmp_c_mpf_set,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of an `mpf' object to another `mpf' object."
  },
  {
    .name		= "mmux-gmp-c-mpf-set-si",
    .implementation	= Fmmux_gmp_c_mpf_set_si,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of a signed integer to an `mpf' object."
  },
  {
    .name		= "mmux-gmp-c-mpf-set-ui",
    .implementation	= Fmmux_gmp_c_mpf_set_ui,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of an unsigned integer to an `mpf' object."
  },
  {
    .name		= "mmux-gmp-c-mpf-set-d",
    .implementation	= Fmmux_gmp_c_mpf_set_d,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of floating-point object to an `mpf' object."
  },
  {
    .name		= "mmux-gmp-c-mpf-set-z",
    .implementation	= Fmmux_gmp_c_mpf_set_z,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of an `mpz' object to an `mpf' object."
  },
  {
    .name		= "mmux-gmp-c-mpf-set-q",
    .implementation	= Fmmux_gmp_c_mpf_set_q,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of an `mpq' object to an `mpf' object."
  },
  {
    .name		= "mmux-gmp-c-mpf-set-str",
    .implementation	= Fmmux_gmp_c_mpf_set_str,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Assign the value of a string object to an `mpf' object."
  },
  {
    .name		= "mmux-gmp-c-mpf-swap",
    .implementation	= Fmmux_gmp_c_mpf_swap,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Swap the values of two `mpf' objects."
  },

  /* Conversion functions */
  {
    .name		= "mmux-gmp-c-mpf-get-ui",
    .implementation	= Fmmux_gmp_c_mpf_get_ui,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Convert an object of type `mpf' to an unsigned exact integer number."
  },
  {
    .name		= "mmux-gmp-c-mpf-get-si",
    .implementation	= Fmmux_gmp_c_mpf_get_si,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Convert an object of type `mpf' to a signed exact integer number."
  },
  {
    .name		= "mmux-gmp-c-mpf-get-d",
    .implementation	= Fmmux_gmp_c_mpf_get_d,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Convert an object of type `mpf' to a floating-point number."
  },
  {
    .name		= "mmux-gmp-c-mpf-get-d-2exp",
    .implementation	= Fmmux_gmp_c_mpf_get_d_2exp,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Convert an object of type `mpf' to a floating-point number, returning the exponent separately."
  },
  {
    .name		= "mmux-gmp-c-mpf-get-str",
    .implementation	= Fmmux_gmp_c_mpf_get_str,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Convert an `mpf' object to a string."
  },

  /* Arithmetic functions. */
  {
    .name		= "mmux-gmp-c-mpf-add",
    .implementation	= Fmmux_gmp_c_mpf_add,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Add two `mpf' objects."
  },
};


/** --------------------------------------------------------------------
 ** Module initialisation.
 ** ----------------------------------------------------------------- */

void
mmux_emacs_gmp_floating_point_number_functions_init (emacs_env * env)
{
  mmux_emacs_gmp_define_functions_from_table(env, module_functions_table, NUMBER_OF_MODULE_FUNCTIONS);
}

/* end of file */
