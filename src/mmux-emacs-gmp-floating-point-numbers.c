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
Fmmux_emacs_gmp_c_mpf_set_default_prec (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mp_bitcnt_t	prec = mmux_emacs_get_gmp_bitcnt(env, args[0]);

  mpf_set_default_prec(prec);
  return mmux_emacs_make_nil(env);
}

static emacs_value
Fmmux_emacs_gmp_c_mpf_get_default_prec (emacs_env *env, ptrdiff_t nargs,
					emacs_value args[] MMUX_EMACS_GMP_UNUSED, void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(0 == nargs);

  return mmux_emacs_make_gmp_prec(env, mpf_get_default_prec());
}

static emacs_value
Fmmux_emacs_gmp_c_mpf_set_prec (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop  = mmux_emacs_get_gmp_mpf(env, args[0]);
  mp_bitcnt_t	prec = mmux_emacs_get_gmp_bitcnt(env, args[1]);

  mpf_set_prec(rop, prec);
  return mmux_emacs_make_nil(env);
}

static emacs_value
Fmmux_emacs_gmp_c_mpf_get_prec (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpf_ptr	rop  = mmux_emacs_get_ptr(env, args[0]);

  return mmux_emacs_make_gmp_prec(env, mpf_get_prec(rop));
}


/** --------------------------------------------------------------------
 ** Assignment functions.
 ** ----------------------------------------------------------------- */

static emacs_value
Fmmux_emacs_gmp_c_mpf_set (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop = mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op  = mmux_emacs_get_gmp_mpf(env, args[1]);

  mpf_set(rop, op);
  return mmux_emacs_make_nil(env);
}

static emacs_value
Fmmux_emacs_gmp_c_mpf_set_si (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop = mmux_emacs_get_gmp_mpf(env, args[0]);
  mmux_slint_t	op  = mmux_emacs_get_slint(env, args[1]);

  mpf_set_si(rop, op);
  return mmux_emacs_make_nil(env);
}

static emacs_value
Fmmux_emacs_gmp_c_mpf_set_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop = mmux_emacs_get_gmp_mpf(env, args[0]);
  mmux_ulint_t	op  = mmux_emacs_get_ulint(env, args[1]);

  mpf_set_ui(rop, op);
  return mmux_emacs_make_nil(env);
}

static emacs_value
Fmmux_emacs_gmp_c_mpf_set_d (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop = mmux_emacs_get_gmp_mpf(env, args[0]);
  double	op  = mmux_emacs_get_float(env, args[1]);

  mpf_set_d(rop, op);
  return mmux_emacs_make_nil(env);
}

static emacs_value
Fmmux_emacs_gmp_c_mpf_set_z (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop = mmux_emacs_get_gmp_mpf(env, args[0]);
  mpz_ptr	op  = mmux_emacs_get_gmp_mpz(env, args[1]);

  mpf_set_z(rop, op);
  return mmux_emacs_make_nil(env);
}

static emacs_value
Fmmux_emacs_gmp_c_mpf_set_q (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop = mmux_emacs_get_gmp_mpf(env, args[0]);
  mpq_ptr	op  = mmux_emacs_get_gmp_mpq(env, args[1]);

  mpf_set_q(rop, op);
  return mmux_emacs_make_nil(env);
}

static emacs_value
Fmmux_emacs_gmp_c_mpf_set_str (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr	rop  = mmux_emacs_get_gmp_mpf(env, args[0]);
  intmax_t	base = mmux_emacs_get_int(env, args[2]);
  ptrdiff_t	len  = 0;

  env->copy_string_contents(env, args[1], NULL, &len);
  if (len <= 4096) {
    char	buf[len];
    int		rv;

    env->copy_string_contents(env, args[1], buf, &len);
    rv = mpf_set_str(rop, buf, (int)base);
    return mmux_emacs_make_sint(env, rv);
  } else {
    char const *	errmsg  = "input string exceeds maximum length";
    emacs_value		Serrmsg = mmux_emacs_make_string(env, errmsg, strlen(errmsg));

    /* Signal an error,  then immediately return.  In the "elisp"  Info file: see the
       node "Standard Errors" for a list of  the standard error symbols; see the node
       "Error Symbols"  for methods to define  error symbols.  (Marco Maggi;  Jan 14,
       2020) */
    env->non_local_exit_signal(env, env->intern(env, MMUX_EMACS_GMP_ERROR_STRING_TOO_LONG), Serrmsg);
    return mmux_emacs_make_nil(env);
  }
}

static emacs_value
Fmmux_emacs_gmp_c_mpf_swap (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	op1 = mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op2 = mmux_emacs_get_gmp_mpf(env, args[1]);

  mpf_swap(op1, op2);
  return mmux_emacs_make_nil(env);
}


/** --------------------------------------------------------------------
 ** Conversion functions.
 ** ----------------------------------------------------------------- */

static emacs_value
Fmmux_emacs_gmp_c_mpf_get_ui (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			      emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpf_ptr	op   = mmux_emacs_get_gmp_mpf(env, args[0]);

  return mmux_emacs_make_ulint(env, mpf_get_ui(op));
}

static emacs_value
Fmmux_emacs_gmp_c_mpf_get_si (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			      emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpf_ptr	op   = mmux_emacs_get_gmp_mpf(env, args[0]);

  return mmux_emacs_make_slint(env, mpf_get_si(op));
}

static emacs_value
Fmmux_emacs_gmp_c_mpf_get_d (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			     emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpf_ptr	op   = mmux_emacs_get_gmp_mpf(env, args[0]);

  return mmux_emacs_make_float(env, mpf_get_d(op));
}

static emacs_value
Fmmux_emacs_gmp_c_mpf_get_d_2exp (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
				  emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpf_ptr	op   = mmux_emacs_get_gmp_mpf(env, args[0]);
  double	rv;
  mp_exp_t	exponent;

  rv = mpf_get_d_2exp(&exponent, op);
  {
    emacs_value Qcons       = env->intern(env, "cons");
    emacs_value operands[2] = {
      mmux_emacs_make_float(env, rv),
      mmux_emacs_make_gmp_mp_exp(env, exponent)
    };

    return env->funcall(env, Qcons, 2, operands);
  }
}

static emacs_value
Fmmux_emacs_gmp_c_mpf_get_str (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  int		base      = mmux_emacs_get_sint(env, args[0]);
  size_t	ndigits   = (size_t)mmux_emacs_get_int(env, args[1]);
  mpf_ptr	op        = mmux_emacs_get_gmp_mpf(env, args[2]);

  emacs_value	Srv;
  mp_exp_t	exponent;

  {
    char	*mantissa_string;
    size_t	mantissa_string_len;

    /* When  the first  argument  is NULL:  allocate memory  using  the configured  GMP
       allocator.  According to GMP's specification: the allocator cannot fail and will
       always return a non-NULL pointer. */
    mantissa_string     = mpf_get_str(NULL, &exponent, base, ndigits, op);
    mantissa_string_len = strlen(mantissa_string);
    Srv = mmux_emacs_make_string(env, mantissa_string, mantissa_string_len);
    {
      void (*freefunc) (void *, size_t);

      mp_get_memory_functions (NULL, NULL, &freefunc);
      freefunc(mantissa_string, 1+mantissa_string_len);
    }
  }

  {
    emacs_value Qcons       = env->intern(env, "cons");
    emacs_value operands[2] = { Srv, mmux_emacs_make_gmp_mp_exp(env, exponent) };

    return env->funcall(env, Qcons, 2, operands);
  }
  return Srv;
}


/** --------------------------------------------------------------------
 ** Arithmetic functions.
 ** ----------------------------------------------------------------- */

/* mpf_add (mpf_t ROP, const mpf_t OP1, const mpf_t OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_add (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr	rop = mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op1 = mmux_emacs_get_gmp_mpf(env, args[1]);
  mpf_ptr	op2 = mmux_emacs_get_gmp_mpf(env, args[2]);

  mpf_add(rop, op1, op2);
  return mmux_emacs_make_nil(env);
}

/* void mpf_add_ui (mpf_t ROP, const mpf_t OP1, unsigned long int OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_add_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr	rop = mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op1 = mmux_emacs_get_gmp_mpf(env, args[1]);
  mmux_ulint_t	op2 = mmux_emacs_get_ulint(env, args[2]);

  mpf_add_ui(rop, op1, op2);
  return mmux_emacs_make_nil(env);
}

/* void mpf_sub (mpf_t ROP, const mpf_t OP1, const mpf_t OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_sub (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr	rop	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op1	= mmux_emacs_get_gmp_mpf(env, args[1]);
  mpf_ptr	op2	= mmux_emacs_get_gmp_mpf(env, args[2]);

  mpf_sub(rop, op1, op2);
  return mmux_emacs_make_nil(env);
}

/* void mpf_ui_sub (mpf_t ROP, unsigned long int OP1, const mpf_t OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_ui_sub (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr	rop	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mmux_ulint_t	op1	= mmux_emacs_get_ulint(env, args[1]);
  mpf_ptr	op2	= mmux_emacs_get_gmp_mpf(env, args[2]);

  mpf_ui_sub(rop, op1, op2);
  return mmux_emacs_make_nil(env);
}

/* void mpf_sub_ui (mpf_t ROP, const mpf_t OP1, unsigned long int OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_sub_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr	rop	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op1	= mmux_emacs_get_gmp_mpf(env, args[1]);
  mmux_ulint_t	op2	= mmux_emacs_get_ulint(env, args[2]);

  mpf_sub_ui(rop, op1, op2);
  return mmux_emacs_make_nil(env);
}

/* void mpf_mul (mpf_t ROP, const mpf_t OP1, const mpf_t OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_mul (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr	rop	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op1	= mmux_emacs_get_gmp_mpf(env, args[1]);
  mpf_ptr	op2	= mmux_emacs_get_gmp_mpf(env, args[2]);

  mpf_mul(rop, op1, op2);
  return mmux_emacs_make_nil(env);
}

/* void mpf_mul_ui (mpf_t ROP, const mpf_t OP1, unsigned long int OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_mul_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr	rop	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op1	= mmux_emacs_get_gmp_mpf(env, args[1]);
  mmux_ulint_t	op2	= mmux_emacs_get_ulint(env, args[2]);

  mpf_mul_ui(rop, op1, op2);
  return mmux_emacs_make_nil(env);
}

/* void mpf_div (mpf_t ROP, const mpf_t OP1, const mpf_t OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_div (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr	rop	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op1	= mmux_emacs_get_gmp_mpf(env, args[1]);
  mpf_ptr	op2	= mmux_emacs_get_gmp_mpf(env, args[2]);

  mpf_div(rop, op1, op2);
  return mmux_emacs_make_nil(env);
}

/* void mpf_ui_div (mpf_t ROP, unsigned long int OP1, const mpf_t OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_ui_div (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr	rop	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mmux_ulint_t	op1	= mmux_emacs_get_ulint(env, args[1]);
  mpf_ptr	op2	= mmux_emacs_get_gmp_mpf(env, args[2]);

  mpf_ui_div(rop, op1, op2);
  return mmux_emacs_make_nil(env);
}

/* void mpf_div_ui (mpf_t ROP, const mpf_t OP1, unsigned long int OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_div_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr	rop	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op1	= mmux_emacs_get_gmp_mpf(env, args[1]);
  mmux_ulint_t	op2	= mmux_emacs_get_ulint(env, args[2]);

  mpf_div_ui(rop, op1, op2);
  return mmux_emacs_make_nil(env);
}

/* void mpf_sqrt (mpf_t ROP, const mpf_t OP) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_sqrt (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op	= mmux_emacs_get_gmp_mpf(env, args[1]);

  mpf_sqrt(rop, op);
  return mmux_emacs_make_nil(env);
}

/* void mpf_sqrt_ui (mpf_t ROP, unsigned long int OP) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_sqrt_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mmux_ulint_t	op	= mmux_emacs_get_ulint(env, args[1]);

  mpf_sqrt_ui(rop, op);
  return mmux_emacs_make_nil(env);
}

/* void mpf_pow_ui (mpf_t ROP, const mpf_t OP1, unsigned long int OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_pow_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr	rop	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op1	= mmux_emacs_get_gmp_mpf(env, args[1]);
  mmux_ulint_t	op2	= mmux_emacs_get_ulint(env, args[2]);

  mpf_pow_ui(rop, op1, op2);
  return mmux_emacs_make_nil(env);
}

/* void mpf_neg (mpf_t ROP, const mpf_t OP) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_neg (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op	= mmux_emacs_get_gmp_mpf(env, args[1]);

  mpf_neg(rop, op);
  return mmux_emacs_make_nil(env);
}

/* void mpf_abs (mpf_t ROP, const mpf_t OP) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_abs (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op	= mmux_emacs_get_gmp_mpf(env, args[1]);

  mpf_abs(rop, op);
  return mmux_emacs_make_nil(env);
}

/* void mpf_mul_2exp (mpf_t ROP, const mpf_t OP1, mp_bitcnt_t OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_mul_2exp (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr	rop	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op1	= mmux_emacs_get_gmp_mpf(env, args[1]);
  mp_bitcnt_t	op2	= mmux_emacs_get_ulint(env, args[2]);

  mpf_mul_2exp(rop, op1, op2);
  return mmux_emacs_make_nil(env);
}

/* void mpf_div_2exp (mpf_t ROP, const mpf_t OP1, mp_bitcnt_t OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_div_2exp (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr	rop	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op1	= mmux_emacs_get_gmp_mpf(env, args[1]);
  mp_bitcnt_t	op2	= mmux_emacs_get_ulint(env, args[2]);

  mpf_div_2exp(rop, op1, op2);
  return mmux_emacs_make_nil(env);
}


/** --------------------------------------------------------------------
 ** Comparison functions.
 ** ----------------------------------------------------------------- */

/* int mpf_cmp (const mpf_t OP1, const mpf_t OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_cmp (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	op1	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op2	= mmux_emacs_get_gmp_mpf(env, args[1]);

  return mmux_emacs_make_sint(env, mpf_cmp(op1, op2));
}

/* int mpf_cmp_z (const mpf_t OP1, const mpz_t OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_cmp_z (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	op1	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mpz_ptr	op2	= mmux_emacs_get_gmp_mpz(env, args[1]);

  return mmux_emacs_make_sint(env, mpf_cmp_z(op1, op2));
}

/* int mpf_cmp_d (const mpf_t OP1, double OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_cmp_d (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	op1	= mmux_emacs_get_gmp_mpf(env, args[0]);
  double	op2	= mmux_emacs_get_float(env, args[1]);

  return mmux_emacs_make_sint(env, mpf_cmp_d(op1, op2));
}

/* int mpf_cmp_ui (const mpf_t OP1, unsigned long int OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_cmp_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	op1	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mmux_ulint_t	op2	= mmux_emacs_get_ulint(env, args[1]);

  return mmux_emacs_make_sint(env, mpf_cmp_ui(op1, op2));
}

/* int mpf_cmp_si (const mpf_t OP1, long int OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_cmp_si (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	op1	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mmux_slint_t	op2	= mmux_emacs_get_slint(env, args[1]);

  return mmux_emacs_make_sint(env, mpf_cmp_si(op1, op2));
}

/* int mpf_sgn (const mpf_t OP) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_sgn (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpf_ptr	op = mmux_emacs_get_gmp_mpf(env, args[0]);

  return mmux_emacs_make_sint(env, mpf_sgn(op));
}

/* void mpf_reldiff (mpf_t ROP, const mpf_t OP1, const mpf_t OP2) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_reldiff (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr	rop	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op1	= mmux_emacs_get_gmp_mpf(env, args[1]);
  mpf_ptr	op2	= mmux_emacs_get_gmp_mpf(env, args[2]);

  mpf_reldiff(rop, op1, op2);
  return mmux_emacs_make_nil(env);
}


/** --------------------------------------------------------------------
 ** Miscellaneous functions.
 ** ----------------------------------------------------------------- */

/* void mpf_ceil (mpf_t ROP, const mpf_t OP) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_ceil (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop = mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op  = mmux_emacs_get_gmp_mpf(env, args[1]);

  mpf_ceil(rop, op);
  return mmux_emacs_make_nil(env);
}

/* void mpf_floor (mpf_t ROP, const mpf_t OP) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_floor (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop = mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op  = mmux_emacs_get_gmp_mpf(env, args[1]);

  mpf_floor(rop, op);
  return mmux_emacs_make_nil(env);
}

/* void mpf_trunc (mpf_t ROP, const mpf_t OP) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_trunc (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpf_ptr	rop = mmux_emacs_get_gmp_mpf(env, args[0]);
  mpf_ptr	op  = mmux_emacs_get_gmp_mpf(env, args[1]);

  mpf_trunc(rop, op);
  return mmux_emacs_make_nil(env);
}

/* int mpf_integer_p (const mpf_t OP) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_integer_p (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpf_ptr	op = mmux_emacs_get_gmp_mpf(env, args[0]);

  return mmux_emacs_make_boolean(env, mpf_integer_p(op));
}

/* int mpf_fits_ulong_p (const mpf_t OP) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_fits_ulong_p (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpf_ptr	op = mmux_emacs_get_gmp_mpf(env, args[0]);

  return mmux_emacs_make_boolean(env, mpf_fits_ulong_p(op));
}

/* int mpf_fits_slong_p (const mpf_t OP) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_fits_slong_p (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpf_ptr	op = mmux_emacs_get_gmp_mpf(env, args[0]);

  return mmux_emacs_make_boolean(env, mpf_fits_slong_p(op));
}

/* int mpf_fits_uint_p (const mpf_t OP) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_fits_uint_p (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpf_ptr	op = mmux_emacs_get_gmp_mpf(env, args[0]);

  return mmux_emacs_make_boolean(env, mpf_fits_uint_p(op));
}

/* int mpf_fits_sint_p (const mpf_t OP) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_fits_sint_p (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpf_ptr	op = mmux_emacs_get_gmp_mpf(env, args[0]);

  return mmux_emacs_make_boolean(env, mpf_fits_sint_p(op));
}

/* int mpf_fits_ushort_p (const mpf_t OP) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_fits_ushort_p (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpf_ptr	op = mmux_emacs_get_gmp_mpf(env, args[0]);

  return mmux_emacs_make_boolean(env, mpf_fits_ushort_p(op));
}

/* int mpf_fits_sshort_p (const mpf_t OP) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_fits_sshort_p (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpf_ptr	op = mmux_emacs_get_gmp_mpf(env, args[0]);

  return mmux_emacs_make_boolean(env, mpf_fits_sshort_p(op));
}

/* void mpf_urandomb (mpf_t ROP, gmp_randstate_t STATE, mp_bitcnt_t NBITS) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_urandomb (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr		rop	= mmux_emacs_get_gmp_mpf(env, args[0]);
  mmux_gmp_randstate_t	state	= mmux_emacs_get_gmp_randstate(env, args[1]);
  mp_bitcnt_t		nbits	= mmux_emacs_get_gmp_bitcnt(env, args[2]);

  mpf_urandomb(rop, state, nbits);
  return mmux_emacs_make_nil(env);
}

/* void mpf_random2 (mpf_t ROP, mp_size_t MAX_SIZE, mp_exp_t EXP) */
static emacs_value
Fmmux_emacs_gmp_c_mpf_random2 (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpf_ptr	rop		= mmux_emacs_get_gmp_mpf(env, args[0]);
  mp_size_t	max_size	= mmux_emacs_get_gmp_size(env, args[1]);
  mp_exp_t	exp		= mmux_emacs_get_gmp_exp(env, args[2]);

  mpf_random2(rop, max_size, exp);
  return mmux_emacs_make_nil(env);
}


/** --------------------------------------------------------------------
 ** Elisp functions table.
 ** ----------------------------------------------------------------- */

#define NUMBER_OF_MODULE_FUNCTIONS	53
static module_function_t const module_functions_table[NUMBER_OF_MODULE_FUNCTIONS] = {
  /* Assignment function. */
  {
    .name		= "mmux-gmp-c-mpf-set-default-prec",
    .implementation	= Fmmux_emacs_gmp_c_mpf_set_default_prec,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Set the default precision of `mpf' objects."
  },
  {
    .name		= "mmux-gmp-c-mpf-get-default-prec",
    .implementation	= Fmmux_emacs_gmp_c_mpf_get_default_prec,
    .min_arity		= 0,
    .max_arity		= 0,
    .documentation	= "Get the default precision of `mpf' objects."
  },
  {
    .name		= "mmux-gmp-c-mpf-set-prec",
    .implementation	= Fmmux_emacs_gmp_c_mpf_set_prec,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Set the default precision of an `mpf' object."
  },
  {
    .name		= "mmux-gmp-c-mpf-get-prec",
    .implementation	= Fmmux_emacs_gmp_c_mpf_get_prec,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Get the default precision of an `mpf' object."
  },

  /* Assignment function. */
  {
    .name		= "mmux-gmp-c-mpf-set",
    .implementation	= Fmmux_emacs_gmp_c_mpf_set,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of an `mpf' object to another `mpf' object."
  },
  {
    .name		= "mmux-gmp-c-mpf-set-si",
    .implementation	= Fmmux_emacs_gmp_c_mpf_set_si,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of a signed integer to an `mpf' object."
  },
  {
    .name		= "mmux-gmp-c-mpf-set-ui",
    .implementation	= Fmmux_emacs_gmp_c_mpf_set_ui,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of an unsigned integer to an `mpf' object."
  },
  {
    .name		= "mmux-gmp-c-mpf-set-d",
    .implementation	= Fmmux_emacs_gmp_c_mpf_set_d,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of floating-point object to an `mpf' object."
  },
  {
    .name		= "mmux-gmp-c-mpf-set-z",
    .implementation	= Fmmux_emacs_gmp_c_mpf_set_z,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of an `mpz' object to an `mpf' object."
  },
  {
    .name		= "mmux-gmp-c-mpf-set-q",
    .implementation	= Fmmux_emacs_gmp_c_mpf_set_q,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Assign the value of an `mpq' object to an `mpf' object."
  },
  {
    .name		= "mmux-gmp-c-mpf-set-str",
    .implementation	= Fmmux_emacs_gmp_c_mpf_set_str,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Assign the value of a string object to an `mpf' object."
  },
  {
    .name		= "mmux-gmp-c-mpf-swap",
    .implementation	= Fmmux_emacs_gmp_c_mpf_swap,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Swap the values of two `mpf' objects."
  },

  /* Conversion functions */
  {
    .name		= "mmux-gmp-c-mpf-get-ui",
    .implementation	= Fmmux_emacs_gmp_c_mpf_get_ui,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Convert an object of type `mpf' to an unsigned exact integer number."
  },
  {
    .name		= "mmux-gmp-c-mpf-get-si",
    .implementation	= Fmmux_emacs_gmp_c_mpf_get_si,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Convert an object of type `mpf' to a signed exact integer number."
  },
  {
    .name		= "mmux-gmp-c-mpf-get-d",
    .implementation	= Fmmux_emacs_gmp_c_mpf_get_d,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Convert an object of type `mpf' to a floating-point number."
  },
  {
    .name		= "mmux-gmp-c-mpf-get-d-2exp",
    .implementation	= Fmmux_emacs_gmp_c_mpf_get_d_2exp,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Convert an object of type `mpf' to a floating-point number, returning the exponent separately."
  },
  {
    .name		= "mmux-gmp-c-mpf-get-str",
    .implementation	= Fmmux_emacs_gmp_c_mpf_get_str,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Convert an `mpf' object to a string."
  },

  /* Arithmetic functions. */
  { /* mpf_add (mpf_t ROP, const mpf_t OP1, const mpf_t OP2) */
    .name		= "mmux-gmp-c-mpf-add",
    .implementation	= Fmmux_emacs_gmp_c_mpf_add,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set ROP to OP1 + OP2.",
  },
  { /* mpf_add_ui (mpf_t ROP, const mpf_t OP1, unsigned long int OP2) */
    .name		= "mmux-gmp-c-mpf-add-ui",
    .implementation	= Fmmux_emacs_gmp_c_mpf_add_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set ROP to OP1 + OP2.",
  },
  { /* void mpf_sub (mpf_t ROP, const mpf_t OP1, const mpf_t OP2) */
    .name		= "mmux-gmp-c-mpf-sub",
    .implementation	= Fmmux_emacs_gmp_c_mpf_sub,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set ROP to OP1 - OP2.",
  },
  { /* void mpf_ui_sub (mpf_t ROP, unsigned long int OP1, const mpf_t OP2) */
    .name		= "mmux-gmp-c-mpf-ui-sub",
    .implementation	= Fmmux_emacs_gmp_c_mpf_ui_sub,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set ROP to OP1 - OP2.",
  },
  { /* void mpf_sub_ui (mpf_t ROP, const mpf_t OP1, unsigned long int OP2) */
    .name		= "mmux-gmp-c-mpf-sub-ui",
    .implementation	= Fmmux_emacs_gmp_c_mpf_sub_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set ROP to OP1 - OP2.",
  },
  { /* void mpf_mul (mpf_t ROP, const mpf_t OP1, const mpf_t OP2) */
    .name		= "mmux-gmp-c-mpf-mul",
    .implementation	= Fmmux_emacs_gmp_c_mpf_mul,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set ROP to OP1 times OP2.",
  },
  { /* void mpf_mul_ui (mpf_t ROP, const mpf_t OP1, unsigned long int OP2) */
    .name		= "mmux-gmp-c-mpf-mul-ui",
    .implementation	= Fmmux_emacs_gmp_c_mpf_mul_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set ROP to OP1 times OP2.",
  },
  { /* void mpf_div (mpf_t ROP, const mpf_t OP1, const mpf_t OP2) */
    .name		= "mmux-gmp-c-mpf-div",
    .implementation	= Fmmux_emacs_gmp_c_mpf_div,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set ROP to OP1/OP2.",
  },
  { /* void mpf_ui_div (mpf_t ROP, unsigned long int OP1, const mpf_t OP2) */
    .name		= "mmux-gmp-c-mpf-ui-div",
    .implementation	= Fmmux_emacs_gmp_c_mpf_ui_div,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set ROP to OP1/OP2.",
  },
  { /* void mpf_div_ui (mpf_t ROP, const mpf_t OP1, unsigned long int OP2) */
    .name		= "mmux-gmp-c-mpf-div-ui",
    .implementation	= Fmmux_emacs_gmp_c_mpf_div_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set ROP to OP1/OP2.",
  },
  { /* void mpf_sqrt (mpf_t ROP, const mpf_t OP) */
    .name		= "mmux-gmp-c-mpf-sqrt",
    .implementation	= Fmmux_emacs_gmp_c_mpf_sqrt,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Set ROP to the square root of OP.",
  },
  { /* void mpf_sqrt_ui (mpf_t ROP, unsigned long int OP) */
    .name		= "mmux-gmp-c-mpf-sqrt-ui",
    .implementation	= Fmmux_emacs_gmp_c_mpf_sqrt_ui,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Set ROP to the square root of OP.",
  },
  { /* void mpf_pow_ui (mpf_t ROP, const mpf_t OP1, unsigned long int OP2) */
    .name		= "mmux-gmp-c-mpf-pow-ui",
    .implementation	= Fmmux_emacs_gmp_c_mpf_pow_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set ROP to OP1 raised to the power OP2.",
  },
  { /* void mpf_neg (mpf_t ROP, const mpf_t OP) */
    .name		= "mmux-gmp-c-mpf-neg",
    .implementation	= Fmmux_emacs_gmp_c_mpf_neg,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Set ROP to -OP.",
  },
  { /* void mpf_abs (mpf_t ROP, const mpf_t OP) */
    .name		= "mmux-gmp-c-mpf-abs",
    .implementation	= Fmmux_emacs_gmp_c_mpf_abs,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Set ROP to the absolute value of OP.",
  },
  { /* void mpf_mul_2exp (mpf_t ROP, const mpf_t OP1, mp_bitcnt_t OP2) */
    .name		= "mmux-gmp-c-mpf-mul-2exp",
    .implementation	= Fmmux_emacs_gmp_c_mpf_mul_2exp,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set ROP to OP1 times 2 raised to OP2.",
  },
  { /* void mpf_div_2exp (mpf_t ROP, const mpf_t OP1, mp_bitcnt_t OP2) */
    .name		= "mmux-gmp-c-mpf-div-2exp",
    .implementation	= Fmmux_emacs_gmp_c_mpf_div_2exp,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set ROP to OP1 divided by 2 raised to OP2.",
  },

  /* Comparison functions. */
  { /* int mpf_cmp (const mpf_t OP1, const mpf_t OP2) */
    .name		= "mmux-gmp-c-mpf-cmp",
    .implementation	= Fmmux_emacs_gmp_c_mpf_cmp,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Compare OP1 and OP2.",
  },
  { /* int mpf_cmp_z (const mpf_t OP1, const mpz_t OP2) */
    .name		= "mmux-gmp-c-mpf-cmp-z",
    .implementation	= Fmmux_emacs_gmp_c_mpf_cmp_z,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Compare OP1 and OP2.",
  },
  { /* int mpf_cmp_d (const mpf_t OP1, double OP2) */
    .name		= "mmux-gmp-c-mpf-cmp-d",
    .implementation	= Fmmux_emacs_gmp_c_mpf_cmp_d,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Compare OP1 and OP2.",
  },
  { /* int mpf_cmp_ui (const mpf_t OP1, unsigned long int OP2) */
    .name		= "mmux-gmp-c-mpf-cmp-ui",
    .implementation	= Fmmux_emacs_gmp_c_mpf_cmp_ui,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Compare OP1 and OP2.",
  },
  { /* int mpf_cmp_si (const mpf_t OP1, long int OP2) */
    .name		= "mmux-gmp-c-mpf-cmp-si",
    .implementation	= Fmmux_emacs_gmp_c_mpf_cmp_si,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Compare OP1 and OP2.",
  },
  { /* int mpf_sgn (const mpf_t OP) */
    .name		= "mmux-gmp-c-mpf-sgn",
    .implementation	= Fmmux_emacs_gmp_c_mpf_sgn,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Return +1 if OP > 0, 0 if OP = 0, and -1 if OP < 0.",
  },
  { /* int mpf_reldiff (mpf_t ROP, const mpf_t OP1, const mpf_t OP2) */
    .name		= "mmux-gmp-c-mpf-reldiff",
    .implementation	= Fmmux_emacs_gmp_c_mpf_reldiff,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Compute the relative difference between OP1 and OP2 and store the result in ROP.  This is abs(OP1-OP2)/OP1.",
  },

  /* Miscellaneous functions. */
  { /* void mpf_ceil (mpf_t ROP, const mpf_t OP) */
    .name		= "mmux-gmp-c-mpf-ceil",
    .implementation	= Fmmux_emacs_gmp_c_mpf_ceil,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Set ROP to OP rounded to an integer.",
  },
  { /* void mpf_floor (mpf_t ROP, const mpf_t OP) */
    .name		= "mmux-gmp-c-mpf-floor",
    .implementation	= Fmmux_emacs_gmp_c_mpf_floor,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Set ROP to OP rounded to an integer.",
  },
  { /* void mpf_trunc (mpf_t ROP, const mpf_t OP) */
    .name		= "mmux-gmp-c-mpf-trunc",
    .implementation	= Fmmux_emacs_gmp_c_mpf_trunc,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Set ROP to OP rounded to an integer.",
  },
  { /* int mpf_integer_p (const mpf_t OP) */
    .name		= "mmux-gmp-c-mpf-integer-p",
    .implementation	= Fmmux_emacs_gmp_c_mpf_integer_p,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Return true if OP is an integer.",
  },
  { /* int mpf_fits_ulong_p (const mpf_t OP) */
    .name		= "mmux-gmp-c-mpf-fits-ulong-p",
    .implementation	= Fmmux_emacs_gmp_c_mpf_fits_ulong_p,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Return true if OP would fit in the respective C data type, when truncated to an integer.",
  },
  { /* int mpf_fits_slong_p (const mpf_t OP) */
    .name		= "mmux-gmp-c-mpf-fits-slong-p",
    .implementation	= Fmmux_emacs_gmp_c_mpf_fits_slong_p,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Return true if OP would fit in the respective C data type, when truncated to an integer.",
  },
  { /* int mpf_fits_uint_p (const mpf_t OP) */
    .name		= "mmux-gmp-c-mpf-fits-uint-p",
    .implementation	= Fmmux_emacs_gmp_c_mpf_fits_uint_p,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Return true if OP would fit in the respective C data type, when truncated to an integer.",
  },
  { /* int mpf_fits_sint_p (const mpf_t OP) */
    .name		= "mmux-gmp-c-mpf-fits-sint-p",
    .implementation	= Fmmux_emacs_gmp_c_mpf_fits_sint_p,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Return true if OP would fit in the respective C data type, when truncated to an integer.",
  },
  { /* int mpf_fits_ushort_p (const mpf_t OP) */
    .name		= "mmux-gmp-c-mpf-fits-ushort-p",
    .implementation	= Fmmux_emacs_gmp_c_mpf_fits_ushort_p,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Return true if OP would fit in the respective C data type, when truncated to an integer.",
  },
  { /* int mpf_fits_sshort_p (const mpf_t OP) */
    .name		= "mmux-gmp-c-mpf-fits-sshort-p",
    .implementation	= Fmmux_emacs_gmp_c_mpf_fits_sshort_p,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Return true if OP would fit in the respective C data type, when truncated to an integer.",
  },
  { /* void mpf_urandomb (mpf_t ROP, gmp_randstate_t STATE, mp_bitcnt_t NBITS) */
    .name		= "mmux-gmp-c-mpf-urandomb",
    .implementation	= Fmmux_emacs_gmp_c_mpf_urandomb,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Generate a uniformly distributed random float in ROP.",
  },
  { /* void mpf_random2 (mpf_t ROP, mp_size_t MAX_SIZE, mp_exp_t EXP) */
    .name		= "mmux-gmp-c-mpf-random2",
    .implementation	= Fmmux_emacs_gmp_c_mpf_random2,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Generate a random float of at most MAX-SIZE limbs, with long strings of zeros and ones in the binary representation.",
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
