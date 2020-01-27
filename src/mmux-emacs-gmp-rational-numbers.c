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
  mpq_ptr	rop = mmux_get_mpq(env, args[0]);
  mpq_ptr	op  = mmux_get_mpq(env, args[1]);

  mpq_set(rop, op);
  return env->intern(env, "nil");
}

/* void mpq_set_si (mpq_t ROP, signed long int OP1, unsigned long int OP2) */
static emacs_value
Fmmux_gmp_c_mpq_set_si (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpq_ptr	rop = mmux_get_mpq(env, args[0]);
  mmux_slint_t	op1 = mmux_get_slint(env, args[1]);
  mmux_ulint_t	op2 = mmux_get_ulint(env, args[2]);

  mpq_set_si(rop, op1, op2);
  return env->intern(env, "nil");
}

/* void mpq_set_ui (mpq_t ROP, unsigned long int OP1, unsigned long int OP2) */
static emacs_value
Fmmux_gmp_c_mpq_set_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpq_ptr	rop = mmux_get_mpq(env, args[0]);
  mmux_ulint_t	op1 = mmux_get_ulint(env, args[1]);
  mmux_ulint_t	op2 = mmux_get_ulint(env, args[2]);

  mpq_set_ui(rop, op1, op2);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpq_set_d (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpq_ptr	rop = mmux_get_mpq(env, args[0]);
  double	op  = mmux_get_float(env, args[1]);

  mpq_set_d(rop, op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpq_set_z (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpq_ptr	rop = mmux_get_mpq(env, args[0]);
  mpz_ptr	op  = mmux_get_mpz(env, args[1]);

  mpq_set_z(rop, op);
  return env->intern(env, "nil");
}

static emacs_value
Fmmux_gmp_c_mpq_set_f (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpq_ptr	rop = mmux_get_mpq(env, args[0]);
  mpf_ptr	op  = mmux_get_mpf(env, args[1]);

  mpq_set_f(rop, op);
  return env->intern(env, "nil");
}

/* int mpq_set_str (mpq_t ROP, const char *STR, int BASE) */
static emacs_value
Fmmux_gmp_c_mpq_set_str (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpq_ptr	rop  = mmux_get_mpq(env, args[0]);
  mmux_sint_t	base = mmux_get_sint(env, args[2]);
  ptrdiff_t	len  = 0;

  env->copy_string_contents(env, args[1], NULL, &len);
  if (len <= 4096) {
    char	buf[len];
    int		rv;

    env->copy_string_contents(env, args[1], buf, &len);
    rv = mpq_set_str(rop, buf, base);
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
  mpq_ptr	op1 = mmux_get_mpq(env, args[0]);
  mpq_ptr	op2 = mmux_get_mpq(env, args[1]);

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
  mpq_ptr	op   = mmux_get_mpq(env, args[0]);

  return env->make_float(env, mpq_get_d(op));
}

static emacs_value
Fmmux_gmp_c_mpq_get_str (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			 emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  intmax_t	base = mmux_get_int(env, args[0]);
  mpq_ptr	op   = mmux_get_mpq(env, args[1]);

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

/* void mpq_add (mpq_t SUM, const mpq_t ADDEND1, const mpq_t ADDEND2) */
static emacs_value
Fmmux_gmp_c_mpq_add (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpq_ptr	rop = mmux_get_mpq(env, args[0]);
  mpq_ptr	op1 = mmux_get_mpq(env, args[1]);
  mpq_ptr	op2 = mmux_get_mpq(env, args[2]);

  mpq_add(rop, op1, op2);
  return env->intern(env, "nil");
}

/* void mpq_sub (mpq_t DIFFERENCE, const mpq_t MINUEND, const mpq_t SUBTRAHEND) */
static emacs_value
Fmmux_gmp_c_mpq_sub (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpq_ptr	difference	= mmux_get_mpq(env, args[0]);
  mpq_ptr	minuend		= mmux_get_mpq(env, args[1]);
  mpq_ptr	subtrahend	= mmux_get_mpq(env, args[2]);

  mpq_sub(difference, minuend, subtrahend);
  return env->intern(env, "nil");
}

/* void mpq_mul (mpq_t PRODUCT, const mpq_t MULTIPLIER, const mpq_t MULTIPLICAND) */
static emacs_value
Fmmux_gmp_c_mpq_mul (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpq_ptr	product		= mmux_get_mpq(env, args[0]);
  mpq_ptr	multiplier	= mmux_get_mpq(env, args[1]);
  mpq_ptr	multiplicand	= mmux_get_mpq(env, args[2]);

  mpq_mul(product, multiplier, multiplicand);
  return env->intern(env, "nil");
}

/* void mpq_mul_2exp (mpq_t ROP, const mpq_t OP1, mp_bitcnt_t OP2) */
static emacs_value
Fmmux_gmp_c_mpq_mul_2exp (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpq_ptr	rop = mmux_get_mpq(env, args[0]);
  mpq_ptr	op1 = mmux_get_mpq(env, args[1]);
  mp_bitcnt_t	op2 = mmux_get_bitcnt(env, args[2]);

  mpq_mul_2exp(rop, op1, op2);
  return env->intern(env, "nil");
}

/* void mpq_div (mpq_t QUOTIENT, const mpq_t DIVIDEND, const mpq_t DIVISOR) */
static emacs_value
Fmmux_gmp_c_mpq_div (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpq_ptr	quotient	= mmux_get_mpq(env, args[0]);
  mpq_ptr	dividend	= mmux_get_mpq(env, args[1]);
  mpq_ptr	divisor		= mmux_get_mpq(env, args[2]);

  mpq_div(quotient, dividend, divisor);
  return env->intern(env, "nil");
}

/* void mpq_div_2exp (mpq_t ROP, const mpq_t OP1, mp_bitcnt_t OP2) */
static emacs_value
Fmmux_gmp_c_mpq_div_2exp (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpq_ptr	rop = mmux_get_mpq(env, args[0]);
  mpq_ptr	op1 = mmux_get_mpq(env, args[1]);
  mp_bitcnt_t	op2 = mmux_get_bitcnt(env, args[2]);

  mpq_div_2exp(rop, op1, op2);
  return env->intern(env, "nil");
}

/* void mpq_neg (mpq_t NEGATED_OPERAND, const mpq_t OPERAND) */
static emacs_value
Fmmux_gmp_c_mpq_neg (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpq_ptr	negated_operand	= mmux_get_mpq(env, args[0]);
  mpq_ptr	operand		= mmux_get_mpq(env, args[1]);

  mpq_neg(negated_operand, operand);
  return env->intern(env, "nil");
}

/* void mpq_abs (mpq_t ROP, const mpq_t OP) */
static emacs_value
Fmmux_gmp_c_mpq_abs (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpq_ptr	rop = mmux_get_mpq(env, args[0]);
  mpq_ptr	op  = mmux_get_mpq(env, args[1]);

  mpq_abs(rop, op);
  return env->intern(env, "nil");
}

/* void mpq_inv (mpq_t INVERTED_NUMBER, const mpq_t NUMBER) */
static emacs_value
Fmmux_gmp_c_mpq_inv (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpq_ptr	inverted_number	= mmux_get_mpq(env, args[0]);
  mpq_ptr	number		= mmux_get_mpq(env, args[1]);

  mpq_inv(inverted_number, number);
  return env->intern(env, "nil");
}


/** --------------------------------------------------------------------
 ** Comparison functions.
 ** ----------------------------------------------------------------- */

/* int mpq_cmp (const mpq_t OP1, const mpq_t OP2) */
static emacs_value
Fmmux_gmp_c_mpq_cmp (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpq_ptr	op1 = mmux_get_mpq(env, args[0]);
  mpq_ptr	op2 = mmux_get_mpq(env, args[1]);

  return mmux_make_int(env, mpq_cmp(op1, op2));
}

/* int mpq_cmp_z (const mpq_t OP1, const mpz_t OP2) */
static emacs_value
Fmmux_gmp_c_mpq_cmp_z (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpq_ptr	op1 = mmux_get_mpq(env, args[0]);
  mpz_ptr	op2 = mmux_get_mpz(env, args[1]);

  return mmux_make_int(env, mpq_cmp_z(op1, op2));
}

/* int mpq_cmp_ui (const mpq_t OP1, unsigned long int NUM2, unsigned long int DEN2) */
static emacs_value
Fmmux_gmp_c_mpq_cmp_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpq_ptr	op1	= mmux_get_mpq(env, args[0]);
  mmux_ulint_t	num2	= mmux_get_ulint(env, args[1]);
  mmux_ulint_t	den2	= mmux_get_ulint(env, args[2]);

  return mmux_make_int(env, mpq_cmp_ui(op1, num2, den2));
}

/* int mpq_cmp_si (const mpq_t OP1, long int NUM2, unsigned long int DEN2) */
static emacs_value
Fmmux_gmp_c_mpq_cmp_si (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(3 == nargs);
  mpq_ptr	op1	= mmux_get_mpq(env, args[0]);
  mmux_slint_t	num2	= mmux_get_slint(env, args[1]);
  mmux_ulint_t	den2	= mmux_get_ulint(env, args[2]);

  return mmux_make_int(env, mpq_cmp_si(op1, num2, den2));
}

/* int mpq_sgn (const mpq_t OP) */
static emacs_value
Fmmux_gmp_c_mpq_sgn (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mpq_ptr	op	= mmux_get_mpq(env, args[0]);

  return mmux_make_int(env, mpq_sgn(op));
}

/* int mpq_equal (const mpq_t OP1, const mpq_t OP2) */
static emacs_value
Fmmux_gmp_c_mpq_equal (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mpq_ptr	op1	= mmux_get_mpq(env, args[0]);
  mpq_ptr	op2	= mmux_get_mpq(env, args[1]);

  return mmux_make_boolean(env, mpq_equal(op1, op2));
}


/** --------------------------------------------------------------------
 ** Elisp functions table.
 ** ----------------------------------------------------------------- */

#define NUMBER_OF_MODULE_FUNCTIONS	25
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
  { /* void mpq_sub (mpq_t DIFFERENCE, const mpq_t MINUEND, const mpq_t SUBTRAHEND) */
    .name		= "mmux-gmp-c-mpq-sub",
    .implementation	= Fmmux_gmp_c_mpq_sub,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set DIFFERENCE to MINUEND - SUBTRAHEND.",
  },
  { /* void mpq_mul (mpq_t PRODUCT, const mpq_t MULTIPLIER, const mpq_t MULTIPLICAND) */
    .name		= "mmux-gmp-c-mpq-mul",
    .implementation	= Fmmux_gmp_c_mpq_mul,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set PRODUCT to MULTIPLIER times MULTIPLICAND.",
  },
  { /* void mpq_mul_2exp (mpq_t ROP, const mpq_t OP1, mp_bitcnt_t OP2) */
    .name		= "mmux-gmp-c-mpq-mul-2exp",
    .implementation	= Fmmux_gmp_c_mpq_mul_2exp,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set ROP to OP1 times 2 raised to OP2.",
  },
  { /* void mpq_div (mpq_t QUOTIENT, const mpq_t DIVIDEND, const mpq_t DIVISOR) */
    .name		= "mmux-gmp-c-mpq-div",
    .implementation	= Fmmux_gmp_c_mpq_div,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set QUOTIENT to DIVIDEND/DIVISOR.",
  },
  { /* void mpq_div_2exp (mpq_t ROP, const mpq_t OP1, mp_bitcnt_t OP2) */
    .name		= "mmux-gmp-c-mpq-div-2exp",
    .implementation	= Fmmux_gmp_c_mpq_div_2exp,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set ROP to OP1 divided by 2 raised to OP2.",
  },
  { /* void mpq_neg (mpq_t NEGATED_OPERAND, const mpq_t OPERAND) */
    .name		= "mmux-gmp-c-mpq-neg",
    .implementation	= Fmmux_gmp_c_mpq_neg,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set NEGATED_OPERAND to -OPERAND.",
  },
  { /* void mpq_abs (mpq_t ROP, const mpq_t OP) */
    .name		= "mmux-gmp-c-mpq-abs",
    .implementation	= Fmmux_gmp_c_mpq_abs,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set ROP to the absolute value of OP.",
  },
  { /* void mpq_inv (mpq_t INVERTED_NUMBER, const mpq_t NUMBER) */
    .name		= "mmux-gmp-c-mpq-inv",
    .implementation	= Fmmux_gmp_c_mpq_inv,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Set INVERTED_NUMBER to 1/NUMBER.",
  },

  /* Comparison functions. */
  { /* int mpq_cmp (const mpq_t OP1, const mpq_t OP2) */
    .name		= "mmux-gmp-c-mpq-cmp",
    .implementation	= Fmmux_gmp_c_mpq_cmp,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Compare OP1 and OP2.",
  },
  { /* int mpq_cmp_z (const mpq_t OP1, const mpz_t OP2) */
    .name		= "mmux-gmp-c-mpq-cmp-z",
    .implementation	= Fmmux_gmp_c_mpq_cmp_z,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Compare OP1 and OP2.",
  },
  { /* int mpq_cmp_ui (const mpq_t OP1, unsigned long int NUM2, unsigned long int DEN2) */
    .name		= "mmux-gmp-c-mpq-cmp-ui",
    .implementation	= Fmmux_gmp_c_mpq_cmp_ui,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Compare OP1 and NUM2/DEN2.",
  },
  { /* int mpq_cmp_si (const mpq_t OP1, long int NUM2, unsigned long int DEN2) */
    .name		= "mmux-gmp-c-mpq-cmp-si",
    .implementation	= Fmmux_gmp_c_mpq_cmp_si,
    .min_arity		= 3,
    .max_arity		= 3,
    .documentation	= "Compare OP1 and NUM2/DEN2.",
  },
  { /* int mpq_sgn (const mpq_t OP) */
    .name		= "mmux-gmp-c-mpq-sgn",
    .implementation	= Fmmux_gmp_c_mpq_sgn,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Return +1 if OP > 0, 0 if OP = 0, and -1 if OP < 0.",
  },
  { /* int mpq_equal (const mpq_t OP1, const mpq_t OP2) */
    .name		= "mmux-gmp-c-mpq-equal",
    .implementation	= Fmmux_gmp_c_mpq_equal,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Return non-zero if OP1 and OP2 are equal, zero if they are non-equal.",
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
