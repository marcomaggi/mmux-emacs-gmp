/*
  Part of: MMUX Emacs GMP
  Contents: usge examples for built-in elisp objects
  Date: Jan 15, 2020

  Abstract

	This module implements example functions  accessing and creating the built-in
	elisp objects.

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
 ** Example functions.
 ** ----------------------------------------------------------------- */

static emacs_value
Fmmux_gmp_use_integer (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			    emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  intmax_t	N = env->extract_integer(env, args[0]);

  return env->make_integer(env, 1+N);
}

static emacs_value
Fmmux_gmp_use_float (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			  emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  double	N = env->extract_float(env, args[0]);

  return env->make_float(env, 1.0+N);
}

static emacs_value
Fmmux_gmp_use_string (emacs_env *env, ptrdiff_t nargs MMUX_EMACS_GMP_UNUSED,
			   emacs_value args[], void * data MMUX_EMACS_GMP_UNUSED)
{
  ptrdiff_t	len = 0;

  env->copy_string_contents(env, args[0], NULL, &len);
  {
    char	buf[len];

    env->copy_string_contents(env, args[0], buf, &len);
    /* We do not take into account the ending zero here. */
    return env->make_string(env, buf, len-1);
  }
}


/** --------------------------------------------------------------------
 ** Elisp functions table.
 ** ----------------------------------------------------------------- */

#define NUMBER_OF_MODULE_FUNCTIONS	3
static module_function_t const module_functions_table[NUMBER_OF_MODULE_FUNCTIONS] = {
  {
    .name		= "mmux-gmp-use-integer",
    .implementation	= Fmmux_gmp_use_integer,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Use an integer object."
  },
  {
    .name		= "mmux-gmp-use-float",
    .implementation	= Fmmux_gmp_use_float,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Use a float object."
  },
  {
    .name		= "mmux-gmp-use-string",
    .implementation	= Fmmux_gmp_use_string,
    .min_arity		= 1,
    .max_arity		= 1,
    .documentation	= "Use a string object."
  }
};


/** --------------------------------------------------------------------
 ** Module initialisation.
 ** ----------------------------------------------------------------- */

void
mmux_gmp_builtin_objects_init (emacs_env * env)
{
  mmux_gmp_define_functions_from_table(env, module_functions_table, NUMBER_OF_MODULE_FUNCTIONS);
}

/* end of file */
