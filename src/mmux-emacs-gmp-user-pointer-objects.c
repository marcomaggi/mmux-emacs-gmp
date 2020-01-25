/*
  Part of: MMUX Emacs GMP
  Contents: user-ptr elisp objects wrapping GMP types
  Date: Jan 15, 2020

  Abstract

	This module  implements functions accessing  and creating the  user-ptr elisp
	objects wrapping the GMP data types.

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
#include <stdlib.h>
#include <errno.h>
#include <string.h>


/** --------------------------------------------------------------------
 ** Allocation functions: "mpz_t".
 ** ----------------------------------------------------------------- */

static void
mmux_emacs_mpz_finalizer (void * obj)
{
  mpz_clear(obj);
  free(obj);
}

static emacs_value
Fmmux_gmp_c_mpz_make (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
		      emacs_value args[] MMUX_EMACS_GMP_UNUSED, void * data MMUX_EMACS_GMP_UNUSED)
{
  mpz_ptr	obj;

  errno = 0;
  obj   = malloc(sizeof(__mpz_struct));
  if (NULL == obj) {
    char const		* errmsg = strerror(errno);
    emacs_value		Serrmsg = env->make_string(env, errmsg, strlen(errmsg));

    /* Signal an error,  then immediately return.  In the "elisp"  Info file: see the
       node "Standard Errors" for a list of  the standard error symbols; see the node
       "Error Symbols"  for methods to define  error symbols.  (Marco Maggi;  Jan 14,
       2020) */
    env->non_local_exit_signal(env, env->intern(env, "mmux-gmp-no-memory-error"), Serrmsg);
    return env->intern(env, "nil");
  } else {
    mpz_init(obj);
    return env->make_user_ptr(env, mmux_emacs_mpz_finalizer, obj);
  }
}


/** --------------------------------------------------------------------
 ** Allocation functions: "mpq_t".
 ** ----------------------------------------------------------------- */

static void
mmux_emacs_mpq_finalizer (void * obj)
{
  mpq_clear(obj);
  free(obj);
}

static emacs_value
Fmmux_gmp_c_mpq_make (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
		      emacs_value args[] MMUX_EMACS_GMP_UNUSED, void * data MMUX_EMACS_GMP_UNUSED)
{
  mpq_ptr	obj;

  errno = 0;
  obj   = malloc(sizeof(__mpq_struct));
  if (NULL == obj) {
    char const		* errmsg = strerror(errno);
    emacs_value		Serrmsg = env->make_string(env, errmsg, strlen(errmsg));

    /* Signal an error,  then immediately return.  In the "elisp"  Info file: see the
       node "Standard Errors" for a list of  the standard error symbols; see the node
       "Error Symbols"  for methods to define  error symbols.  (Marco Maggi;  Jan 14,
       2020) */
    env->non_local_exit_signal(env, env->intern(env, "mmux-gmp-no-memory-error"), Serrmsg);
    return env->intern(env, "nil");
  } else {
    mpq_init(obj);
    return env->make_user_ptr(env, mmux_emacs_mpq_finalizer, obj);
  }
}


/** --------------------------------------------------------------------
 ** Allocation functions: "mpf_t".
 ** ----------------------------------------------------------------- */

static void
mmux_emacs_mpf_finalizer (void * obj)
{
  mpf_clear(obj);
  free(obj);
}

static emacs_value
Fmmux_gmp_c_mpf_make (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
		      emacs_value args[] MMUX_EMACS_GMP_UNUSED, void * data MMUX_EMACS_GMP_UNUSED)
{
  mpf_ptr	obj;

  errno = 0;
  obj   = malloc(sizeof(__mpf_struct));
  if (NULL == obj) {
    char const		* errmsg = strerror(errno);
    emacs_value		Serrmsg = env->make_string(env, errmsg, strlen(errmsg));

    /* Signal an error,  then immediately return.  In the "elisp"  Info file: see the
       node "Standard Errors" for a list of  the standard error symbols; see the node
       "Error Symbols"  for methods to define  error symbols.  (Marco Maggi;  Jan 14,
       2020) */
    env->non_local_exit_signal(env, env->intern(env, "mmux-gmp-no-memory-error"), Serrmsg);
    return env->intern(env, "nil");
  } else {
    mpf_init(obj);
    mpf_set_ui(obj, 0);
    return env->make_user_ptr(env, mmux_emacs_mpf_finalizer, obj);
  }
}


/** --------------------------------------------------------------------
 ** Allocation functions: "gmp_randstate_t".
 ** ----------------------------------------------------------------- */

static void
mmux_emacs_gmp_randstate_finalizer (void * obj)
{
  gmp_randclear(obj);
  free(obj);
}

static emacs_value
Fmmux_gmp_c_gmp_randstate_make (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
				emacs_value args[] MMUX_EMACS_GMP_UNUSED, void * data MMUX_EMACS_GMP_UNUSED)
{
  mmux_gmp_randstate_t	obj;

  errno = 0;
  obj   = malloc(sizeof(__gmp_randstate_struct));
  if (NULL == obj) {
    char const		* errmsg = strerror(errno);
    emacs_value		Serrmsg = env->make_string(env, errmsg, strlen(errmsg));

    /* Signal an error,  then immediately return.  In the "elisp"  Info file: see the
       node "Standard Errors" for a list of  the standard error symbols; see the node
       "Error Symbols"  for methods to define  error symbols.  (Marco Maggi;  Jan 14,
       2020) */
    env->non_local_exit_signal(env, env->intern(env, "mmux-gmp-no-memory-error"), Serrmsg);
    return env->intern(env, "nil");
  } else {
    return env->make_user_ptr(env, mmux_emacs_gmp_randstate_finalizer, obj);
  }
}


/** --------------------------------------------------------------------
 ** Elisp functions table.
 ** ----------------------------------------------------------------- */

#define NUMBER_OF_MODULE_FUNCTIONS	4
static module_function_t const module_functions_table[NUMBER_OF_MODULE_FUNCTIONS] = {
  {
    .name		= "mmux-gmp-c-mpz-make",
    .implementation	= Fmmux_gmp_c_mpz_make,
    .min_arity		= 0,
    .max_arity		= 0,
    .documentation	= "Build and return a new user-pointer object to be embedded into a `mpz' object."
  },
  {
    .name		= "mmux-gmp-c-mpq-make",
    .implementation	= Fmmux_gmp_c_mpq_make,
    .min_arity		= 0,
    .max_arity		= 0,
    .documentation	= "Build and return a new user-pointer object to be embedded into a `mpq' object."
  },
  {
    .name		= "mmux-gmp-c-mpf-make",
    .implementation	= Fmmux_gmp_c_mpf_make,
    .min_arity		= 0,
    .max_arity		= 0,
    .documentation	= "Build and return a new user-pointer object to be embedded into a `mpf' object."
  },
  {
    .name		= "mmux-gmp-c-gmp-randstate-make",
    .implementation	= Fmmux_gmp_c_gmp_randstate_make,
    .min_arity		= 0,
    .max_arity		= 0,
    .documentation	= "Build and return a new user-pointer object to be embedded into a `gmp-randstate' object."
  },
};


/** --------------------------------------------------------------------
 ** Module initialisation.
 ** ----------------------------------------------------------------- */

void
mmux_emacs_gmp_user_pointer_objects_init (emacs_env * env)
{
  mmux_emacs_gmp_define_functions_from_table(env, module_functions_table, NUMBER_OF_MODULE_FUNCTIONS);
}

/* end of file */
