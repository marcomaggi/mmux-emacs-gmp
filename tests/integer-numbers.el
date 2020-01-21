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

;;; Code:

(require 'ert)
(require 'mmux-emacs-gmp)


;;;; helpers

(defmacro check (EXPR => RESULT)
  `(should (equal ,RESULT ,EXPR)))


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
