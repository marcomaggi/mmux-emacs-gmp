;;; integer-numbers.el --- dynamic module test

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
(require 'gmp)


;;;; helpers

(defmacro check (EXPR => RESULT)
  `(should (equal ,RESULT ,EXPR)))

(defun mmux-gmp-print-stderr (obj)
  (print obj #'external-debugging-output))


;;;; allocation functions

(ert-deftest mpz-1 ()
  "Build an `mpz' object: integer init values."
  (should (equal "123" (let ((op (mpz 123)))
			 (mpz-get-str 10 op)))))

(ert-deftest mpz-2 ()
  "Build an `mpz' object: floating-point init value."
  (should (equal "1"
		 (let ((op (mpz 1.2)))
		   (mpz-get-str 10 op)))))

(ert-deftest mpz-3 ()
  "Build an `mpz' object: no init values."
  (should (equal "0" (let ((op (mpz)))
		       (mpz-get-str 10 op)))))


;;;; assignment functions

(ert-deftest mpz-set ()
  "Assign an `mpz' object to an `mpz' object."
  (let ((rop (mpz))
	(op  (mpz)))
    (mpz-set-si rop 123)
    (mpz-set    op rop)
    (should (equal "123" (mpz-get-str 10 op)))))

(ert-deftest mpz-set-si ()
  "Assign a signed exact integer to an `mpz' object."
  (should (equal "123" (let ((rop (mpz)))
			 (mpz-set-si rop 123)
			 (mpz-get-str 10 rop))))
  (should (equal "-123" (let ((rop (mpz)))
			  (mpz-set-si rop -123)
			  (mpz-get-str 10 rop)))))

(ert-deftest mpz-set-ui ()
  "Assign an unsigned exact integer to an `mpz' object."
  (let ((rop (mpz)))
    (mpz-set-ui rop 123)
    (should (equal "123" (mpz-get-str 10 rop)))))

(ert-deftest mpz-set-q ()
  "Assign an `mpq' object to an `mpz' object."
  (let ((rop (mpz))
	(op  (mpq)))
    (mpq-set-si op 10 7)
    (mpz-set-q rop op)
    (should (equal "1" (mpz-get-str 10 rop)))))

(ert-deftest mpz-set-f ()
  "Assign an `mpf' object to an `mpz' object."
  (let ((rop (mpz))
	(op  (mpf)))
    (mpf-set-d op 12.34)
    (mpz-set-f rop op)
    (should (equal "12" (mpz-get-str 10 rop)))))

(ert-deftest mpz-set-d ()
  "Assign a floating point to an `mpz' object."
  (let ((rop (mpz)))
    (mpz-set-d rop 12.3)
    (should (equal "12" (mpz-get-str 10 rop)))))

(ert-deftest mpz-set-str ()
  "Assign a string value to an `mpz' object."
  (let ((rop (mpz)))
    (mpz-set-str rop "123" 10)
    (should (equal "123" (mpz-get-str 10 rop)))))

(ert-deftest mpz-swap ()
  "Swap values between `mpz' objects."
  (let ((op1 (mpz))
	(op2 (mpz)))
    (mpz-set-si op1 123)
    (mpz-set-si op2 456)
    (mpz-swap op1 op2)
    (should (equal "123" (mpz-get-str 10 op2)))
    (should (equal "456" (mpz-get-str 10 op1)))))

(ert-deftest mpz-swap-1 ()
  "Swap values between `mpz' objects."
  (defconst op1 (mpz))
  (defconst op2 (mpz))
  (mpz-set-si op1 123)
  (mpz-set-si op2 456)
  (mpz-swap op1 op2)
  (should (equal "123" (mpz-get-str 10 op2)))
  (should (equal "456" (mpz-get-str 10 op1))))


;;;; conversion functions

(ert-deftest mpz-get-ui ()
  "Conversion to unsigned integer."
  (should (equal 123
		 (let ((op (mpz 123)))
		   (mpz-get-ui op)))))

(ert-deftest mpz-get-si ()
  "Conversion to signed integer."
  (should (equal 123
		 (let ((op (mpz 123)))
		   (mpz-get-si op)))))

(ert-deftest mpz-get-d ()
  "Conversion to signed integer."
  (should (equal 123.0
		 (let ((op (mpz 123)))
		   (mpz-get-d op)))))

(ert-deftest mpz-get-d-2exp ()
  "Conversion to signed integer."
  ;; We can test in the *scratch* buffer that:
  ;;
  ;;   (* 0.9609375 (expt 2 7)) => 123.0
  ;;
  (should (equal '(0.9609375 . 7)
		 (let ((op (mpz 123)))
		   (mpz-get-d-2exp op)))))

(ert-deftest mpz-get-str ()
  "Conversion to string."
  (let ((op (mpz 15)))
    (should (equal "15" (mpz-get-str +10 op)))
    (should (equal "f"  (mpz-get-str +16 op)))
    (should (equal "F"  (mpz-get-str -16 op)))))


;;;; arithmetic functions

(ert-deftest mpz-add ()
  "Add `mpz' objects."
  (should (equal 11
		 (let ((rop	(mpz))
		       (op1	(mpz 10))
		       (op2	(mpz 1)))
		   (mpz-add rop op1 op2)
		   (mpz-get-si rop)))))

(ert-deftest mpz-add-ui ()
  "Add an `mpz' object to an unsigned integer."
  (should (equal 11
		 (let ((rop	(mpz))
		       (op1	(mpz 10))
		       (op2	1))
		   (mpz-add-ui rop op1 op2)
		   (mpz-get-si rop)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-sub ()
  "Subtract an `mpz' objects from an `mpz' object."
  (should (equal 10
		 (let ((rop	(mpz))
		       (op1	(mpz 11))
		       (op2	(mpz 1)))
		   (mpz-sub rop op1 op2)
		   (mpz-get-si rop)))))

(ert-deftest mpz-sub-ui ()
  "Subtract an unsigned integer from an `mpz' object."
  (should (equal 10
		 (let ((rop	(mpz))
		       (op1	(mpz 11))
		       (op2	1))
		   (mpz-sub-ui rop op1 op2)
		   (mpz-get-si rop)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-addmul ()
  "Multiply two `mpz' objects, then add the result to another `mpz' object."
  (should (equal (+ 100 (* 11 2))
		 (let ((rop	(mpz 100))
		       (op1	(mpz 11))
		       (op2	(mpz 2)))
		   (mpz-addmul rop op1 op2)
		   (mpz-get-si rop)))))

(ert-deftest mpz-addmul-ui ()
  "Multiply an `mpz' object by an unsigned integer, then add the result to an `mpz' object."
  (should (equal (+ 100 (* 11 2))
		 (let ((rop	(mpz 100))
		       (op1	(mpz 11))
		       (op2	2))
		   (mpz-addmul-ui rop op1 op2)
		   (mpz-get-si rop)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-submul ()
  "Multiply two `mpz' objects, then subtract the result from another `mpz' object."
  (should (equal (- 100 (* 11 2))
		 (let ((rop	(mpz 100))
		       (op1	(mpz 11))
		       (op2	(mpz 2)))
		   (mpz-submul rop op1 op2)
		   (mpz-get-si rop)))))

(ert-deftest mpz-submul-ui ()
  "Multiply an `mpz' object by an unsigned integer, then subtract the result from an `mpz' object."
  (should (equal (- 100 (* 11 2))
		 (let ((rop	(mpz 100))
		       (op1	(mpz 11))
		       (op2	2))
		   (mpz-submul-ui rop op1 op2)
		   (mpz-get-si rop)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-mul ()
  "Multiply two `mpz' objects."
  (should (equal 222
		 (let ((rop	(mpz))
		       (op1	(mpz 111))
		       (op2	(mpz 2)))
		   (mpz-mul rop op1 op2)
		   (mpz-get-si rop)))))

(ert-deftest mpz-mul-si ()
  "Multiply an `mpz' object by a signed exact integer number."
  (should (equal 222
		 (let ((rop	(mpz))
		       (op1	(mpz 111))
		       (op2	2))
		   (mpz-mul-si rop op1 op2)
		   (mpz-get-si rop)))))

(ert-deftest mpz-mul-ui ()
  "Multiply an `mpz' object by an unsigned exact integer number."
  (should (equal 222
		 (let ((rop	(mpz))
		       (op1	(mpz 111))
		       (op2	2))
		   (mpz-mul-ui rop op1 op2)
		   (mpz-get-si rop)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-mul-2exp ()
  "Left shift an `mpz' object."
  (should (equal #b1010100
		 (let ((rop	(mpz))
		       (op	(mpz #b10101))
		       (bitcnt	2))
		   (mpz-mul-2exp rop op bitcnt)
		   (mpz-get-si rop)))))

(ert-deftest mpz-neg ()
  "Left shift an `mpz' object."
  (should (equal -123
		 (let ((rop	(mpz))
		       (op	(mpz 123)))
		   (mpz-neg rop op)
		   (mpz-get-si rop))))
  (should (equal +123
		 (let ((rop	(mpz))
		       (op	(mpz -123)))
		   (mpz-neg rop op)
		   (mpz-get-si rop)))))

(ert-deftest mpz-abs ()
  "Left shift an `mpz' object."
  (should (equal 123
		 (let ((rop	(mpz))
		       (op	(mpz -123)))
		   (mpz-abs rop op)
		   (mpz-get-si rop)))))


;;;; integer division functions: ceil rounding
;;
;;The template operation is:
;;
;;   N = Q * D + R
;;
;;and with ceil rounding we have:
;;
;; N = 10
;; D = 3
;; Q = ceil(N/D) = ceil(10 / 3) = ceil(3.33333) = 4
;; R = N - Q * D = 10 - 4 * 3 = -2
;;
;;for the 2exp functions:
;;
;; N = 10
;; B = 3
;; D = 2^B = 2^3 = 8
;; Q = ceil(N/D) = ceil(10 / 8) = ceil(1.25) = 2
;; R = N - Q * D = 10 - 2 * 8 = 10 - 16 = -6
;;

(ert-deftest mpz-cdiv-q ()
  ""
  (let ((Q	(mpz))
	(N	(mpz 10))
	(D	(mpz 3)))
    (mpz-cdiv-q Q N D)
    (should (equal 4 (mpz-get-si Q)))))

(ert-deftest mpz-cdiv-r ()
  ""
  (let ((R	(mpz))
	(N	(mpz 10))
	(D	(mpz 3)))
    (mpz-cdiv-r R N D)
    (should (equal -2 (mpz-get-si R)))))

(ert-deftest mpz-cdiv-qr ()
  ""
  (let ((Q	(mpz))
	(R	(mpz))
	(N	(mpz 10))
	(D	(mpz 3)))
    (mpz-cdiv-qr Q R N D)
    (should (equal +4 (mpz-get-si Q)))
    (should (equal -2 (mpz-get-si R)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-cdiv-q-ui ()
  ""
  (let ((Q	(mpz))
	(N	(mpz 10))
	(D	3))
    (let ((absR	(mpz-cdiv-q-ui Q N D)))
      (should (equal +4 (mpz-get-si Q)))
      (should (equal +2 absR)))))

(ert-deftest mpz-cdiv-r-ui ()
  ""
  (let ((R	(mpz))
	(N	(mpz 10))
	(D	3))
    (let ((absR	(mpz-cdiv-r-ui R N D)))
      (should (equal -2 (mpz-get-si R)))
      (should (equal +2 absR)))))

(ert-deftest mpz-cdiv-qr-ui ()
  ""
  (let ((Q	(mpz))
	(R	(mpz))
	(N	(mpz 10))
	(D	3))
    (let ((absR (mpz-cdiv-qr-ui Q R N D)))
      (should (equal +4 (mpz-get-si Q)))
      (should (equal -2 (mpz-get-si R)))
      (should (equal +2 absR)))))

(ert-deftest mpz-cdiv-ui ()
  ""
  (let ((N	(mpz 10))
	(D	3))
    (let ((absR	(mpz-cdiv-ui N D)))
      (should (equal +2 absR)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-cdiv-q-2exp ()
  ""
  (let ((Q	(mpz))
	(N	(mpz 10))
	(B	3))
    (mpz-cdiv-q-2exp Q N B)
    (should (equal +2 (mpz-get-si Q)))))

(ert-deftest mpz-cdiv-r-2exp ()
  ""
  (let ((R	(mpz))
	(N	(mpz 10))
	(B	3))
    (mpz-cdiv-r-2exp R N B)
    (should (equal -6 (mpz-get-si R)))))


;;;; integer division functions: floor rounding
;;
;;The template operation is:
;;
;;   N = Q * D + R
;;
;;and with floor rounding we have:
;;
;; N = 10
;; D = 3
;; Q = floor(N/D) = floor(10 / 3) = floor(3.33333) = 3
;; R = N - Q * D = 10 - 3 * 3 = +1
;;
;;for the 2exp functions:
;;
;; N = 10
;; B = 3
;; D = 2^B = 2^3 = 8
;; Q = floor(N/D) = floor(10 / 8) = floor(1.25) = 1
;; R = N - Q * D = 10 - 1 * 8 = 10 - 8 = +2
;;

(ert-deftest mpz-fdiv-q ()
  ""
  (let ((Q	(mpz))
	(N	(mpz 10))
	(D	(mpz 3)))
    (mpz-fdiv-q Q N D)
    (should (equal 3 (mpz-get-si Q)))))

(ert-deftest mpz-fdiv-r ()
  ""
  (let ((R	(mpz))
	(N	(mpz 10))
	(D	(mpz 3)))
    (mpz-fdiv-r R N D)
    (should (equal +1 (mpz-get-si R)))))

(ert-deftest mpz-fdiv-qr ()
  ""
  (let ((Q	(mpz))
	(R	(mpz))
	(N	(mpz 10))
	(D	(mpz 3)))
    (mpz-fdiv-qr Q R N D)
    (should (equal +3 (mpz-get-si Q)))
    (should (equal +1 (mpz-get-si R)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-fdiv-q-ui ()
  ""
  (let ((Q	(mpz))
	(N	(mpz 10))
	(D	3))
    (let ((absR	(mpz-fdiv-q-ui Q N D)))
      (should (equal +3 (mpz-get-si Q)))
      (should (equal +1 absR)))))

(ert-deftest mpz-fdiv-r-ui ()
  ""
  (let ((R	(mpz))
	(N	(mpz 10))
	(D	3))
    (let ((absR	(mpz-fdiv-r-ui R N D)))
      (should (equal +1 (mpz-get-si R)))
      (should (equal +1 absR)))))

(ert-deftest mpz-fdiv-qr-ui ()
  ""
  (let ((Q	(mpz))
	(R	(mpz))
	(N	(mpz 10))
	(D	3))
    (let ((absR (mpz-fdiv-qr-ui Q R N D)))
      (should (equal +3 (mpz-get-si Q)))
      (should (equal +1 (mpz-get-si R)))
      (should (equal +1 absR)))))

(ert-deftest mpz-fdiv-ui ()
  ""
  (let ((N	(mpz 10))
	(D	3))
    (let ((absR	(mpz-fdiv-ui N D)))
      (should (equal +1 absR)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-fdiv-q-2exp ()
  ""
  (let ((Q	(mpz))
	(N	(mpz 10))
	(B	3))
    (mpz-fdiv-q-2exp Q N B)
    (should (equal +1 (mpz-get-si Q)))))

(ert-deftest mpz-fdiv-r-2exp ()
  ""
  (let ((R	(mpz))
	(N	(mpz 10))
	(B	3))
    (mpz-fdiv-r-2exp R N B)
    (should (equal +2 (mpz-get-si R)))))


;;;; integer division functions: truncate rounding
;;
;;The template operation is:
;;
;;   N = Q * D + R
;;
;;and with truncate rounding we have:
;;
;; N = 10
;; D = 3
;; Q = truncate(N/D) = truncate(10 / 3) = truncate(3.33333) = 3
;; R = N - Q * D = 10 - 3 * 3 = +1
;;
;;for the 2exp functions:
;;
;; N = 10
;; B = 3
;; D = 2^B = 2^3 = 8
;; Q = truncate(N/D) = truncate(10 / 8) = truncate(1.25) = 1
;; R = N - Q * D = 10 - 1 * 8 = 10 - 8 = +2
;;

(ert-deftest mpz-tdiv-q ()
  ""
  (let ((Q	(mpz))
	(N	(mpz 10))
	(D	(mpz 3)))
    (mpz-tdiv-q Q N D)
    (should (equal 3 (mpz-get-si Q)))))

(ert-deftest mpz-tdiv-r ()
  ""
  (let ((R	(mpz))
	(N	(mpz 10))
	(D	(mpz 3)))
    (mpz-tdiv-r R N D)
    (should (equal +1 (mpz-get-si R)))))

(ert-deftest mpz-tdiv-qr ()
  ""
  (let ((Q	(mpz))
	(R	(mpz))
	(N	(mpz 10))
	(D	(mpz 3)))
    (mpz-tdiv-qr Q R N D)
    (should (equal +3 (mpz-get-si Q)))
    (should (equal +1 (mpz-get-si R)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-tdiv-q-ui ()
  ""
  (let ((Q	(mpz))
	(N	(mpz 10))
	(D	3))
    (let ((absR	(mpz-tdiv-q-ui Q N D)))
      (should (equal +3 (mpz-get-si Q)))
      (should (equal +1 absR)))))

(ert-deftest mpz-tdiv-r-ui ()
  ""
  (let ((R	(mpz))
	(N	(mpz 10))
	(D	3))
    (let ((absR	(mpz-tdiv-r-ui R N D)))
      (should (equal +1 (mpz-get-si R)))
      (should (equal +1 absR)))))

(ert-deftest mpz-tdiv-qr-ui ()
  ""
  (let ((Q	(mpz))
	(R	(mpz))
	(N	(mpz 10))
	(D	3))
    (let ((absR (mpz-tdiv-qr-ui Q R N D)))
      (should (equal +3 (mpz-get-si Q)))
      (should (equal +1 (mpz-get-si R)))
      (should (equal +1 absR)))))

(ert-deftest mpz-tdiv-ui ()
  ""
  (let ((N	(mpz 10))
	(D	3))
    (let ((absR	(mpz-tdiv-ui N D)))
      (should (equal +1 absR)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-tdiv-q-2exp ()
  ""
  (let ((Q	(mpz))
	(N	(mpz 10))
	(B	3))
    (mpz-tdiv-q-2exp Q N B)
    (should (equal +1 (mpz-get-si Q)))))

(ert-deftest mpz-tdiv-r-2exp ()
  ""
  (let ((R	(mpz))
	(N	(mpz 10))
	(B	3))
    (mpz-tdiv-r-2exp R N B)
    (should (equal +2 (mpz-get-si R)))))


;;;; integer division functions: modulo functions
;;
;;The template operation is:
;;
;;   N = Q * D + R
;;
;;and with floor rounding we have:
;;
;; N = 10
;; D = 3
;; Q = floor(N/D) = floor(10 / 3) = floor(3.33333) = 3
;; R = N - Q * D = 10 - 3 * 3 = +1
;;

(ert-deftest mpz-mod ()
  ""
  (let ((R	(mpz))
	(N	(mpz 10))
	(D	(mpz 3)))
    (mpz-mod R N D)
    (should (equal 1 (mpz-get-si R)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-mod-ui ()
  ""
  (let ((R	(mpz))
	(N	(mpz 10))
	(D	3))
    (should (equal 1 (mpz-mod-ui R N D)))))


;;;; integer division functions: exact division

(ert-deftest mpz-divexact ()
  "Set Q to N/D."
  (let ((Q	(mpz))
	(N	(mpz 9))
	(D	(mpz 3)))
    (mpz-divexact Q N D)
    (should (equal 3 (mpz-get-si Q)))))

(ert-deftest mpz-divexact-ui ()
  "Set Q to N/D."
  (let ((Q	(mpz))
	(N	(mpz 9))
	(D	3))
    (mpz-divexact-ui Q N D)
    (should (equal 3 (mpz-get-si Q)))))

;;; --------------------------------------------------------------------

;;; int mpz_divisible_p (const mpz_t N, const mpz_t D) */
(ert-deftest mpz-divisible-p ()
  "Return true if N is exactly divisible by D."
  (let ((N	(mpz 9))
	(D	(mpz 3)))
    (should (mpz-divisible-p N D))))

;;; int mpz_divisible_ui_p (const mpz_t N, unsigned long int D) */
(ert-deftest mpz-divisible-ui-p ()
  "Return true if N is exactly divisible by D."
  (let ((N	(mpz 9))
	(D	3))
    (should (mpz-divisible-ui-p N D))))

;;; int mpz_divisible_2exp_p (const mpz_t N, mp_bitcnt_t B) */
(ert-deftest mpz-divisible-2exp-p ()
  "Return true if N is exactly divisible by 2^B."
  (let ((N	(mpz 16))
	(B	3))
    (should (mpz-divisible-2exp-p N B))))

;;; --------------------------------------------------------------------

;;; int mpz_congruent_p (const mpz_t N, const mpz_t C, const mpz_t D) */
(ert-deftest mpz-congruent-p ()
  "Return non-zero if N is congruent to C modulo D; Q exists such that: N = C + Q * D."
  (let ((N	(mpz 7))
	(C	(mpz 1))
	(D	(mpz 3)))
    (should (mpz-congruent-p N C D))))

;;; int mpz_congruent_ui_p (const mpz_t N, unsigned long int C, unsigned long int D) */
(ert-deftest mpz-congruent-ui-p ()
  "Return non-zero if N is congruent to C modulo D; Q exists such that: N = C + Q * D."
  (let ((N	(mpz 7))
	(C	1)
	(D	3))
    (should (mpz-congruent-ui-p N C D))))

;;; int mpz_congruent_2exp_p (const mpz_t N, const mpz_t C, mp_bitcnt_t B) */
(ert-deftest mpz-congruent-2exp-p ()
  "Return non-zero if N is congruent to C modulo D = 2^B; Q exists such that: N = C + Q * D."
  (let ((N	(mpz 17))
	(C	(mpz 1))
	(B	3))
    (should (mpz-congruent-2exp-p N C B))))


;;;; exponentiation functions

;; void mpz_powm (mpz_t ROP, const mpz_t BASE, const mpz_t EXP, const mpz_t MOD)
(ert-deftest mpz-powm ()
  "Set ROP to (BASE raised to EXP) modulo MOD."
  (let ((rop	(mpz))
	(base	(mpz 5))
	(exp	(mpz 3))
	(mod	(mpz 2)))
    (mpz-powm rop base exp mod)
    (should (equal (mod (expt 5 3) 2)
		   (mpz-get-ui rop)))))

;; void mpz_powm_ui (mpz_t ROP, const mpz_t BASE, unsigned long int EXP, const mpz_t MOD)
(ert-deftest mpz-powm-ui ()
  "Set ROP to (BASE raised to EXP) modulo MOD."
  (let ((rop	(mpz))
	(base	(mpz 5))
	(exp	3)
	(mod	(mpz 2)))
    (mpz-powm-ui rop base exp mod)
    (should (equal (mod (expt 5 3) 2)
		   (mpz-get-ui rop)))))

;; void mpz_powm_sec (mpz_t ROP, const mpz_t BASE, const mpz_t EXP, const mpz_t MOD)
(ert-deftest mpz-powm-sec ()
  "Set ROP to (BASE raised to EXP) modulo MOD.  MOD must be odd."
  (let ((rop	(mpz))
	(base	(mpz 5))
	(exp	(mpz 3))
	(mod	(mpz 7)))
    (mpz-powm-sec rop base exp mod)
    (should (equal (mod (expt 5 3) 7)
		   (mpz-get-ui rop)))))

;; void mpz_pow_ui (mpz_t ROP, const mpz_t BASE, unsigned long int EXP)
(ert-deftest mpz-pow-ui ()
  "Set ROP to BASE raised to EXP."
  (let ((rop	(mpz))
	(base	(mpz 5))
	(exp	3))
    (mpz-pow-ui rop base exp)
    (should (equal (expt 5 3)
		   (mpz-get-ui rop)))))

;; void mpz_ui_pow_ui (mpz_t ROP, unsigned long int BASE, unsigned long int EXP)
(ert-deftest mpz-ui-pow-ui ()
  "Set ROP to BASE raised to EXP."
  (let ((rop	(mpz))
	(base	5)
	(exp	3))
    (mpz-ui-pow-ui rop base exp)
    (should (equal (expt 5 3)
		   (mpz-get-ui rop)))))


;;;; root extraction functions

;; int mpz_root (mpz_t ROP, const mpz_t OP, unsigned long int N)
(ert-deftest mpz-root ()
  "Set ROP to the truncated integer part of the Nth root of OP."
  (let ((rop	(mpz))
	(op	(mpz 8))
	(N	3))
    (mpz-root rop op N)
    (should (equal 2 (mpz-get-si rop)))))

;; void mpz_rootrem (mpz_t ROOT, mpz_t REM, const mpz_t U, unsigned long int N)
(ert-deftest mpz-rootrem ()
  "Set ROOT to the truncated integer part of the Nth root of U.  Set REM to the remainder, U-ROOT^N."
  ;; 9 = 2^3 + 1
  (let ((rop	(mpz))
	(rem	(mpz))
	(op	(mpz 9))
	(N	3))
    (mpz-rootrem rop rem op N)
    (should (equal 2 (mpz-get-si rop)))
    (should (equal 1 (mpz-get-si rem)))))

;; void mpz_sqrt (mpz_t ROP, const mpz_t OP)
(ert-deftest mpz-sqrt ()
  "Set ROP to the truncated integer part of the square root of OP."
  (let ((rop	(mpz))
	(op	(mpz 16)))
    (mpz-sqrt rop op)
    (should (equal 4 (mpz-get-si rop)))))

;; void mpz_sqrtrem (mpz_t ROP1, mpz_t ROP2, const mpz_t OP)
(ert-deftest mpz-sqrtrem ()
  "Set ROP1 to the truncated integer part of the square root of OP.  Set ROP2 to the remainder OP-ROP1*ROP1."
  ;; 17 = 4^2 + 1
  (let ((rop	(mpz))
	(rem	(mpz))
	(op	(mpz 17)))
    (mpz-sqrtrem rop rem op)
    (should (equal 4 (mpz-get-si rop)))
    (should (equal 1 (mpz-get-si rem)))))

;; int mpz_perfect_power_p (const mpz_t OP)
(ert-deftest mpz-perfect-power-p ()
  "Return true if OP is a perfect power."
  (should (mpz-perfect-power-p (mpz 8)))
  (should (not (mpz-perfect-power-p (mpz 7)))))

;; int mpz_perfect_square_p (const mpz_t OP)
(ert-deftest mpz-perfect-square-p ()
  "Return non-zero if OP is a perfect square."
  (should (mpz-perfect-square-p (mpz 16)))
  (should (not (mpz-perfect-square-p (mpz 7)))))


;;;; number theoretic functions

;; int mpz_probab_prime_p (const mpz_t N, int REPS)
(ert-deftest mpz-probab-prime-p ()
  "Determine whether N is prime."
  (should (equal 2 (mpz-probab-prime-p (mpz 3) 2))))

;; void mpz_nextprime (mpz_t ROP, const mpz_t OP)
(ert-deftest mpz-nextprime ()
  "Set ROP to the next prime greater than OP."
  (let ((rop	(mpz))
	(op	(mpz 5)))
    (mpz-nextprime rop op)
    (should (equal 7 (mpz-get-si rop)))))

;; void mpz_gcd (mpz_t ROP, const mpz_t OP1, const mpz_t OP2)
(ert-deftest mpz-gcd ()
  "Set ROP to the greatest common divisor of OP1 and OP2."
  (let ((rop	(mpz))
	(op1	(mpz 10))
	(op2	(mpz 12)))
    (mpz-gcd rop op1 op2)
    (should (equal 2 (mpz-get-si rop)))))

;; unsigned long int mpz_gcd_ui (mpz_t ROP, const mpz_t OP1, unsigned long int OP2)
(ert-deftest mpz-gcd-ui ()
  "Set ROP to the greatest common divisor of OP1 and OP2."
  (let ((rop	(mpz))
	(op1	(mpz 10))
	(op2	12))
    (let ((rop1 (mpz-gcd-ui rop op1 op2)))
      (should (equal 2 (mpz-get-si rop)))
      (should (equal 2 rop1)))))

;; void mpz_gcdext (mpz_t G, mpz_t S, mpz_t T, const mpz_t A, const mpz_t B)
(ert-deftest mpz-gcdext ()
  "Set G to the greatest common divisor of A and B, and in addition set S and T to coefficients satisfying A*S + B*T = G."
  (let ((G	(mpz))
	(S	(mpz))
	(T	(mpz))
	(A	(mpz 110))
	(B	(mpz 82)))
    (mpz-gcdext G S T A B)
    ;;(mmux-gmp-print-stderr (list (mpz-get-si G) (mpz-get-si S) (mpz-get-si T) (mpz-get-si A) (mpz-get-si B)) )
    (should (equal +2 (mpz-get-si G)))
    (should (equal +3 (mpz-get-si S)))
    (should (equal -4 (mpz-get-si T)))
    ;; A * S + B * T = G -> 110 * 3 + 82 * (-4) = 2
    (should (equal (mpz-get-si G) (+ (* (mpz-get-si A) (mpz-get-si S))
				     (* (mpz-get-si B) (mpz-get-si T)))))))

;; void mpz_lcm (mpz_t ROP, const mpz_t OP1, const mpz_t OP2)
(ert-deftest mpz-lcm ()
  "Set ROP to the least common multiple of OP1 and OP2."
  (let ((rop	(mpz))
	(op1	(mpz (* 2 5)))
	(op2	(mpz (* 2 7))))
    (mpz-lcm rop op1 op2)
    (should (equal (* 2 7 5) (mpz-get-si rop)))))

;; void mpz_lcm_ui (mpz_t ROP, const mpz_t OP1, unsigned long OP2)
(ert-deftest mpz-lcm-ui ()
  "Set ROP to the least common multiple of OP1 and OP2."
  (let ((rop	(mpz))
	(op1	(mpz (* 2 5)))
	(op2	(* 2 7)))
    (mpz-lcm-ui rop op1 op2)
    (should (equal (* 2 7 5) (mpz-get-si rop)))))

;; int mpz_invert (mpz_t ROP, const mpz_t OP1, const mpz_t OP2)
(ert-deftest mpz-invert ()
  "Compute the inverse of OP1 modulo OP2 and put the result in ROP."
  ;;OP2 divides (evenly) the quantity ROP * OP1 − 1
  ;;
  ;; ROP * OP1 = X * OP2 + 1
  ;; 4 * 3 = 1 * 11 + 1
  (let ((rop	(mpz))
	(op1	(mpz 3))
	(op2	(mpz 11)))
    (let ((rv (mpz-invert rop op1 op2)))
      (should rv)
      (should (equal 4 (mpz-get-si rop))))))

;; int mpz_jacobi (const mpz_t A, const mpz_t B)
(ert-deftest mpz-jacobi ()
  "Calculate the Jacobi symbol (A/B).  This is defined only for B odd."
  (let ((A	(mpz 11))
	(B	(mpz 9)))
    (should (equal 1 (mpz-jacobi A B)))))

;; int mpz_legendre (const mpz_t A, const mpz_t P)
(ert-deftest mpz-legendre ()
  "Calculate the Legendre symbol (A/P)."
  (let ((A	(mpz 20))
	(P	(mpz 11)))
    (should (equal 1 (mpz-legendre A P)))))

;; int mpz_kronecker (const mpz_t A, const mpz_t B)
(ert-deftest mpz-kronecker ()
  "Calculate the Jacobi symbol (A/B) with the Kronecker extension (a/2)=(2/a) when a odd, or (a/2)=0 when a even."
  (let ((A	(mpz 15))
	(B	(mpz 4)))
    (should (equal 1 (mpz-kronecker A B)))))

;; int mpz_kronecker_si (const mpz_t A, long B)
(ert-deftest mpz-kronecker-si ()
  "Calculate the Jacobi symbol (A/B) with the Kronecker extension (a/2)=(2/a) when a odd, or (a/2)=0 when a even."
  (let ((A	(mpz 15))
	(B	4))
    (should (equal 1 (mpz-kronecker-si A B)))))

;; int mpz_kronecker_ui (const mpz_t A, unsigned long B)
(ert-deftest mpz-kronecker-ui ()
  "Calculate the Jacobi symbol (A/B) with the Kronecker extension (a/2)=(2/a) when a odd, or (a/2)=0 when a even."
  (let ((A	(mpz 15))
	(B	4))
    (should (equal 1 (mpz-kronecker-ui A B)))))

;; int mpz_si_kronecker (long A, const mpz_t B)
(ert-deftest mpz-si-kronecker ()
  "Calculate the Jacobi symbol (A/B) with the Kronecker extension (a/2)=(2/a) when a odd, or (a/2)=0 when a even."
  (let ((A	15)
	(B	(mpz 4)))
    (should (equal 1 (mpz-si-kronecker A B)))))

;; int mpz_ui_kronecker (unsigned long A, const mpz_t B)
(ert-deftest mpz-ui-kronecker ()
  "Calculate the Jacobi symbol (A/B) with the Kronecker extension (a/2)=(2/a) when a odd, or (a/2)=0 when a even."
  (let ((A	15)
	(B	(mpz 4)))
    (should (equal 1 (mpz-ui-kronecker A B)))))

;; mp_bitcnt_t mpz_remove (mpz_t ROP, const mpz_t OP, const mpz_t F)
(ert-deftest mpz-remove ()
  "Remove all occurrences of the factor F from OP and store the result in ROP."
  (let ((rop	(mpz))
	(op	(mpz 45))
	(F	(mpz 3)))
    (let ((rv (mpz-remove rop op F)))
      (should (equal 2 rv))
      (should (equal 5 (mpz-get-si rop))))))

;; void mpz_fac_ui (mpz_t ROP, unsigned long int N)
(ert-deftest mpz-fac-ui ()
  "Set ROP to the factorial of N."
  (let ((rop	(mpz))
	(N	4))
    (mpz-fac-ui rop N)
    (should (equal (* 4 3 2 1) (mpz-get-si rop)))))

;; void mpz_2fac_ui (mpz_t ROP, unsigned long int N)
(ert-deftest mpz-2fac-ui ()
  "Set ROP to the double factorial of N: N!!."
  (let ((rop	(mpz))
	(N	9))
    (mpz-2fac-ui rop N)
    ;;See:
    ;;
    ;;  https://en.wikipedia.org/wiki/Factorial#Multifactorials
    ;;
    ;;from the full factorial select the first number every 2:
    ;;
    ;; (* 9 8 7 6 5 4 3 2 1) -> (* 9 7 5 3 1) => 945
    ;;    ^   ^   ^   ^   ^
    ;;
    (should (equal (* 9 7 5 3 1) (mpz-get-si rop)))))

;; void mpz_mfac_uiui (mpz_t ROP, unsigned long int N, unsigned long int M)
(ert-deftest mpz-mfac-uiui ()
  "Set ROP to the M-multi-factorial of N: N!^(M)."
  (let ((rop	(mpz))
	(N	10)
	(M	4))
    (mpz-mfac-uiui rop N M)
    ;;See:
    ;;
    ;;  https://en.wikipedia.org/wiki/Factorial#Multifactorials
    ;;
    ;;from the full factorial select the first number every 4:
    ;;
    ;;(* 10 9 8 7 6 5 4 3 2 1) -> (* 10 6 2) => 120
    ;;   ^        ^       ^
    (should (equal (* 10 6 2) (mpz-get-si rop)))))

;; void mpz_primorial_ui (mpz_t ROP, unsigned long int N)
(ert-deftest mpz-primorial-ui ()
  "Set ROP to the primorial of N: the product of all positive prime numbers <=N."
  ;; (* 7 5 3 2 1) => 210
  (let ((rop	(mpz))
	(op	7))
    (mpz-primorial-ui rop op)
    (should (equal 210 (mpz-get-si rop)))))

;; void mpz_bin_ui (mpz_t ROP, const mpz_t N, unsigned long int K)
(ert-deftest mpz-bin-ui ()
  "Compute the binomial coefficient N over K and store the result in ROP."
  (let ((rop	(mpz))
	(N	(mpz 4))
	(K	2))
    (mpz-bin-ui rop N K)
    (should (equal 6 (mpz-get-si rop)))))

;; void mpz_bin_uiui (mpz_t ROP, unsigned long int N, unsigned long int K)
(ert-deftest mpz-bin-uiui ()
  "Compute the binomial coefficient N over K and store the result in ROP."
  (let ((rop	(mpz))
	(N	4)
	(K	2))
    (mpz-bin-uiui rop N K)
    (should (equal 6 (mpz-get-si rop)))))

;; void mpz_fib_ui (mpz_t FN, unsigned long int N)
(ert-deftest mpz-fib-ui ()
  "Set FN to to F[N]: the N'th Fibonacci number."
  (let ((FN	(mpz))
	(N	20))
    (mpz-fib-ui FN N)
    (should (equal 6765 (mpz-get-si FN)))))

;; void mpz_fib2_ui (mpz_t FN, mpz_t FNSUB1, unsigned long int N)
(ert-deftest mpz-fib2-ui ()
  "Set FN to to F[N]: the N'th Fibonacci number.  Set FNSUB1 to to F[N-1]."
  (let ((FN	(mpz))
	(FNSUB1	(mpz))
	(N	20))
    (mpz-fib2-ui FN FNSUB1 N)
    (should (equal 6765 (mpz-get-si FN)))
    (should (equal 4181 (mpz-get-si FNSUB1)))))

;; void mpz_lucnum_ui (mpz_t LN, unsigned long int N)
(ert-deftest mpz-lucnum-ui ()
  "Set LN to to L[N]: the N'th Lucas number."
  (let ((LN	(mpz))
	(N	9))
    (mpz-lucnum-ui LN N)
    (should (equal 76 (mpz-get-si LN)))))

;; void mpz_lucnum2_ui (mpz_t LN, mpz_t LNSUB1, unsigned long int N)
(ert-deftest mpz-lucnum2-ui ()
  "Set LN to to L[N]: the N'th Lucas number.  Set LNSUB1 to to L[N-1]."
  (let ((LN	(mpz))
	(LNSUB1	(mpz))
	(N	9))
    (mpz-lucnum2-ui LN LNSUB1 N)
    (should (equal 76 (mpz-get-si LN)))
    (should (equal 47 (mpz-get-si LNSUB1)))))


;;;; comparison

;; int mpz_cmp (const mpz_t OP1, const mpz_t OP2)
(ert-deftest mpz-cmp ()
  "Compare OP1 and OP2."
  (should (equal -1 (mpz-cmp (mpz 1) (mpz 2))))
  (should (equal  0 (mpz-cmp (mpz 0) (mpz 0))))
  (should (equal +1 (mpz-cmp (mpz 2) (mpz 1)))))

;; int mpz_cmp_d (const mpz_t OP1, double OP2)
(ert-deftest mpz-cmp-d ()
  "Compare OP1 and OP2."
  (should (equal -1 (mpz-cmp-d (mpz 1) 2.0)))
  (should (equal  0 (mpz-cmp-d (mpz 0) 0.0)))
  (should (equal +1 (mpz-cmp-d (mpz 2) 1.0))))

;; int mpz_cmp_si (const mpz_t OP1, signed long int OP2)
(ert-deftest mpz-cmp-si ()
  "Compare OP1 and OP2."
  (should (equal -1 (mpz-cmp-si (mpz -2) -1)))
  (should (equal  0 (mpz-cmp-si (mpz  0)  0)))
  (should (equal +1 (mpz-cmp-si (mpz -1) -2))))

;; int mpz_cmp_ui (const mpz_t OP1, unsigned long int OP2)
(ert-deftest mpz-cmp-ui ()
  "Compare OP1 and OP2."
  (should (equal -1 (mpz-cmp-ui (mpz 1) 2)))
  (should (equal  0 (mpz-cmp-ui (mpz 0) 0)))
  (should (equal +1 (mpz-cmp-ui (mpz 2) 1))))

;;; --------------------------------------------------------------------

;; int mpz_cmpabs (const mpz_t OP1, const mpz_t OP2)
(ert-deftest mpz-cmpabs ()
  "Compare the absolute values of OP1 and OP2."
  (should (equal -1 (mpz-cmpabs (mpz 1) (mpz -2))))
  (should (equal  0 (mpz-cmpabs (mpz 0) (mpz 0))))
  (should (equal +1 (mpz-cmpabs (mpz 2) (mpz 1)))))

;; int mpz_cmpabs_d (const mpz_t OP1, double OP2)
(ert-deftest mpz-cmpabs-d ()
  "Compare the absolute values of OP1 and OP2."
  (should (equal -1 (mpz-cmpabs-d (mpz 1) -2.0)))
  (should (equal  0 (mpz-cmpabs-d (mpz 0)  0.0)))
  (should (equal +1 (mpz-cmpabs-d (mpz 2)  1.0))))

;; int mpz_cmpabs_ui (const mpz_t OP1, unsigned long int OP2)
(ert-deftest mpz-cmpabs-ui ()
  "Compare the absolute values of OP1 and OP2."
  (should (equal -1 (mpz-cmpabs-ui (mpz  1) 2)))
  (should (equal  0 (mpz-cmpabs-ui (mpz  0) 0)))
  (should (equal +1 (mpz-cmpabs-ui (mpz -2) 1))))

;;; --------------------------------------------------------------------

;; int mpz_sgn (const mpz_t OP)
(ert-deftest mpz-sgn ()
  ""
  (should (equal +1 (mpz-sgn (mpz +1))))
  (should (equal  0 (mpz-sgn (mpz  0))))
  (should (equal -1 (mpz-sgn (mpz -1)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-zero-p ()
  "Return true if OP is zero; otherwise return false."
  (should (not (mpz-zero-p (mpz -1))))
  (should      (mpz-zero-p (mpz  0)))
  (should (not (mpz-zero-p (mpz +1)))))

(ert-deftest mpz-non-zero-p ()
  "Return true if OP is non-zero; otherwise return false."
  (should      (mpz-non-zero-p (mpz -1)))
  (should (not (mpz-non-zero-p (mpz  0))))
  (should      (mpz-non-zero-p (mpz +1))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-positive-p ()
  "Return true if OP is strictly positive; otherwise return false."
  (should (not (mpz-positive-p (mpz -1))))
  (should (not (mpz-positive-p (mpz  0))))
  (should      (mpz-positive-p (mpz +1))))

(ert-deftest mpz-negative-p ()
  "Return true if OP is strictly negative; otherwise return false."
  (should      (mpz-negative-p (mpz -1)))
  (should (not (mpz-negative-p (mpz  0))))
  (should (not (mpz-negative-p (mpz +1)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-non-positive-p ()
  "Return true if OP is non-positive; otherwise return false."
  (should      (mpz-non-positive-p (mpz -1)))
  (should      (mpz-non-positive-p (mpz  0)))
  (should (not (mpz-non-positive-p (mpz +1)))))

(ert-deftest mpz-non-negative-p ()
  "Return true if OP is non-negative; otherwise return false."
  (should (not (mpz-non-negative-p (mpz -1))))
  (should      (mpz-non-negative-p (mpz  0)))
  (should      (mpz-non-negative-p (mpz +1))))

;;; --------------------------------------------------------------------

(ert-deftest mpz< ()
  "Compare operands."
  (should      (mpz< (mpz 1) (mpz 2)))
  (should (not (mpz< (mpz 1) (mpz 1))))
  (should (not (mpz< (mpz 2) (mpz 1)))))

(ert-deftest mpz> ()
  "Compare operands."
  (should (not (mpz> (mpz 1) (mpz 2))))
  (should (not (mpz> (mpz 1) (mpz 1))))
  (should      (mpz> (mpz 2) (mpz 1))))

(ert-deftest mpz<= ()
  "Compare operands."
  (should      (mpz<= (mpz 1) (mpz 2)))
  (should      (mpz<= (mpz 1) (mpz 1)))
  (should (not (mpz<= (mpz 2) (mpz 1)))))

(ert-deftest mpz>= ()
  "Compare operands."
  (should (not (mpz>= (mpz 1) (mpz 2))))
  (should      (mpz>= (mpz 1) (mpz 1)))
  (should      (mpz>= (mpz 2) (mpz 1))))

(ert-deftest mpz= ()
  "Compare operands."
  (should (not (mpz= (mpz 1) (mpz 2))))
  (should      (mpz= (mpz 1) (mpz 1)))
  (should (not (mpz= (mpz 2) (mpz 1)))))


;;;; logical and bit manipulation functions

;; void mpz_and (mpz_t ROP, const mpz_t OP1, const mpz_t OP2)
(ert-deftest mpz-and ()
  "Set ROP to OP1 bitwise-and OP2."
  (let ((rop	(mpz))
	(op1	(mpz #b1010101))
	(op2	(mpz #b1101011)))
    (mpz-and rop op1 op2)
    (should (equal #b1000001 (mpz-get-si rop)))))

;; void mpz_ior (mpz_t ROP, const mpz_t OP1, const mpz_t OP2)
(ert-deftest mpz-ior ()
  "Set ROP to OP1 bitwise inclusive-or OP2."
  (let ((rop	(mpz))
	(op1	(mpz #b1010101))
	(op2	(mpz #b1110101)))
    (mpz-ior rop op1 op2)
    (should (equal #b1110101 (mpz-get-si rop)))))

;; void mpz_xor (mpz_t ROP, const mpz_t OP1, const mpz_t OP2)
(ert-deftest mpz-xor ()
  "Set ROP to OP1 bitwise exclusive-or OP2."
  (let ((rop	(mpz))
	(op1	(mpz #b1110101))
	(op2	(mpz #b1011101)))
    (mpz-xor rop op1 op2)
    (should (equal #b0101000 (mpz-get-si rop)))))

;; void mpz_com (mpz_t ROP, const mpz_t OP)
(ert-deftest mpz-com ()
  "Set ROP to the one's complement of OP."
  (let ((rop	(mpz))
	(op	(mpz #b10)))
    (mpz-com rop op)
    (should (equal -3 (mpz-get-si rop)))))

;; mp_bitcnt_t mpz_popcount (const mpz_t OP)
(ert-deftest mpz-popcount ()
  "Return the population count of OP."
  (let ((op	(mpz #b1010101)))
    (should (equal 4 (mpz-popcount op)))))

;; mp_bitcnt_t mpz_hamdist (const mpz_t OP1, const mpz_t OP2)
(ert-deftest mpz-hamdist ()
  "Return the hamming distance between the two operands."
  (let ((op1	(mpz 63))
	(op2	(mpz 70)))
    (should (equal 5 (mpz-hamdist op1 op2)))))

;; mp_bitcnt_t mpz_scan0 (const mpz_t OP, mp_bitcnt_t STARTING_BIT)
(ert-deftest mpz-scan0 ()
  "Scan OP for the first 0 bit."
  (let ((op		(mpz #b1000110))
	(starting-bit	1))
    (should (equal 3 (mpz-scan0 op starting-bit))))
  (let ((op		(mpz #b1011111))
	(starting-bit	2))
    (should (equal 5 (mpz-scan0 op starting-bit)))))

;; mp_bitcnt_t mpz_scan1 (const mpz_t OP, mp_bitcnt_t STARTING_BIT)
(ert-deftest mpz-scan1 ()
  "Scan OP for the first 1 bit."
  (let ((op		(mpz #b1000110))
	(starting-bit	3))
    (should (equal 6 (mpz-scan1 op starting-bit))))
  (let ((op		(mpz #b010000))
  	(starting-bit	2))
    (should (equal 4 (mpz-scan1 op starting-bit)))))

;; void mpz_setbit (mpz_t ROP, mp_bitcnt_t BIT_INDEX)
(ert-deftest mpz-setbit ()
  "Set bit BIT_INDEX in ROP."
  (let ((rop		(mpz))
	(bit-index	3))
    (mpz-setbit rop bit-index)
    (should (equal 8 (mpz-get-si rop)))))

;; void mpz_clrbit (mpz_t ROP, mp_bitcnt_t BIT_INDEX)
(ert-deftest mpz-clrbit ()
  "Clear bit BIT_INDEX in ROP."
  (let ((rop		(mpz #b00100))
	(bit-index	2))
    (mpz-clrbit rop bit-index)
    (should (equal 0 (mpz-get-si rop)))))

;; void mpz_combit (mpz_t ROP, mp_bitcnt_t BIT_INDEX)
(ert-deftest mpz-combit ()
  "Complement bit BIT_INDEX in ROP."
  (let ((rop		(mpz #b00100))
	(bit-index	2))
    (mpz-combit rop bit-index)
    (should (equal 0 (mpz-get-si rop)))))

;; int mpz_tstbit (const mpz_t OP, mp_bitcnt_t BIT_INDEX)
(ert-deftest mpz-tstbit ()
  "Test bit BIT_INDEX in OP and return 0 or 1 accordingly."
  (let ((op		(mpz #b01000))
	(bit-index	3))
    (should (equal t (mpz-tstbit op bit-index))))
  (let ((op		(mpz #b10111))
	(bit-index	3))
    (should (equal nil (mpz-tstbit op bit-index)))))


;;;; random number functions

;; void mpz_urandomb (mpz_t ROP, gmp_randstate_t STATE, mp_bitcnt_t N)
(ert-deftest mpz-urandomb ()
  "Generate a uniformly distributed random integer in the range 0 to 2^N-1, inclusive."
  (let ((rop		(mpz))
	(state		(gmp-randstate))
	(N		3))
    (gmp-randinit-default state)
    (gmp-randseed-ui state 123)
    (mpz-urandomb rop state N)
    (let ((num (mpz-get-ui rop)))
      (should (and (>= num 0)
		   (<  num (expt 2 N)))))))

;; void mpz_urandomm (mpz_t ROP, gmp_randstate_t STATE, const mpz_t N)
(ert-deftest mpz-urandomm ()
  "Generate a uniform random integer in the range 0 to N-1, inclusive."
  (let ((rop		(mpz))
	(state		(gmp-randstate))
	(N		(mpz 3)))
    (gmp-randinit-default state)
    (gmp-randseed-ui state 123)
    (mpz-urandomm rop state N)
    (let ((num (mpz-get-ui rop)))
      (should (and (>= num 0)
		   (<  num (mpz-get-ui N)))))))

;; void mpz_rrandomb (mpz_t ROP, gmp_randstate_t STATE, mp_bitcnt_t N)
(ert-deftest mpz-rrandomb ()
  "Generate a random integer with long strings of zeros and ones in the binary representation."
  (let ((rop		(mpz))
	(state		(gmp-randstate))
	(N		3))
    (gmp-randinit-default state)
    (gmp-randseed-ui state 123)
    (mpz-rrandomb rop state N)
    (let ((num (mpz-get-ui rop)))
      (should (and (>= num 0)
		   (<  num (expt 2 N)))))))

;; void mpz_random (mpz_t ROP, mp_size_t MAX_SIZE)
(ert-deftest mpz-random ()
  "Generate a random integer of at most MAX-SIZE limbs."
  (let ((rop		(mpz))
	(state		(gmp-randstate))
	(max-size	1))
    (gmp-randinit-default state)
    (gmp-randseed-ui state 123)
    (mpz-random rop max-size)
    (should rop)))

;; void mpz_random2 (mpz_t ROP, mp_size_t MAX_SIZE)
(ert-deftest mpz-random2 ()
  "Generate a random integer of at most MAX-SIZE limbs, with long strings of zeros and ones in the binary representation."
  (let ((rop		(mpz))
	(state		(gmp-randstate))
	(max-size	1))
    (gmp-randinit-default state)
    (gmp-randseed-ui state 123)
    (mpz-random2 rop max-size)
    (should rop)))


;;;; miscellaneous functions

;; int mpz_fits_ulong_p (const mpz_t OP)
(ert-deftest mpz-fits-ulong-p ()
  ""
  (should (mpz-fits-ulong-p (mpz 123)))
  (should (not (mpz-fits-ulong-p (let ((rop (mpz))) (mpz-ui-pow-ui rop 2 70) rop)))))

;; int mpz_fits_slong_p (const mpz_t OP)
(ert-deftest mpz-fits-slong-p ()
  ""
  (should (mpz-fits-slong-p (mpz 123)))
  (should (not (mpz-fits-slong-p (let ((rop (mpz))) (mpz-ui-pow-ui rop 2 70) rop)))))

;; int mpz_fits_uint_p (const mpz_t OP)
(ert-deftest mpz-fits-uint-p ()
  ""
  (should (mpz-fits-uint-p (mpz 123)))
  (should (not (mpz-fits-uint-p (let ((rop (mpz))) (mpz-ui-pow-ui rop 2 70) rop)))))

;; int mpz_fits_sint_p (const mpz_t OP)
(ert-deftest mpz-fits-sint-p ()
  ""
  (should (mpz-fits-sint-p (mpz 123)))
  (should (not (mpz-fits-sint-p (let ((rop (mpz))) (mpz-ui-pow-ui rop 2 70) rop)))))

;; int mpz_fits_ushort_p (const mpz_t OP)
(ert-deftest mpz-fits-ushort-p ()
  ""
  (should (mpz-fits-ushort-p (mpz 123)))
  (should (not (mpz-fits-ushort-p (let ((rop (mpz))) (mpz-ui-pow-ui rop 2 70) rop)))))

;; int mpz_fits_sshort_p (const mpz_t OP)
(ert-deftest mpz-fits-sshort-p ()
  ""
  (should (mpz-fits-sshort-p (mpz 123)))
  (should (not (mpz-fits-sshort-p (let ((rop (mpz))) (mpz-ui-pow-ui rop 2 70) rop)))))

;;; --------------------------------------------------------------------

;; int mpz_odd_p (const mpz_t OP)
(ert-deftest mpz-odd-p ()
  "Return true if the operand is odd; otherwise return false."
  (should (mpz-odd-p (mpz 1)))
  (should (not (mpz-odd-p (mpz 2)))))

;; int mpz_even_p (const mpz_t OP)
(ert-deftest mpz-even-p ()
  "Return true if the operand is even; otherwise return false."
  (should (mpz-even-p (mpz 2)))
  (should (not (mpz-even-p (mpz 1)))))

;;; --------------------------------------------------------------------

;; size_t mpz_sizeinbase (const mpz_t OP, int BASE)
(ert-deftest mpz-sizeinbase ()
  ""
  (should (equal 1 (mpz-sizeinbase (mpz 1) 2))))


;;;; done

(garbage-collect)
(ert-run-tests-batch-and-exit)

;;; test.el ends here
