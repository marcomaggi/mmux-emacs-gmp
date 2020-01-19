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
  mpz_ptr	rop = mmux_get_ptr(env, args[0]);
  mpz_ptr	op  = mmux_get_ptr(env, args[1]);

  mpz_set(rop, op);
  return mmux_make_nil(env);
}

static emacs_value
Fmmux_gmp_c_mpz_set_si (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	rop = mmux_get_ptr(env, args[0]);
  intmax_t	op  = mmux_get_int(env, args[1]);

  mpz_set_si(rop, (signed long int)op);
  return mmux_make_nil(env);
}

static emacs_value
Fmmux_gmp_c_mpz_set_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	rop = mmux_get_ptr(env, args[0]);
  intmax_t	op  = mmux_get_int(env, args[1]);

  mpz_set_ui(rop, (unsigned long int)op);
  return mmux_make_nil(env);
}

static emacs_value
Fmmux_gmp_c_mpz_set_d (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	rop = mmux_get_ptr(env, args[0]);
  double	op  = env->extract_float(env, args[1]);

  mpz_set_d(rop, op);
  return mmux_make_nil(env);
}

static emacs_value
Fmmux_gmp_c_mpz_set_q (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	rop = mmux_get_ptr(env, args[0]);
  mpq_ptr	op  = mmux_get_ptr(env, args[1]);

  mpz_set_q(rop, op);
  return mmux_make_nil(env);
}

static emacs_value
Fmmux_gmp_c_mpz_set_f (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	rop = mmux_get_ptr(env, args[0]);
  mpf_ptr	op  = mmux_get_ptr(env, args[1]);

  mpz_set_f(rop, op);
  return mmux_make_nil(env);
}

static emacs_value
Fmmux_gmp_c_mpz_set_str (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop  = mmux_get_ptr    (env, args[0]);
  intmax_t	base = mmux_get_int (env, args[2]);
  ptrdiff_t	len  = 0;

  env->copy_string_contents(env, args[1], NULL, &len);
  if (len <= 4096) {
    char	buf[len];
    int		rv;

    env->copy_string_contents(env, args[1], buf, &len);
    rv = mpz_set_str(rop, buf, (int)base);
    return mmux_make_int(env, rv);
  } else {
    char const *	errmsg  = "input string exceeds maximum length";
    emacs_value		Serrmsg = env->make_string(env, errmsg, strlen(errmsg));

    /* Signal an error,  then immediately return.  In the "elisp"  Info file: see the
       node "Standard Errors" for a list of  the standard error symbols; see the node
       "Error Symbols"  for methods to define  error symbols.  (Marco Maggi;  Jan 14,
       2020) */
    env->non_local_exit_signal(env, env->intern(env, MMUX_EMAC_GMP_ERROR_STRING_TOO_LONG), Serrmsg);
    return mmux_make_nil(env);
  }
}

static emacs_value
Fmmux_gmp_c_mpz_swap (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	op1 = mmux_get_ptr(env, args[0]);
  mpz_ptr	op2 = mmux_get_ptr(env, args[1]);

  mpz_swap(op1, op2);
  return mmux_make_nil(env);
}


/** --------------------------------------------------------------------
 ** Conversion functions.
 ** ----------------------------------------------------------------- */

static emacs_value
Fmmux_gmp_c_mpz_get_ui (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpz_ptr	op   = mmux_get_ptr    (env, args[0]);

  return mmux_make_int(env, (intmax_t)mpz_get_ui(op));
}

static emacs_value
Fmmux_gmp_c_mpz_get_si (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpz_ptr	op   = mmux_get_ptr    (env, args[0]);

  return mmux_make_int(env, (intmax_t)mpz_get_si(op));
}

static emacs_value
Fmmux_gmp_c_mpz_get_d (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpz_ptr	op   = mmux_get_ptr    (env, args[0]);

  return env->make_float(env, (intmax_t)mpz_get_d(op));
}

static emacs_value
Fmmux_gmp_c_mpz_get_d_2exp (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			    emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpz_ptr	op   = mmux_get_ptr    (env, args[0]);
  double	rv;
  mp_exp_t	exponent;

  rv = mpz_get_d_2exp(&exponent, op);
  {
    emacs_value Qcons       = env->intern(env, "cons");
    emacs_value operands[2] = {
      env->make_float(env, rv),
      mmux_make_int(env, (intmax_t)exponent)
    };

    return env->funcall(env, Qcons, 2, operands);
  }
}

static emacs_value
Fmmux_gmp_c_mpz_get_str (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			 emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  intmax_t	base = mmux_get_int (env, args[0]);
  mpz_ptr	op   = mmux_get_ptr    (env, args[1]);

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
  mpz_ptr	rop = mmux_get_mpz(env, args[0]);
  mpz_ptr	op1 = mmux_get_mpz(env, args[1]);
  mpz_ptr	op2 = mmux_get_mpz(env, args[2]);

  mpz_add(rop, op1, op2);
  return mmux_make_nil(env);
}

static emacs_value
Fmmux_gmp_c_mpz_add_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = mmux_get_mpz(env, args[0]);
  mpz_ptr	op1 = mmux_get_mpz(env, args[1]);
  intmax_t	op2 = mmux_get_int(env, args[2]);

  mpz_add_ui(rop, op1, (unsigned long int)op2);
  return mmux_make_nil(env);
}

/* ------------------------------------------------------------------ */

static emacs_value
Fmmux_gmp_c_mpz_sub (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = mmux_get_mpz(env, args[0]);
  mpz_ptr	op1 = mmux_get_mpz(env, args[1]);
  mpz_ptr	op2 = mmux_get_mpz(env, args[2]);

  mpz_sub(rop, op1, op2);
  return mmux_make_nil(env);
}

static emacs_value
Fmmux_gmp_c_mpz_sub_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = mmux_get_mpz(env, args[0]);
  mpz_ptr	op1 = mmux_get_mpz(env, args[1]);
  intmax_t	op2 = mmux_get_int(env, args[2]);

  mpz_sub_ui(rop, op1, (unsigned long int)op2);
  return mmux_make_nil(env);
}

/* ------------------------------------------------------------------ */

static emacs_value
Fmmux_gmp_c_mpz_addmul (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = mmux_get_mpz(env, args[0]);
  mpz_ptr	op1 = mmux_get_mpz(env, args[1]);
  mpz_ptr	op2 = mmux_get_mpz(env, args[2]);

  mpz_addmul(rop, op1, op2);
  return mmux_make_nil(env);
}

static emacs_value
Fmmux_gmp_c_mpz_addmul_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = mmux_get_mpz(env, args[0]);
  mpz_ptr	op1 = mmux_get_mpz(env, args[1]);
  intmax_t	op2 = mmux_get_int(env, args[2]);

  mpz_addmul_ui(rop, op1, (unsigned long int)op2);
  return mmux_make_nil(env);
}

/* ------------------------------------------------------------------ */

static emacs_value
Fmmux_gmp_c_mpz_submul (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = mmux_get_mpz(env, args[0]);
  mpz_ptr	op1 = mmux_get_mpz(env, args[1]);
  mpz_ptr	op2 = mmux_get_mpz(env, args[2]);

  mpz_submul(rop, op1, op2);
  return mmux_make_nil(env);
}

static emacs_value
Fmmux_gmp_c_mpz_submul_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = mmux_get_mpz(env, args[0]);
  mpz_ptr	op1 = mmux_get_mpz(env, args[1]);
  intmax_t	op2 = mmux_get_int(env, args[2]);

  mpz_submul_ui(rop, op1, (unsigned long int)op2);
  return mmux_make_nil(env);
}

/* ------------------------------------------------------------------ */

static emacs_value
Fmmux_gmp_c_mpz_mul (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = mmux_get_mpz(env, args[0]);
  mpz_ptr	op1 = mmux_get_mpz(env, args[1]);
  mpz_ptr	op2 = mmux_get_mpz(env, args[2]);

  mpz_mul(rop, op1, op2);
  return mmux_make_nil(env);
}

static emacs_value
Fmmux_gmp_c_mpz_mul_si (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = mmux_get_mpz(env, args[0]);
  mpz_ptr	op1 = mmux_get_mpz(env, args[1]);
  intmax_t	op2 = mmux_get_int(env, args[2]);

  mpz_mul_si(rop, op1, (signed long int)op2);
  return mmux_make_nil(env);
}

static emacs_value
Fmmux_gmp_c_mpz_mul_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = mmux_get_mpz(env, args[0]);
  mpz_ptr	op1 = mmux_get_mpz(env, args[1]);
  intmax_t	op2 = mmux_get_int(env, args[2]);

  mpz_mul_ui(rop, op1, (unsigned long int)op2);
  return mmux_make_nil(env);
}

/* ------------------------------------------------------------------ */

static emacs_value
Fmmux_gmp_c_mpz_mul_2exp (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	rop = mmux_get_mpz(env, args[0]);
  mpz_ptr	op1 = mmux_get_mpz(env, args[1]);
  intmax_t	op2 = mmux_get_int(env, args[2]);

  mpz_mul_2exp(rop, op1, (mp_bitcnt_t)op2);
  return mmux_make_nil(env);
}

static emacs_value
Fmmux_gmp_c_mpz_neg (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	rop = mmux_get_mpz(env, args[0]);
  mpz_ptr	op  = mmux_get_mpz(env, args[1]);

  mpz_neg(rop, op);
  return mmux_make_nil(env);
}

static emacs_value
Fmmux_gmp_c_mpz_abs (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	rop = mmux_get_mpz(env, args[0]);
  mpz_ptr	op  = mmux_get_mpz(env, args[1]);

  mpz_abs(rop, op);
  return mmux_make_nil(env);
}


/** --------------------------------------------------------------------
 ** Division functions.
 ** ----------------------------------------------------------------- */

/* void mpz_cdiv_q (mpz_t Q, const mpz_t N, const mpz_t D) */
static emacs_value
Fmmux_gmp_c_cdiv_q (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	Q = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mpz_ptr	D = mmux_get_mpz(env, args[2]);

  mpz_cdiv_q(Q, N, D);
  return mmux_make_nil(env);
}

/* void mpz_cdiv_r (mpz_t R, const mpz_t N, const mpz_t D) */
static emacs_value
Fmmux_gmp_c_cdiv_r (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	R = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mpz_ptr	D = mmux_get_mpz(env, args[2]);

  mpz_cdiv_r(R, N, D);
  return mmux_make_nil(env);
}

/* void mpz_cdiv_qr (mpz_t Q, mpz_t R, const mpz_t N, const mpz_t D) */
static emacs_value
Fmmux_gmp_c_cdiv_qr (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(4 == nargs);
  mpz_ptr	Q = mmux_get_mpz(env, args[0]);
  mpz_ptr	R = mmux_get_mpz(env, args[1]);
  mpz_ptr	N = mmux_get_mpz(env, args[2]);
  mpz_ptr	D = mmux_get_mpz(env, args[3]);

  mpz_cdiv_qr(Q, R, N, D);
  return mmux_make_nil(env);
}

/* ------------------------------------------------------------------ */

/* unsigned long int mpz_cdiv_q_ui (mpz_t Q, const mpz_t N, unsigned long int D) */
static emacs_value
Fmmux_gmp_c_cdiv_q_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	Q = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mmux_ulint_t	D = mmux_get_ulint(env, args[2]);

  return mmux_make_int(env, mpz_cdiv_q_ui(Q, N, D));
}

/* unsigned long int mpz_cdiv_r_ui (mpz_t R, const mpz_t N, unsigned long int D) */
static emacs_value
Fmmux_gmp_c_cdiv_r_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	Q = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mmux_ulint_t	D = mmux_get_ulint(env, args[2]);

  return mmux_make_int(env, mpz_cdiv_r_ui(Q, N, D));
}

/* unsigned long int mpz_cdiv_qr_ui (mpz_t Q, mpz_t R, const mpz_t N, unsigned long int D) */
static emacs_value
Fmmux_gmp_c_cdiv_qr_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(4 == nargs);
  mpz_ptr	Q = mmux_get_mpz(env, args[0]);
  mpz_ptr	R = mmux_get_mpz(env, args[1]);
  mpz_ptr	N = mmux_get_mpz(env, args[2]);
  mmux_ulint_t	D = mmux_get_ulint(env, args[3]);

  return mmux_make_int(env, mpz_cdiv_qr_ui(Q, R, N, D));
}

/* unsigned long int mpz_cdiv_ui (const mpz_t N, unsigned long int D) */
static emacs_value
Fmmux_gmp_c_cdiv_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	N = mmux_get_mpz(env, args[2]);
  mmux_ulint_t	D = mmux_get_ulint(env, args[3]);

  return mmux_make_int(env, mpz_cdiv_ui(N, D));
}

/* ------------------------------------------------------------------ */

/* void mpz_cdiv_q_2exp (mpz_t Q, const mpz_t N, mp_bitcnt_t B) */
static emacs_value
Fmmux_gmp_c_cdiv_q_2exp (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	Q = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mp_bitcnt_t	B = mmux_get_bitcnt(env, args[2]);

  mpz_cdiv_q_2exp(Q, N, B);
  return mmux_make_nil(env);
}

/* void mpz_cdiv_r_2exp (mpz_t R, const mpz_t N, mp_bitcnt_t B) */
static emacs_value
Fmmux_gmp_c_cdiv_2_2exp (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	R = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mp_bitcnt_t	B = mmux_get_bitcnt(env, args[2]);

  mpz_cdiv_r_2exp(R, N, B);
  return mmux_make_nil(env);
}

/* ------------------------------------------------------------------ */

/* void mpz_fdiv_q (mpz_t Q, const mpz_t N, const mpz_t D) */
static emacs_value
Fmmux_gmp_c_fdiv_q (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	Q = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mpz_ptr	D = mmux_get_mpz(env, args[2]);

  mpz_fdiv_q(Q, N, D);
  return mmux_make_nil(env);
}

/* void mpz_fdiv_r (mpz_t R, const mpz_t N, const mpz_t D) */
static emacs_value
Fmmux_gmp_c_fdiv_r (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	R = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mpz_ptr	D = mmux_get_mpz(env, args[2]);

  mpz_fdiv_r(R, N, D);
  return mmux_make_nil(env);
}

/* void mpz_fdiv_qr (mpz_t Q, mpz_t R, const mpz_t N, const mpz_t D) */
static emacs_value
Fmmux_gmp_c_fdiv_qr (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(4 == nargs);
  mpz_ptr	Q = mmux_get_mpz(env, args[0]);
  mpz_ptr	R = mmux_get_mpz(env, args[1]);
  mpz_ptr	N = mmux_get_mpz(env, args[2]);
  mpz_ptr	D = mmux_get_mpz(env, args[3]);

  mpz_fdiv_qr(Q, R, N, D);
  return mmux_make_nil(env);
}

/* unsigned long int mpz_fdiv_q_ui (mpz_t Q, const mpz_t N, unsigned long int D) */
static emacs_value
Fmmux_gmp_c_fdiv_q_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	Q = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mmux_ulint_t	D = mmux_get_ulint(env, args[2]);

  return mmux_make_int(env, mpz_fdiv_q_ui(Q, N, D));
}

/* unsigned long int mpz_fdiv_r_ui (mpz_t R, const mpz_t N, unsigned long int D) */
static emacs_value
Fmmux_gmp_c_fdiv_r_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	R = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mmux_ulint_t	D = mmux_get_ulint(env, args[2]);

  return mmux_make_int(env, mpz_fdiv_r_ui(R, N, D));
}

/* unsigned long int mpz_fdiv_qr_ui (mpz_t Q, mpz_t R, const mpz_t N, unsigned long int D) */
static emacs_value
Fmmux_gmp_c_fdiv_qr_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	Q = mmux_get_mpz(env, args[0]);
  mpz_ptr	R = mmux_get_mpz(env, args[1]);
  mpz_ptr	N = mmux_get_mpz(env, args[2]);
  mmux_ulint_t	D = mmux_get_ulint(env, args[3]);

  return mmux_make_int(env, mpz_fdiv_qr_ui(Q, R, N, D));
}

/* unsigned long int mpz_fdiv_ui (const mpz_t N, unsigned long int D) */
static emacs_value
Fmmux_gmp_c_fdiv_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	N = mmux_get_mpz(env, args[0]);
  mmux_ulint_t	D = mmux_get_ulint(env, args[1]);

  return mmux_make_int(env, mpz_fdiv_ui(N, D));
}

/* void mpz_fdiv_q_2exp (mpz_t Q, const mpz_t N, mp_bitcnt_t B) */
static emacs_value
Fmmux_gmp_c_fdiv_q_2exp (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	Q = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mp_bitcnt_t	B = mmux_get_bitcnt(env, args[2]);

  mpz_fdiv_q_2exp(Q, N, B);
  return mmux_make_nil(env);
}

/* void mpz_fdiv_r_2exp (mpz_t R, const mpz_t N, mp_bitcnt_t B) */
static emacs_value
Fmmux_gmp_c_fdiv_r_2exp (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	R = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mp_bitcnt_t	B = mmux_get_bitcnt(env, args[2]);

  mpz_fdiv_r_2exp(R, N, B);
  return mmux_make_nil(env);
}

/* ------------------------------------------------------------------ */

/* void mpz_tdiv_q (mpz_t Q, const mpz_t N, const mpz_t D) */
static emacs_value
Fmmux_gmp_c_tdiv_q (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	Q = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mpz_ptr	D = mmux_get_mpz(env, args[2]);

  mpz_tdiv_q(Q, N, D);
  return mmux_make_nil(env);
}

/* void mpz_tdiv_r (mpz_t R, const mpz_t N, const mpz_t D) */
static emacs_value
Fmmux_gmp_c_tdiv_r (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	R = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mpz_ptr	D = mmux_get_mpz(env, args[2]);

  mpz_tdiv_r(R, N, D);
  return mmux_make_nil(env);
}

/* void mpz_tdiv_qr (mpz_t Q, mpz_t R, const mpz_t N, const mpz_t D) */
static emacs_value
Fmmux_gmp_c_tdiv_qr (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(4 == nargs);
  mpz_ptr	Q = mmux_get_mpz(env, args[0]);
  mpz_ptr	R = mmux_get_mpz(env, args[1]);
  mpz_ptr	N = mmux_get_mpz(env, args[2]);
  mpz_ptr	D = mmux_get_mpz(env, args[3]);

  mpz_tdiv_qr(Q, R, N, D);
  return mmux_make_nil(env);
}

/* unsigned long int mpz_tdiv_q_ui (mpz_t Q, const mpz_t N, unsigned long int D) */
static emacs_value
Fmmux_gmp_c_tdiv_q_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	Q = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mmux_ulint_t	D = mmux_get_ulint(env, args[2]);

  return mmux_make_ulint(env, mpz_tdiv_q_ui(Q, N, D));
}

/* unsigned long int mpz_tdiv_r_ui (mpz_t R, const mpz_t N, unsigned long int D) */
static emacs_value
Fmmux_gmp_c_tdiv_r_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	R = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mmux_ulint_t	D = mmux_get_ulint(env, args[2]);

  return mmux_make_ulint(env, mpz_tdiv_r_ui(R, N, D));
}

/* unsigned long int mpz_tdiv_qr_ui (mpz_t Q, mpz_t R, const mpz_t N, unsigned long int D) */
static emacs_value
Fmmux_gmp_c_tdiv_qr_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(4 == nargs);
  mpz_ptr	Q = mmux_get_mpz(env, args[0]);
  mpz_ptr	R = mmux_get_mpz(env, args[1]);
  mpz_ptr	N = mmux_get_mpz(env, args[2]);
  mmux_ulint_t	D = mmux_get_ulint(env, args[3]);

  return mmux_make_ulint(env, mpz_tdiv_qr_ui(Q, R, N, D));
}

/* unsigned long int mpz_tdiv_ui (const mpz_t N, unsigned long int D) */
static emacs_value
Fmmux_gmp_c_tdiv_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	N = mmux_get_mpz(env, args[0]);
  mmux_ulint_t	D = mmux_get_ulint(env, args[1]);

  return mmux_make_ulint(env, mpz_tdiv_ui(N, D));
}

/* void mpz_tdiv_q_2exp (mpz_t Q, const mpz_t N, mp_bitcnt_t B) */
static emacs_value
Fmmux_gmp_c_tdiv_q_2exp (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	Q = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mp_bitcnt_t	B = mmux_get_bitcnt(env, args[2]);

  mpz_tdiv_q_2exp(Q, N, B);
  return mmux_make_nil(env);
}

/* void mpz_tdiv_r_2exp (mpz_t R, const mpz_t N, mp_bitcnt_t B) */
static emacs_value
Fmmux_gmp_c_tdiv_r_2exp (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	R = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mp_bitcnt_t	B = mmux_get_bitcnt(env, args[2]);

  mpz_tdiv_r_2exp(R, N, B);
  return mmux_make_nil(env);
}

/* ------------------------------------------------------------------ */

/* void mpz_mod (mpz_t R, const mpz_t N, const mpz_t D) */
static emacs_value
Fmmux_gmp_c_mod (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	R = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mpz_ptr	D = mmux_get_mpz(env, args[2]);

  mpz_mod(R, N, D);
  return mmux_make_nil(env);
}

/* unsigned long int mpz_mod_ui (mpz_t R, const mpz_t N, unsigned long int D) */
static emacs_value
Fmmux_gmp_c_mod_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	R = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mmux_ulint_t	D = mmux_get_ulint(env, args[2]);

  return mmux_make_ulint(env, mpz_mod_ui(R, N, D));
}

/* void mpz_divexact (mpz_t Q, const mpz_t N, const mpz_t D) */
static emacs_value
Fmmux_gmp_c_divexact (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	Q = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mpz_ptr	D = mmux_get_mpz(env, args[2]);

  mpz_divexact(Q, N, D);
  return mmux_make_nil(env);
}

/* void mpz_divexact_ui (mpz_t Q, const mpz_t N, unsigned long D) */
static emacs_value
Fmmux_gmp_c_divexact_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	Q = mmux_get_mpz(env, args[0]);
  mpz_ptr	N = mmux_get_mpz(env, args[1]);
  mmux_ulint_t	D = mmux_get_ulint(env, args[2]);

  mpz_divexact_ui(Q, N, D);
  return mmux_make_nil(env);
}

/* ------------------------------------------------------------------ */

/* int mpz_divisible_p (const mpz_t N, const mpz_t D) */
static emacs_value
Fmmux_gmp_c_divisible_p (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	N = mmux_get_mpz(env, args[0]);
  mpz_ptr	D = mmux_get_mpz(env, args[1]);

  return ((mpz_divisible_p(N, D))? mmux_make_true(env) : mmux_make_nil(env));
}

/* int mpz_divisible_ui_p (const mpz_t N, unsigned long int D) */
static emacs_value
Fmmux_gmp_c_divisible_ui_p (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	N = mmux_get_mpz(env, args[0]);
  mmux_ulint_t	D = mmux_get_ulint(env, args[1]);

  return ((mpz_divisible_ui_p(N, D))? mmux_make_true(env) : mmux_make_nil(env));
}

/* int mpz_divisible_2exp_p (const mpz_t N, mp_bitcnt_t B) */
static emacs_value
Fmmux_gmp_c_divisible_2exp_p (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	N = mmux_get_mpz(env, args[0]);
  mp_bitcnt_t	B = mmux_get_bitcnt(env, args[1]);

  return ((mpz_divisible_2exp_p(N, B))? mmux_make_true(env) : mmux_make_nil(env));
}

/* ------------------------------------------------------------------ */

/* int mpz_congruent_p (const mpz_t N, const mpz_t C, const mpz_t D) */
static emacs_value
Fmmux_gmp_c_congruent_p (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpz_ptr	N = mmux_get_mpz(env, args[0]);
  mpz_ptr	C = mmux_get_mpz(env, args[1]);
  mpz_ptr	D = mmux_get_mpz(env, args[2]);

  return ((mpz_congruent_p(N, C, D))? mmux_make_true(env) : mmux_make_nil(env));
}

/* int mpz_congruent_ui_p (const mpz_t N, unsigned long int C, unsigned long int D) */
static emacs_value
Fmmux_gmp_c_congruent_ui_p (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	N = mmux_get_mpz(env, args[0]);
  mmux_ulint_t	C = mmux_get_ulint(env, args[1]);
  mmux_ulint_t	D = mmux_get_ulint(env, args[2]);

  return ((mpz_congruent_ui_p(N, C, D))? mmux_make_true(env) : mmux_make_nil(env));
}

/* int mpz_congruent_2exp_p (const mpz_t N, const mpz_t C, mp_bitcnt_t B) */
static emacs_value
Fmmux_gmp_c_congruent_2exp_p (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpz_ptr	N = mmux_get_mpz(env, args[0]);
  mpz_ptr	C = mmux_get_mpz(env, args[1]);
  mp_bitcnt_t	B = mmux_get_bitcnt(env, args[1]);

  return ((mpz_congruent_2exp_p(N, C, B))? mmux_make_true(env) : mmux_make_nil(env));
}


/** --------------------------------------------------------------------
 ** Elisp functions table.
 ** ----------------------------------------------------------------- */

#define NUMBER_OF_MODULE_FUNCTIONS	64
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

  /* Division operations. */
  { /* void mpz_cdiv_q (mpz_t Q, const mpz_t N, const mpz_t D) */
    .name		= "mmux-gmp-c-cdiv-q",
    .implementation	= Fmmux_gmp_c_cdiv_q,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* void mpz_cdiv_r (mpz_t R, const mpz_t N, const mpz_t D) */
    .name		= "mmux-gmp-c-cdiv-r",
    .implementation	= Fmmux_gmp_c_cdiv_r,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* void mpz_cdiv_qr (mpz_t Q, mpz_t R, const mpz_t N, const mpz_t D) */
    .name		= "mmux-gmp-c-cdiv-qr",
    .implementation	= Fmmux_gmp_c_cdiv_qr,
    .min_arity		= 4,
    .max_arity		= 4,
    .documentation	= "",
  },
  { /* unsigned long int mpz_cdiv_q_ui (mpz_t Q, const mpz_t N, unsigned long int D) */
    .name		= "mmux-gmp-c-cdiv-q-ui",
    .implementation	= Fmmux_gmp_c_cdiv_q_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* unsigned long int mpz_cdiv_r_ui (mpz_t R, const mpz_t N, unsigned long int D) */
    .name		= "mmux-gmp-c-cdiv-r-ui",
    .implementation	= Fmmux_gmp_c_cdiv_r_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* unsigned long int mpz_cdiv_qr_ui (mpz_t Q, mpz_t R, const mpz_t N, unsigned long int D) */
    .name		= "mmux-gmp-c-cdiv-qr-ui",
    .implementation	= Fmmux_gmp_c_cdiv_qr_ui,
    .min_arity		= 4,
    .max_arity		= 4,
    .documentation	= "",
  },
  { /* unsigned long int mpz_cdiv_ui (const mpz_t N, unsigned long int D) */
    .name		= "mmux-gmp-c-cdiv-ui",
    .implementation	= Fmmux_gmp_c_cdiv_ui,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "",
  },
  { /* void mpz_cdiv_q_2exp (mpz_t Q, const mpz_t N, mp_bitcnt_t B) */
    .name		= "mmux-gmp-c-cdiv-q-2exp",
    .implementation	= Fmmux_gmp_c_cdiv_q_2exp,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* void mpz_cdiv_r_2exp (mpz_t R, const mpz_t N, mp_bitcnt_t B) */
    .name		= "mmux-gmp-c-cdiv-2-2exp",
    .implementation	= Fmmux_gmp_c_cdiv_2_2exp,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* void mpz_fdiv_q (mpz_t Q, const mpz_t N, const mpz_t D) */
    .name		= "mmux-gmp-c-fdiv-q",
    .implementation	= Fmmux_gmp_c_fdiv_q,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* void mpz_fdiv_r (mpz_t R, const mpz_t N, const mpz_t D) */
    .name		= "mmux-gmp-c-fdiv-r",
    .implementation	= Fmmux_gmp_c_fdiv_r,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* void mpz_fdiv_qr (mpz_t Q, mpz_t R, const mpz_t N, const mpz_t D) */
    .name		= "mmux-gmp-c-fdiv-qr",
    .implementation	= Fmmux_gmp_c_fdiv_qr,
    .min_arity		= 4,
    .max_arity		= 4,
    .documentation	= "",
  },
  { /* unsigned long int mpz_fdiv_q_ui (mpz_t Q, const mpz_t N, unsigned long int D) */
    .name		= "mmux-gmp-c-fdiv-q-ui",
    .implementation	= Fmmux_gmp_c_fdiv_q_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* unsigned long int mpz_fdiv_r_ui (mpz_t R, const mpz_t N, unsigned long int D) */
    .name		= "mmux-gmp-c-fdiv-r-ui",
    .implementation	= Fmmux_gmp_c_fdiv_r_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* unsigned long int mpz_fdiv_qr_ui (mpz_t Q, mpz_t R, const mpz_t N, unsigned long int D) */
    .name		= "mmux-gmp-c-fdiv-qr-ui",
    .implementation	= Fmmux_gmp_c_fdiv_qr_ui,
    .min_arity		= 4,
    .max_arity		= 4,
    .documentation	= "",
  },
  { /* unsigned long int mpz_fdiv_ui (const mpz_t N, unsigned long int D) */
    .name		= "mmux-gmp-c-fdiv-ui",
    .implementation	= Fmmux_gmp_c_fdiv_ui,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "",
  },
  { /* void mpz_fdiv_q_2exp (mpz_t Q, const mpz_t N, mp_bitcnt_t B) */
    .name		= "mmux-gmp-c-fdiv-q-2exp",
    .implementation	= Fmmux_gmp_c_fdiv_q_2exp,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* void mpz_fdiv_r_2exp (mpz_t R, const mpz_t N, mp_bitcnt_t B) */
    .name		= "mmux-gmp-c-fdiv-r-2exp",
    .implementation	= Fmmux_gmp_c_fdiv_r_2exp,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* void mpz_tdiv_q (mpz_t Q, const mpz_t N, const mpz_t D) */
    .name		= "mmux-gmp-c-tdiv-q",
    .implementation	= Fmmux_gmp_c_tdiv_q,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* void mpz_tdiv_r (mpz_t R, const mpz_t N, const mpz_t D) */
    .name		= "mmux-gmp-c-tdiv-r",
    .implementation	= Fmmux_gmp_c_tdiv_r,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* void mpz_tdiv_qr (mpz_t Q, mpz_t R, const mpz_t N, const mpz_t D) */
    .name		= "mmux-gmp-c-tdiv-qr",
    .implementation	= Fmmux_gmp_c_tdiv_qr,
    .min_arity		= 4,
    .max_arity		= 4,
    .documentation	= "",
  },
  { /* unsigned long int mpz_tdiv_q_ui (mpz_t Q, const mpz_t N, unsigned long int D) */
    .name		= "mmux-gmp-c-tdiv-q-ui",
    .implementation	= Fmmux_gmp_c_tdiv_q_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* unsigned long int mpz_tdiv_r_ui (mpz_t R, const mpz_t N, unsigned long int D) */
    .name		= "mmux-gmp-c-tdiv-r-ui",
    .implementation	= Fmmux_gmp_c_tdiv_r_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* unsigned long int mpz_tdiv_qr_ui (mpz_t Q, mpz_t R, const mpz_t N, unsigned long int D) */
    .name		= "mmux-gmp-c-tdiv-qr-ui",
    .implementation	= Fmmux_gmp_c_tdiv_qr_ui,
    .min_arity		= 4,
    .max_arity		= 4,
    .documentation	= "",
  },
  { /* unsigned long int mpz_tdiv_ui (const mpz_t N, unsigned long int D) */
    .name		= "mmux-gmp-c-tdiv-ui",
    .implementation	= Fmmux_gmp_c_tdiv_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* void mpz_tdiv_q_2exp (mpz_t Q, const mpz_t N, mp_bitcnt_t B) */
    .name		= "mmux-gmp-c-tdiv-q-2exp",
    .implementation	= Fmmux_gmp_c_tdiv_q_2exp,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* void mpz_tdiv_r_2exp (mpz_t R, const mpz_t N, mp_bitcnt_t B) */
    .name		= "mmux-gmp-c-tdiv-r-2exp",
    .implementation	= Fmmux_gmp_c_tdiv_r_2exp,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* void mpz_mod (mpz_t R, const mpz_t N, const mpz_t D) */
    .name		= "mmux-gmp-c-mod",
    .implementation	= Fmmux_gmp_c_mod,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* unsigned long int mpz_mod_ui (mpz_t R, const mpz_t N, unsigned long int D) */
    .name		= "mmux-gmp-c-mod-ui",
    .implementation	= Fmmux_gmp_c_mod_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* void mpz_divexact (mpz_t Q, const mpz_t N, const mpz_t D) */
    .name		= "mmux-gmp-c-divexact",
    .implementation	= Fmmux_gmp_c_divexact,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* void mpz_divexact_ui (mpz_t Q, const mpz_t N, unsigned long D) */
    .name		= "mmux-gmp-c-divexact-ui",
    .implementation	= Fmmux_gmp_c_divexact_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "",
  },
  { /* int mpz_divisible_p (const mpz_t N, const mpz_t D) */
    .name		= "mmux-gmp-c-divisible-p",
    .implementation	= Fmmux_gmp_c_divisible_p,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "",
  },
  { /* int mpz_divisible_ui_p (const mpz_t N, unsigned long int D) */
    .name		= "mmux-gmp-c-divisible-ui-p",
    .implementation	= Fmmux_gmp_c_divisible_ui_p,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "",
  },
  { /* int mpz_divisible_2exp_p (const mpz_t N, mp_bitcnt_t B) */
    .name		= "mmux-gmp-c-divisible-2exp-p",
    .implementation	= Fmmux_gmp_c_divisible_2exp_p,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "",
  },
  { /* int mpz_congruent_p (const mpz_t N, const mpz_t C, const mpz_t D) */
    .name		= "mmux-gmp-c-congruent-p",
    .implementation	= Fmmux_gmp_c_congruent_p,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "",
  },
  { /* int mpz_congruent_ui_p (const mpz_t N, unsigned long int C, unsigned long int D) */
    .name		= "mmux-gmp-c-congruent-ui-p",
    .implementation	= Fmmux_gmp_c_congruent_ui_p,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "",
  },
  { /* int mpz_congruent_2exp_p (const mpz_t N, const mpz_t C, mp_bitcnt_t B) */
    .name		= "mmux-gmp-c-congruent-2exp-p",
    .implementation	= Fmmux_gmp_c_congruent_2exp_p,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "",
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
