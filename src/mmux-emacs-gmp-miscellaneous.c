/*
  Part of: MMUX Emacs GMP
  Contents: miscellaneous functions
  Date: Jan 25, 2020

  Abstract

	This module implements adapters for miscellaneous functions.

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


/** --------------------------------------------------------------------
 ** Random state functions: initialisation.
 ** ----------------------------------------------------------------- */

/* void gmp_randinit_default (gmp_randstate_t STATE) */
static emacs_value
Fmmux_emacs_gmp_c_gmp_randinit_default (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mmux_gmp_randstate_t	state	= mmux_emacs_get_gmp_randstate(env, args[0]);

  gmp_randinit_default(state);
  return mmux_emacs_make_nil(env);
}

/* void gmp_randinit_mt (gmp_randstate_t STATE) */
static emacs_value
Fmmux_emacs_gmp_c_gmp_randinit_mt (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(1 == nargs);
  mmux_gmp_randstate_t	state	= mmux_emacs_get_gmp_randstate(env, args[0]);

  gmp_randinit_mt(state);
  return mmux_emacs_make_nil(env);
}

/* void gmp_randinit_lc_2exp (gmp_randstate_t STATE, const mpz_t A, unsigned long C, mp_bitcnt_t M2EXP) */
static emacs_value
Fmmux_emacs_gmp_c_gmp_randinit_lc_2exp (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(4 == nargs);
  mmux_gmp_randstate_t	state	= mmux_emacs_get_gmp_randstate(env, args[0]);
  mpz_ptr		A	= mmux_emacs_get_gmp_mpz(env, args[1]);
  mmux_ulint_t		C	= mmux_emacs_get_ulint(env, args[2]);
  mp_bitcnt_t		m2exp	= mmux_emacs_get_gmp_bitcnt(env, args[3]);

  gmp_randinit_lc_2exp(state, A, C, m2exp);
  return mmux_emacs_make_nil(env);
}

/* int gmp_randinit_lc_2exp_size (gmp_randstate_t STATE, mp_bitcnt_t SIZE) */
static emacs_value
Fmmux_emacs_gmp_c_gmp_randinit_lc_2exp_size (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mmux_gmp_randstate_t	state	= mmux_emacs_get_gmp_randstate(env, args[0]);
  mp_bitcnt_t		size	= mmux_emacs_get_gmp_bitcnt(env, args[1]);

  gmp_randinit_lc_2exp_size(state, size);
  return mmux_emacs_make_nil(env);
}

/* void gmp_randinit_set (gmp_randstate_t ROP, gmp_randstate_t OP) */
static emacs_value
Fmmux_emacs_gmp_c_gmp_randinit_set (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mmux_gmp_randstate_t	rop	= mmux_emacs_get_gmp_randstate(env, args[0]);
  mmux_gmp_randstate_t	op	= mmux_emacs_get_gmp_randstate(env, args[1]);

  gmp_randinit_set(rop, op);
  return mmux_emacs_make_nil(env);
}


/** --------------------------------------------------------------------
 ** Random state functions: seeding.
 ** ----------------------------------------------------------------- */

/* void gmp_randseed (gmp_randstate_t STATE, const mpz_t SEED) */
static emacs_value
Fmmux_emacs_gmp_c_gmp_randseed (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mmux_gmp_randstate_t	state	= mmux_emacs_get_gmp_randstate(env, args[0]);
  mpz_ptr		seed	= mmux_emacs_get_gmp_mpz(env, args[1]);

  gmp_randseed(state, seed);
  return mmux_emacs_make_nil(env);
}

/* void gmp_randseed_ui (gmp_randstate_t STATE, unsigned long int SEED) */
static emacs_value
Fmmux_emacs_gmp_c_gmp_randseed_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mmux_gmp_randstate_t	state	= mmux_emacs_get_gmp_randstate(env, args[0]);
  mmux_ulint_t		seed	= mmux_emacs_get_ulint(env, args[1]);

  gmp_randseed_ui(state, seed);
  return mmux_emacs_make_nil(env);
}


/** --------------------------------------------------------------------
 ** Random state functions: generation.
 ** ----------------------------------------------------------------- */

/* unsigned long gmp_urandomb_ui (gmp_randstate_t STATE, unsigned long N) */
static emacs_value
Fmmux_emacs_gmp_c_gmp_urandomb_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mmux_gmp_randstate_t	state	= mmux_emacs_get_gmp_randstate(env, args[0]);
  mmux_ulint_t		N	= mmux_emacs_get_ulint(env, args[1]);
  mmux_ulint_t		num;

  num = gmp_urandomb_ui(state, N);
  if (0) {
    fprintf(stderr, "%s: N=%lu, rnd=%lu\n", __func__, N, num);
  }
  return mmux_emacs_make_ulint(env, num);
}

/* unsigned long gmp_urandomm_ui (gmp_randstate_t STATE, unsigned long N) */
static emacs_value
Fmmux_emacs_gmp_c_gmp_urandomm_ui (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  assert(2 == nargs);
  mmux_gmp_randstate_t	state	= mmux_emacs_get_gmp_randstate(env, args[0]);
  mmux_ulint_t		N	= mmux_emacs_get_ulint(env, args[1]);

  return mmux_emacs_make_ulint(env, gmp_urandomm_ui(state, N));
}


/** --------------------------------------------------------------------
 ** Elisp functions table.
 ** ----------------------------------------------------------------- */

#define NUMBER_OF_MODULE_FUNCTIONS	9
static module_function_t const module_functions_table[NUMBER_OF_MODULE_FUNCTIONS] = {
  /* Random state initialisation function. */
  { /* void gmp_randinit_default (gmp_randstate_t STATE) */
    .name		= "mmux-gmp-c-gmp-randinit-default",
    .implementation	= Fmmux_emacs_gmp_c_gmp_randinit_default,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Initialize STATE with a default algorithm.",
  },
  { /* void gmp_randinit_mt (gmp_randstate_t STATE) */
    .name		= "mmux-gmp-c-gmp-randinit-mt",
    .implementation	= Fmmux_emacs_gmp_c_gmp_randinit_mt,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Initialize STATE for a Mersenne Twister algorithm.",
  },
  { /* void gmp_randinit_lc_2exp (gmp_randstate_t STATE, const mpz_t A, unsigned long C, mp_bitcnt_t M2EXP) */
    .name		= "mmux-gmp-c-gmp-randinit-lc-2exp",
    .implementation	= Fmmux_emacs_gmp_c_gmp_randinit_lc_2exp,
    .min_arity		= 4,
    .max_arity		= 4,
    .documentation	= "Initialize STATE with a linear congruential algorithm.",
  },
  { /* int gmp_randinit_lc_2exp_size (gmp_randstate_t STATE, mp_bitcnt_t SIZE) */
    .name		= "mmux-gmp-c-gmp-randinit-lc-2exp-size",
    .implementation	= Fmmux_emacs_gmp_c_gmp_randinit_lc_2exp_size,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Initialize STATE with a linear congruential algorithm.",
  },
  { /* void gmp_randinit_set (gmp_randstate_t ROP, gmp_randstate_t OP) */
    .name		= "mmux-gmp-c-gmp-randinit-set",
    .implementation	= Fmmux_emacs_gmp_c_gmp_randinit_set,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Initialize ROP with a copy of the algorithm and state from OP.",
  },

  /* random seeding functions */
  { /* void gmp_randseed (gmp_randstate_t STATE, const mpz_t SEED) */
    .name		= "mmux-gmp-c-gmp-randseed",
    .implementation	= Fmmux_emacs_gmp_c_gmp_randseed,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Set an initial seed value into STATE.",
  },
  { /* void gmp_randseed_ui (gmp_randstate_t STATE, unsigned long int SEED) */
    .name		= "mmux-gmp-c-gmp-randseed-ui",
    .implementation	= Fmmux_emacs_gmp_c_gmp_randseed_ui,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Set an initial seed value into STATE.",
  },

  /* random number generation */
  { /* unsigned long gmp_urandomb_ui (gmp_randstate_t STATE, unsigned long N) */
    .name		= "mmux-gmp-c-gmp-urandomb-ui",
    .implementation	= Fmmux_emacs_gmp_c_gmp_urandomb_ui,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Return a uniformly distributed random number of N bits, in the range 0 to 2^N-1 inclusive.",
  },
  { /* unsigned long gmp_urandomm_ui (gmp_randstate_t STATE, unsigned long N) */
    .name		= "mmux-gmp-c-gmp-urandomm-ui",
    .implementation	= Fmmux_emacs_gmp_c_gmp_urandomm_ui,
    .min_arity		= 2,
    .max_arity		= 2,
    .documentation	= "Return a uniformly distributed random number in the range 0 to N-1, inclusive.",
  },
};


/** --------------------------------------------------------------------
 ** Module initialisation.
 ** ----------------------------------------------------------------- */

void
mmux_emacs_gmp_miscellaneous_functions_init (emacs_env * env)
{
  mmux_emacs_gmp_define_functions_from_table(env, module_functions_table, NUMBER_OF_MODULE_FUNCTIONS);
}

/* end of file */
