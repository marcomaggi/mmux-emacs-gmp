;;; builtin-objects-use.el --- dynamic module test

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

;;; Code:

(require 'ert)
(require 'gmp)


;;;; helpers

(defun mmux-gmp-print-stderr (obj)
  (print obj #'external-debugging-output))


;;;; allocation functions

(ert-deftest mpf-1 ()
  "Build an `mpf' object: integer init values."
  (should (equal "+0.123e+3"
		 (let ((op (mpf 123)))
		   (mpf-get-str* 10 5 op)))))

(ert-deftest mpf-2 ()
  "Build an `mpf' object: floating-point init value."
  (should (equal "+0.12e+1"
		 (let ((op (mpf 1.2)))
		   (mpf-get-str* 10 5 op)))))

(ert-deftest mpf-3 ()
  "Build an `mpf' object: no init values."
  (should (equal "0.0"
		 (let ((op (mpf)))
		   (mpf-get-str* 10 5 op)))))


;;;; initialisation functions

(ert-deftest mpf-set/get-default-prec ()
  "Set and get the default precision of `mpf' objects."
  (mpf-set-default-prec 123)
  (should (equal 128 (mpf-get-default-prec))))

(ert-deftest mpf-set/get-prec ()
  "Set and get the precision of `mpf' objects."
  (let ((rop (mpf 1.0)))
    (mpf-set-prec rop 123)
    (should (equal 128 (mpf-get-prec rop)))))


;;;; assignment functions

(ert-deftest mpf-set ()
  "Assign an `mpf' object to an `mpf' object."
  (let ((rop (mpf))
	(op  (mpf)))
    (mpf-set-si rop 123)
    (mpf-set    op rop)
    (should (equal "+0.123e+3" (mpf-get-str* 10 8 op)))))

(ert-deftest mpf-set-si ()
  "Assign a signed exact integer to an `mpf' object."
  (let ((rop (mpf)))
    (mpf-set-si rop 123)
    (should (equal "+0.123e+3" (mpf-get-str* 10 8 rop)))))

(ert-deftest mpf-set-ui ()
  "Assign an unsigned exact integer to an `mpf' object."
  (let ((rop (mpf)))
    (mpf-set-ui rop 123)
    (should (equal "+0.123e+3" (mpf-get-str* 10 8 rop)))))

(ert-deftest mpf-set-d ()
  "Assign a floating point to an `mpf' object."
  (should (equal "+0.123e+2" (let ((rop (mpf)))
			       (mpf-set-d rop 12.3)
			       (mpf-get-str* 10 8 rop)))))

(ert-deftest mpf-set-z ()
  "Assign an `mpz' object an `mpf' object."
  (let ((rop	(mpf))
	(op	(mpz 123)))
    (mpf-set-z rop op)
    (should (equal "+0.123e+3" (mpf-get-str* 10 8 rop)))))

(ert-deftest mpf-set-q ()
  "Assign an `mpq' object an `mpf' object."
  (let ((rop	(mpf))
	(op	(mpq 2 3)))
    (mpf-set-q rop op)
    (should (equal "+0.66666667e0" (mpf-get-str* 10 8 rop)))))

(ert-deftest mpf-set-str ()
  "Assign a string value to an `mpf' object."
  (let ((rop (mpf)))
    (mpf-set-str rop "123" 10)
    (should (equal "+0.123e+3" (mpf-get-str* 10 8 rop)))))

(ert-deftest mpf-swap ()
  "Swap values between `mpf' objects."
  (let ((op1 (mpf))
	(op2 (mpf)))
    (mpf-set-si op1 123)
    (mpf-set-si op2 456)
    (mpf-swap op1 op2)
    (should (equal "+0.123e+3" (mpf-get-str* 10 8 op2)))
    (should (equal "+0.456e+3" (mpf-get-str* 10 8 op1)))))


;;;; conversion functions

(ert-deftest mpf-get-ui ()
  "Conversion to unsigned integer."
  (should (equal 123
		 (let ((op (mpf 123)))
		   (mpf-get-ui op)))))

(ert-deftest mpf-get-si ()
  "Conversion to signed integer."
  (should (equal 123
		 (let ((op (mpf 123)))
		   (mpf-get-si op)))))

(ert-deftest mpf-get-d ()
  "Conversion to signed integer."
  (should (equal 123.0
		 (let ((op (mpf 123)))
		   (mpf-get-d op)))))

(ert-deftest mpf-get-d-2exp ()
  "Conversion to signed integer."
  ;; We can test in the *scratch* buffer that:
  ;;
  ;;   (* 0.9609375 (expt 2 7)) => 123.0
  ;;
  (should (equal '(0.9609375 . 7)
		 (let ((op (mpf 123)))
		   (mpf-get-d-2exp op)))))

;;; --------------------------------------------------------------------

(ert-deftest mpf-get-str ()
  "Conversion to string."
  (let ((op (mpf))
	(ndigits 5))
    (mpf-set-si op 15)
    (should (equal '("15" . 2) (mpf-get-str +10 ndigits op)))
    (should (equal '("f"  . 1) (mpf-get-str +16 ndigits op)))
    (should (equal '("F"  . 1) (mpf-get-str -16 ndigits op)))))

(ert-deftest mpf-get-str-1 ()
  "Conversion to string: floating-point object as source."
  (let ((op (mpf))
	(ndigits 5))
    (mpf-set-d op 12.34)
    (should (equal '("1234" . 2) (mpf-get-str +10 ndigits op)))))

(ert-deftest mpf-get-str-2 ()
  "Conversion to string: negative floating-point object as source."
  (let ((op (mpf))
	(ndigits 5))
    (mpf-set-d op -12.34)
    (should (equal '("-1234" . 2) (mpf-get-str +10 ndigits op)))))

(ert-deftest mpf-get-str-3 ()
  "Conversion to string: negative floating-point object as source, less than zero."
  (let ((op (mpf))
	(ndigits 5))
    (mpf-set-d op -0.1234)
    (should (equal '("-1234" . 0) (mpf-get-str +10 ndigits op)))))

(ert-deftest mpf-get-str-4 ()
  "Conversion to string: negative floating-point object as source, less than zero."
  (let ((op (mpf))
	(ndigits 5))
    (mpf-set-d op -0.001234)
    (should (equal '("-1234" . -2) (mpf-get-str +10 ndigits op)))))

;;; --------------------------------------------------------------------

(ert-deftest mpf-get-str*-1 ()
  "Conversion to formatted string: positive double as source."
  (let ((op (mpf))
	(ndigits 5))
    (mpf-set-d op +0.001234)
    (should (equal "+0.1234e-2" (mpf-get-str* +10 ndigits op))))
  (let ((op (mpf))
	(ndigits 5))
    (mpf-set-d op +12.34)
    (should (equal "+0.1234e+2" (mpf-get-str* +10 ndigits op)))))

(ert-deftest mpf-get-str*-2 ()
  "Conversion to formatted string: negative double as source."
  (let ((op (mpf))
	(ndigits 5))
    (mpf-set-d op -0.001234)
    (should (equal "-0.1234e-2" (mpf-get-str* +10 ndigits op))))
  (let ((op (mpf))
	(ndigits 5))
    (mpf-set-d op -12.34)
    (should (equal "-0.1234e+2" (mpf-get-str* +10 ndigits op)))))


;;;; arithmetic functions

;; mpf_add (mpf_t ROP, const mpf_t OP1, const mpf_t OP2)
(ert-deftest mpf-add ()
  "Set ROP to OP1 + OP2."
  (let ((rop	(mpf))
	(op1	(mpf 1.2))
	(op2	(mpf 3.4)))
    (mpf-add rop op1 op2)
    (should (mpf-almost-equal-p rop (+ 1.2 3.4) 1e-5))))

;; void mpf_add_ui (mpf_t ROP, const mpf_t OP1, unsigned long int OP2)
(ert-deftest mpf-add-ui ()
  "Set ROP to OP1 + OP2."
  (let ((rop	(mpf))
	(op1	(mpf 1.2))
	(op2	3))
    (mpf-add-ui rop op1 op2)
    (should (mpf-almost-equal-p rop (+ 1.2 3.0) 1e-5))))

;; void mpf_sub (mpf_t ROP, const mpf_t OP1, const mpf_t OP2)
(ert-deftest mpf-sub ()
  "Set ROP to OP1 - OP2."
  (let ((rop	(mpf))
	(op1	(mpf 1.2))
	(op2	(mpf 3.4)))
    (mpf-sub rop op1 op2)
    (should (mpf-almost-equal-p rop (- 1.2 3.4) 1e-5))))

;; void mpf_ui_sub (mpf_t ROP, unsigned long int OP1, const mpf_t OP2)
(ert-deftest mpf-ui-sub ()
  "Set ROP to OP1 - OP2."
  (let ((rop	(mpf))
	(op1	1)
	(op2	(mpf 3.4)))
    (mpf-ui-sub rop op1 op2)
    (should (mpf-almost-equal-p rop (- 1 3.4) 1e-5))))

;; void mpf_sub_ui (mpf_t ROP, const mpf_t OP1, unsigned long int OP2)
(ert-deftest mpf-sub-ui ()
  "Set ROP to OP1 - OP2."
  (let ((rop	(mpf))
	(op1	(mpf 1.2))
	(op2	3))
    (mpf-sub-ui rop op1 op2)
    (should (mpf-almost-equal-p rop (- 1.2 3) 1e-5))))

;; void mpf_mul (mpf_t ROP, const mpf_t OP1, const mpf_t OP2)
(ert-deftest mpf-mul ()
  "Set ROP to OP1 times OP2."
  (let ((rop	(mpf))
	(op1	(mpf 1.2))
	(op2	(mpf 3.4)))
    (mpf-mul rop op1 op2)
    (should (mpf-almost-equal-p rop (* 1.2 3.4) 1e-5))))

;; void mpf_mul_ui (mpf_t ROP, const mpf_t OP1, unsigned long int OP2)
(ert-deftest mpf-mul-ui ()
  "Set ROP to OP1 times OP2."
  (let ((rop	(mpf))
	(op1	(mpf 1.2))
	(op2	3))
    (mpf-mul-ui rop op1 op2)
    (should (mpf-almost-equal-p rop (* 1.2 3) 1e-5))))

;; void mpf_div (mpf_t ROP, const mpf_t OP1, const mpf_t OP2)
(ert-deftest mpf-div ()
  "Set ROP to OP1/OP2."
  (let ((rop	(mpf))
	(op1	(mpf 1.2))
	(op2	(mpf 3.4)))
    (mpf-div rop op1 op2)
    (should (mpf-almost-equal-p rop (/ 1.2 3.4) 1e-5))))

;; void mpf_ui_div (mpf_t ROP, unsigned long int OP1, const mpf_t OP2)
(ert-deftest mpf-ui-div ()
  "Set ROP to OP1/OP2."
  (let ((rop	(mpf))
	(op1	1)
	(op2	(mpf 3.4)))
    (mpf-ui-div rop op1 op2)
    (should (mpf-almost-equal-p rop (/ 1 3.4) 1e-5))))

;; void mpf_div_ui (mpf_t ROP, const mpf_t OP1, unsigned long int OP2)
(ert-deftest mpf-div-ui ()
  "Set ROP to OP1/OP2."
  (let ((rop	(mpf))
	(op1	(mpf 1.2))
	(op2	3))
    (mpf-div-ui rop op1 op2)
    (should (mpf-almost-equal-p rop (/ 1.2 3) 1e-5))))

;; void mpf_sqrt (mpf_t ROP, const mpf_t OP)
(ert-deftest mpf-sqrt ()
  "Set ROP to the square root of OP."
  (let ((rop	(mpf))
	(op	(mpf 1.2)))
    (mpf-sqrt rop op)
    (should (mpf-almost-equal-p rop (sqrt 1.2) 1e-5))))

;; void mpf_sqrt_ui (mpf_t ROP, unsigned long int OP)
(ert-deftest mpf-sqrt-ui ()
  "Set ROP to the square root of OP."
  (let ((rop	(mpf))
	(op	12))
    (mpf-sqrt-ui rop op)
    (should (mpf-almost-equal-p rop (sqrt 12) 1e-5))))

;; void mpf_pow_ui (mpf_t ROP, const mpf_t OP1, unsigned long int OP2)
(ert-deftest mpf-pow-ui ()
  "Set ROP to OP1 raised to the power OP2."
  (let ((rop	(mpf))
	(op1	(mpf 1.2))
	(op2	3))
    (mpf-pow-ui rop op1 op2)
    (should (mpf-almost-equal-p rop (expt 1.2 3) 1e-5))))

;; void mpf_neg (mpf_t ROP, const mpf_t OP)
(ert-deftest mpf-neg ()
  "Set ROP to -OP."
  (let ((rop	(mpf))
	(op	(mpf 1.2)))
    (mpf-neg rop op)
    (should (mpf-almost-equal-p rop (- 1.2) 1e-5))))

;; void mpf_abs (mpf_t ROP, const mpf_t OP)
(ert-deftest mpf-abs ()
  "Set ROP to the absolute value of OP."
  (let ((rop	(mpf))
	(op	(mpf -1.2)))
    (mpf-abs rop op)
    (should (mpf-almost-equal-p rop 1.2 1e-5))))

;; void mpf_mul_2exp (mpf_t ROP, const mpf_t OP1, mp_bitcnt_t OP2)
(ert-deftest mpf-mul-2exp ()
  "Set ROP to OP1 times 2 raised to OP2."
  (let ((rop	(mpf))
	(op1	(mpf 1.2))
	(op2	3))
    (mpf-mul-2exp rop op1 op2)
    (should (mpf-almost-equal-p rop (* 1.2 (expt 2 3)) 1e-5))))

;; void mpf_div_2exp (mpf_t ROP, const mpf_t OP1, mp_bitcnt_t OP2)
(ert-deftest mpf-div-2exp ()
  "Set ROP to OP1 divided by 2 raised to OP2."
  (let ((rop	(mpf))
	(op1	(mpf 1.2))
	(op2	3))
    (mpf-div-2exp rop op1 op2)
    (should (mpf-almost-equal-p rop (/ 1.2 (expt 2 3)) 1e-5))))


;;;; comparison functions

;; int mpf_cmp (const mpf_t OP1, const mpf_t OP2)
(ert-deftest mpf-cmp ()
  "Compare OP1 and OP2."
  (should (equal -1 (mpf-cmp (mpf 1.2) (mpf 3.4))))
  (should (equal  0 (mpf-cmp (mpf 1.2) (mpf 1.2))))
  (should (equal +1 (mpf-cmp (mpf 3.4) (mpf 1.2)))))

;; int mpf_cmp_z (const mpf_t OP1, const mpz_t OP2)
(ert-deftest mpf-cmp-z ()
  "Compare OP1 and OP2."
  (should (equal -1 (mpf-cmp-z (mpf 1.2) (mpz 2))))
  (should (equal  0 (mpf-cmp-z (mpf 1.0) (mpz 1))))
  (should (equal +1 (mpf-cmp-z (mpf 1.2) (mpz 1)))))

;; int mpf_cmp_d (const mpf_t OP1, double OP2)
(ert-deftest mpf-cmp-d ()
  "Compare OP1 and OP2."
  (should (equal -1 (mpf-cmp-d (mpf 1.2) 3.4)))
  (should (equal  0 (mpf-cmp-d (mpf 1.2) 1.2)))
  (should (equal +1 (mpf-cmp-d (mpf 3.4) 1.2))))

;; int mpf_cmp_ui (const mpf_t OP1, unsigned long int OP2)
(ert-deftest mpf-cmp-ui ()
  "Compare OP1 and OP2."
  (should (equal -1 (mpf-cmp-ui (mpf 1.2) 2)))
  (should (equal  0 (mpf-cmp-ui (mpf 1.0) 1)))
  (should (equal +1 (mpf-cmp-ui (mpf 1.2) 1))))

;; int mpf_cmp_si (const mpf_t OP1, long int OP2)
(ert-deftest mpf-cmp-si ()
  "Compare OP1 and OP2."
  (should (equal -1 (mpf-cmp-si (mpf -2.1) -2)))
  (should (equal  0 (mpf-cmp-si (mpf -1.0) -1)))
  (should (equal +1 (mpf-cmp-si (mpf -1.0) -2))))

;; int mpf_sgn (const mpf_t OP)
(ert-deftest mpf-sgn ()
  "Return +1 if OP > 0, 0 if OP = 0, and -1 if OP < 0."
  (should (equal -1 (mpf-sgn (mpf -1.0))))
  (should (equal  0 (mpf-sgn (mpf  0.0))))
  (should (equal +1 (mpf-sgn (mpf +1.0)))))

;; void mpf_reldiff (mpf_t ROP, const mpf_t OP1, const mpf_t OP2)
(ert-deftest mpf-reldiff ()
  "Compute the relative difference between OP1 and OP2 and store the result in ROP.  This is abs(OP1-OP2)/OP1."
  (let ((rop	(mpf))
	(op1	(mpf 1.2))
	(op2	(mpf 3.4)))
    (mpf-reldiff rop op1 op2)
    (let ((X (/ (abs (- 1.2 3.4)) 1.2)))
      (should (< (- X 0.00001)
		 (mpf-get-d rop)
		 (+ X 0.00001))))))

(ert-deftest mpf-equal ()
  "Return true the operands are equal; otherwise return false."
  (should      (mpf-equal (mpf 1.2) (mpf 1.2)))
  (should (not (mpf-equal (mpf 1.2) (mpf 3.4)))))

;; ;;; --------------------------------------------------------------------

(ert-deftest mpf-zero-p ()
  "Return true if OP is zero; otherwise return false."
  (should      (mpf-zero-p (mpf 0.0)))
  (should (not (mpf-zero-p (mpf 1.0)))))

(ert-deftest mpf-non-zero-p ()
  "Return true if OP is non-zero; otherwise return false."
  (should (mpf-non-zero-p (mpf 1.0)))
  (should (not (mpf-non-zero-p (mpf 0.0)))))

;;; --------------------------------------------------------------------

(ert-deftest mpf-positive-p ()
  "Return true if OP is strictly positive; otherwise return false."
  (should      (mpf-positive-p (mpf +1.0)))
  (should (not (mpf-positive-p (mpf  0.0))))
  (should (not (mpf-positive-p (mpf -1.0)))))

(ert-deftest mpf-negative-p ()
  "Return true if OP is strictly negative; otherwise return false."
  (should (not (mpf-negative-p (mpf +1.0))))
  (should (not (mpf-negative-p (mpf  0.0))))
  (should      (mpf-negative-p (mpf -1.0))))

;;; --------------------------------------------------------------------

(ert-deftest mpf-non-positive-p ()
  "Return true if OP is non-positive; otherwise return false."
  (should (not (mpf-non-positive-p (mpf +1.0))))
  (should      (mpf-non-positive-p (mpf  0.0)))
  (should      (mpf-non-positive-p (mpf -1.0))))

(ert-deftest mpf-non-negative-p ()
  "Return true if OP is non-negative; otherwise return false."
  (should      (mpf-non-negative-p (mpf +1.0)))
  (should      (mpf-non-negative-p (mpf  0.0)))
  (should (not (mpf-non-negative-p (mpf -1.0)))))

;;; --------------------------------------------------------------------

(ert-deftest mpf< ()
  "Return true if each argument is strictly less than the following argument; otherwise return false."
  (should      (mpf< (mpf 1.0) (mpf 2.0)))
  (should (not (mpf< (mpf 1.0) (mpf 1.0))))
  (should (not (mpf< (mpf 2.0) (mpf 1.0)))))

(ert-deftest mpf> ()
  "Return true if each argument is strictly greater than the following argument; otherwise return false."
  (should (not (mpf> (mpf 1.0) (mpf 2.0))))
  (should (not (mpf> (mpf 1.0) (mpf 1.0))))
  (should      (mpf> (mpf 2.0) (mpf 1.0))))

(ert-deftest mpf<= ()
  "Return true if each argument is strictly less than, or equal to, the following argument; otherwise return false."
  (should      (mpf<= (mpf 1.0) (mpf 2.0)))
  (should      (mpf<= (mpf 1.0) (mpf 1.0)))
  (should (not (mpf<= (mpf 2.0) (mpf 1.0)))))

(ert-deftest mpf>= ()
  "Return true if each argument is greater than, or equal to, the following argument; otherwise return false."
  (should (not (mpf>= (mpf 1.0) (mpf 2.0))))
  (should      (mpf>= (mpf 1.0) (mpf 1.0)))
  (should      (mpf>= (mpf 2.0) (mpf 1.0))))

(ert-deftest mpf= ()
  "Return true if each argument is equal to the following argument; otherwise return false."
  (should (not (mpf= (mpf 1.0) (mpf 2.0))))
  (should      (mpf= (mpf 1.0) (mpf 1.0)))
  (should (not (mpf= (mpf 2.0) (mpf 1.0)))))


;;;; floating-point numbers: miscellaneous functions

;; void mpf_ceil (mpf_t ROP, const mpf_t OP)
(ert-deftest mpf-ceil ()
  "Set ROP to OP rounded to an integer."
  (let ((rop	(mpf))
	(op	(mpf 1.5)))
    (mpf-ceil rop op)
    (should (mpf-almost-equal-p rop 2.0 1e-5))))

;; void mpf_floor (mpf_t ROP, const mpf_t OP)
(ert-deftest mpf-floor ()
  "Set ROP to OP rounded to an integer."
  (let ((rop	(mpf))
	(op	(mpf 1.5)))
    (mpf-floor rop op)
    (should (mpf-almost-equal-p rop 1.0 1e-5))))

;; void mpf_trunc (mpf_t ROP, const mpf_t OP)
(ert-deftest mpf-trunc ()
  "Set ROP to OP rounded to an integer."
  (let ((rop	(mpf))
	(op	(mpf 1.5)))
    (mpf-trunc rop op)
    (should (mpf-almost-equal-p rop 1.0 1e-5))))

;; int mpf_integer_p (const mpf_t OP)
(ert-deftest mpf-integer-p ()
  "Return non-zero if OP is an integer."
  (should      (mpf-integer-p (mpf 1.0)))
  (should (not (mpf-integer-p (mpf 1.1)))))

;; int mpf_fits_ulong_p (const mpf_t OP)
(ert-deftest mpf-fits-ulong-p ()
  "Return non-zero if OP would fit in the respective C data type, when truncated to an integer."
  (should      (mpf-fits-ulong-p (mpf 1.2)))
  (should (not (mpf-fits-ulong-p (mpf 1.0e99)))))

;; int mpf_fits_slong_p (const mpf_t OP)
(ert-deftest mpf-fits-slong-p ()
  "Return non-zero if OP would fit in the respective C data type, when truncated to an integer."
  (should      (mpf-fits-slong-p (mpf 1.2)))
  (should (not (mpf-fits-slong-p (mpf 1.0e99)))))

;; int mpf_fits_uint_p (const mpf_t OP)
(ert-deftest mpf-fits-uint-p ()
  "Return non-zero if OP would fit in the respective C data type, when truncated to an integer."
  (should      (mpf-fits-uint-p (mpf 1.2)))
  (should (not (mpf-fits-uint-p (mpf 1.0e99)))))

;; int mpf_fits_sint_p (const mpf_t OP)
(ert-deftest mpf-fits-sint-p ()
  "Return non-zero if OP would fit in the respective C data type, when truncated to an integer."
  (should      (mpf-fits-sint-p (mpf 1.2)))
  (should (not (mpf-fits-sint-p (mpf 1.0e99)))))

;; int mpf_fits_ushort_p (const mpf_t OP)
(ert-deftest mpf-fits-ushort-p ()
  "Return non-zero if OP would fit in the respective C data type, when truncated to an integer."
  (should      (mpf-fits-ushort-p (mpf 1.2)))
  (should (not (mpf-fits-ushort-p (mpf 1.0e99)))))

;; int mpf_fits_sshort_p (const mpf_t OP)
(ert-deftest mpf-fits-sshort-p ()
  "Return non-zero if OP would fit in the respective C data type, when truncated to an integer."
  (should      (mpf-fits-sshort-p (mpf 1.2)))
  (should (not (mpf-fits-sshort-p (mpf 1.0e99)))))

;; void mpf_urandomb (mpf_t ROP, gmp_randstate_t STATE, mp_bitcnt_t NBITS)
(ert-deftest mpf-urandomb ()
  "Generate a uniformly distributed random float in ROP."
  (let ((rop	(mpf))
	(state	(gmp-randstate))
	(nbits	3))
    (gmp-randinit-default state)
    (gmp-randseed-ui state 123)
    (mpf-urandomb rop state nbits)
    (should (mpf<= 0 rop))
    (should (mpf<  rop 1.0))))

;; void mpf_random2 (mpf_t ROP, mp_size_t MAX_SIZE, mp_exp_t EXP)
(ert-deftest mpf-random2 ()
  "Generate a random float of at most MAX_SIZE limbs, with long strings of zeros and ones in the binary representation."
  (let ((rop		(mpf))
	(max-size	1)
	(exp		3))
    (mpf-random2 rop max-size exp)
    (should (mpf-p rop))))


;;;; done

(garbage-collect)
(ert-run-tests-batch-and-exit)

;;; test.el ends here
