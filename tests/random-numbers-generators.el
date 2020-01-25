;;; random-numbers-generators.el --- dynamic module test

;; Copyright (C) 2020 by Marco Maggi

;; Author: Marco Maggi <mrc.mgg@gmail.com>

;; This program is  free software; you can redistribute  it and/or modify it under the  terms of the
;; GNU General Public License as published by the  Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
;; even the implied  warranty of MERCHANTABILITY or  FITNESS FOR A PARTICULAR PURPOSE.   See the GNU
;; General Public License for more details.
;;
;; You should have  received a copy of the  GNU General Public License along with  this program.  If
;; not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;For numeric examples, look at the site:
;;
;; https://documentation.help/Math.Gmp.Native.NET/38be0c24-42ac-e0ea-9e18-e75e3bda2a1e.htm
;;

;;; Code:

(require 'ert)
(require 'mmux-emacs-gmp)


;;;; random number generators: initialisation

;; void gmp_randinit_default (gmp_randstate_t STATE)
(ert-deftest gmp-randinit-default ()
  "Initialize STATE with a default algorithm."
  (let ((state	(gmp-randstate)))
    (gmp-randinit-default state)
    (gmp-randseed-ui state 123)
    (let ((num (gmp-urandomb-ui state 3)))
      (should (and (<= 0 num) (< num (expt 2 3)))))))

;; void gmp_randinit_mt (gmp_randstate_t STATE)
(ert-deftest gmp-randinit-mt ()
  "Initialize STATE for a Mersenne Twister algorithm."
  (let ((state	(gmp-randstate)))
    (gmp-randinit-mt state)
    (gmp-randseed-ui state 123)
    (let ((num (gmp-urandomb-ui state 3)))
      (should (and (<= 0 num) (< num (expt 2 3)))))))

;; void gmp_randinit_lc_2exp (gmp_randstate_t STATE, const mpz_t A, unsigned long C, mp_bitcnt_t M2EXP)
(ert-deftest gmp-randinit-lc-2exp ()
  "Initialize STATE with a linear congruential algorithm."
  (let ((state	(gmp-randstate))
	(A	(mpz 19))
	(C	2)
	(M2EXP	3))
    (gmp-randinit-lc-2exp state A C M2EXP)
    (gmp-randseed-ui state 123)
    (let ((num (gmp-urandomb-ui state 3)))
      (should (and (<= 0 num) (< num (expt 2 3)))))))

;; int gmp-randinit-lc-2exp_size (gmp_randstate_t STATE, mp_bitcnt_t SIZE)
(ert-deftest gmp-randinit-lc-2exp-size ()
  "Initialize STATE with a linear congruential algorithm."
  (let ((state	(gmp-randstate))
	(size	30))
    (gmp-randinit-lc-2exp-size state size)
    (gmp-randseed-ui state 123)
    (let ((num (gmp-urandomb-ui state 3)))
      (should (and (<= 0 num) (< num (expt 2 3)))))))

;; void gmp-randinit-set (gmp_randstate_t ROP, gmp_randstate_t OP)
(ert-deftest gmp-randinit-set ()
  "Initialize ROP with a copy of the algorithm and state from OP."
  (let ((rop	(gmp-randstate))
	(op	(gmp-randstate)))
    (gmp-randinit-default op)
    (gmp-randseed-ui op 123)
    (gmp-randinit-set rop op)
    (let ((num (gmp-urandomb-ui op 3)))
      (should (and (<= 0 num) (< num (expt 2 3)))))))


;;;; random number generators: seeding

;; void gmp_randseed (gmp_randstate_t STATE, const mpz_t SEED)
(ert-deftest gmp-randseed ()
  "Set an initial seed value into STATE."
  (let ((state	(gmp-randstate)))
    (gmp-randinit-default state)
    (gmp-randseed state (mpz 123))
    (let ((num (gmp-urandomm-ui state 3)))
      (should (<= 0 num 3)))))

;; void gmp_randseed_ui (gmp_randstate_t STATE, unsigned long int SEED)
(ert-deftest gmp-randseed-ui ()
  "Set an initial seed value into STATE."
  (let ((state	(gmp-randstate)))
    (gmp-randinit-default state)
    (gmp-randseed-ui state 123)
    (let ((num (gmp-urandomm-ui state 3)))
      (should (<= 0 num 3)))))


;;;; random number generators: generation

;; unsigned long gmp_urandomb_ui (gmp_randstate_t STATE, unsigned long N)
(ert-deftest gmp-urandomb-ui ()
  "Return a uniformly distributed random number of N bits, in the range 0 to 2^N-1 inclusive."
  (let ((state	(gmp-randstate)))
    (gmp-randinit-default state)
    (gmp-randseed-ui state 123)
    (let ((num (gmp-urandomb-ui state 3)))
      (should (and (<= 0 num) (< num (expt 2 3)))))))

;; unsigned long gmp_urandomm_ui (gmp_randstate_t STATE, unsigned long N)
(ert-deftest gmp-urandomm-ui ()
  "Return a uniformly distributed random number in the range 0 to N-1, inclusive."
  (let ((state	(gmp-randstate)))
    (gmp-randinit-default state)
    (gmp-randseed-ui state 123)
    (let ((num (gmp-urandomm-ui state 3)))
      (should (and (<= 0 num) (< num 3))))))


;;;; done

(garbage-collect)
(ert-run-tests-batch-and-exit)

;;; end of file
