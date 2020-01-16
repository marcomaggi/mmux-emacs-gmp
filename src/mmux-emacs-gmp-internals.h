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

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif
#include "mmux-emacs-gmp.h"
#include <assert.h>
#include <stdio.h>


/** --------------------------------------------------------------------
 ** Preprocessor macros.
 ** ----------------------------------------------------------------- */


/** --------------------------------------------------------------------
 ** Type definitions.
 ** ----------------------------------------------------------------- */

typedef emacs_value function_implementation_t (emacs_env *env, ptrdiff_t nargs, emacs_value args[], void *data);

typedef struct module_function_t	module_function_t;

struct module_function_t {
  char const			* name;
  function_implementation_t	* implementation;
  ptrdiff_t			min_arity;
  ptrdiff_t			max_arity;
  char const			* documentation;
};


/** --------------------------------------------------------------------
 ** Constants.
 ** ----------------------------------------------------------------- */

/* This is required by GNU Emacs' API. */
mmux_emacs_gmp_decl int  plugin_is_GPL_compatible;


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


/** --------------------------------------------------------------------
 ** Done.
 ** ----------------------------------------------------------------- */

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* MMUX_EMACS_GMP_INTERNALS_H */

/* end of file */
