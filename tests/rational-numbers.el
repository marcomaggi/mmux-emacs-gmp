;;; rational-numbers.el --- dynamic module test

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


;;;; allocation functions

(ert-deftest mpq-1 ()
  "Build an `mpq' object: integer init values."
  (should (equal "3/4" (let ((op (mpq 3 4)))
			 (mpq-get-str 10 op)))))

(ert-deftest mpq-2 ()
  "Build an `mpq' object: floating-point init value."
  (should (equal "5404319552844595/4503599627370496"
		 (let ((op (mpq 1.2)))
		   (mpq-get-str 10 op)))))

(ert-deftest mpq-3 ()
  "Build an `mpq' object: no init values."
  (should (equal "0" (let ((op (mpq)))
		       (mpq-get-str 10 op)))))


;;;; assignment functions

(ert-deftest mpq-set ()
  "Assign an `mpq' object to an `mpq' object."
  (should (equal "3/4" (let ((rop (mpq))
			     (op  (mpq)))
			 (mpq-set-si rop 3 4)
			 (mpq-set    op rop)
			 (mpq-get-str 10 op)))))

(ert-deftest mpq-set-si ()
  "Assign two signed exact integers to an `mpq' object."
  (should (equal "3/4" (let ((rop (mpq)))
			 (mpq-set-si rop 3 4)
			 (mpq-get-str 10 rop)))))

(ert-deftest mpq-set-si-1 ()
  "Assign two signed exact integers to an `mpq' object."
  (should (equal "-3/4" (let ((rop (mpq)))
			  (mpq-set-si rop -3 4)
			  (mpq-get-str 10 rop)))))

(ert-deftest mpq-set-ui ()
  "Assign two unsigned exact integers to an `mpq' object."
  (should (equal "3/4" (let ((rop (mpq)))
			 (mpq-set-ui rop 3 4)
			 (mpq-get-str 10 rop)))))

(ert-deftest mpq-set-d ()
  "Assign a floating-point to an `mpq' object."
  (should (equal "5404319552844595/4503599627370496"
		 (let ((rop (mpq)))
		   (mpq-set-d rop 1.2)
		   (mpq-get-str 10 rop)))))

(ert-deftest mpq-set-z ()
  "Assign an `mpz' object to an `mpq' object."
  (should (equal "123"
		 (let ((rop (mpq))
		       (op  (mpz 123)))
		   (mpq-set-z rop op)
		   (mpq-get-str 10 rop)))))

(ert-deftest mpq-set-f ()
  "Assign an `mpf' object to an `mpq' object."
  (should (equal "5404319552844595/4503599627370496"
		 (let ((rop (mpq))
		       (op  (mpf 1.2)))
		   (mpq-set-f rop op)
		   (mpq-get-str 10 rop)))))

(ert-deftest mpq-set-str ()
  "Assign a string value to an `mpq' object."
  (should (equal "3/4"
		 (let ((rop (mpq)))
		   (mpq-set-str rop "3/4" 10)
		   (mpq-get-str 10 rop)))))

(ert-deftest mpq-swap ()
  "Swap values between `mpq' objects."
  (let ((op1 (mpq))
	(op2 (mpq)))
    (mpq-set-si op1 3 4)
    (mpq-set-si op2 5 6)
    (mpq-swap op1 op2)
    (should (equal "3/4" (mpq-get-str 10 op2)))
    (should (equal "5/6" (mpq-get-str 10 op1)))))


;;;; conversion functions

(ert-deftest mpq-get-d ()
  "Conversion to signed integer."
  (should (equal 1.2
		 (let ((op (mpq 1.2)))
		   (mpq-get-d op)))))

(ert-deftest mpq-get-str ()
  "Conversion to string."
  (let ()
    (defconst op (mpq))
    (mpq-set-si op 17 13)
    (should (equal "17/13" (mpq-get-str +10 op)))
    (should (equal "11/d"  (mpq-get-str +16 op)))
    (should (equal "11/D"  (mpq-get-str -16 op)))))


;;;; arithmetic functions




;;;; rational number functions: comparison

;; int mpq_cmp (const mpq_t OP1, const mpq_t OP2)
(ert-deftest mpq-cmp ()
  "Compare OP1 and OP2."
  (should (equal -1 (mpq-cmp (mpq 1 2) (mpq 3 2))))
  (should (equal  0 (mpq-cmp (mpq 1 2) (mpq 1 2))))
  (should (equal +1 (mpq-cmp (mpq 3 2) (mpq 1 2)))))

;; int mpq_cmp_z (const mpq_t OP1, const mpz_t OP2)
(ert-deftest mpq-cmp-z ()
  "Compare OP1 and OP2."
  (should (equal -1 (mpq-cmp-z (mpq 1 2) (mpz 1))))
  (should (equal  0 (mpq-cmp-z (mpq 1 1) (mpz 1))))
  (should (equal +1 (mpq-cmp-z (mpq 3 2) (mpz 1)))))

;; int mpq_cmp_ui (const mpq_t OP1, unsigned long int NUM2, unsigned long int DEN2)
(ert-deftest mpq-cmp-ui ()
  "Compare OP1 and NUM2/DEN2."
  (should (equal -1 (mpq-cmp-ui (mpq 1 2) 3 2)))
  (should (equal  0 (mpq-cmp-ui (mpq 1 2) 1 2)))
  (should (equal +1 (mpq-cmp-ui (mpq 3 2) 1 2))))

;; int mpq_cmp_si (const mpq_t OP1, long int NUM2, unsigned long int DEN2)
(ert-deftest mpq-cmp-si ()
  "Compare OP1 and NUM2/DEN2."
  (should (equal +1 (mpq-cmp-si (mpq -1 2) -3 2)))
  (should (equal  0 (mpq-cmp-si (mpq -1 2) -1 2)))
  (should (equal -1 (mpq-cmp-si (mpq -3 2) -1 2))))

;; int mpq_sgn (const mpq_t OP)
(ert-deftest mpq-sgn ()
  "Return +1 if OP > 0, 0 if OP = 0, and -1 if OP < 0."
  (should (equal +1 (mpq-sgn (mpq +1 2))))
  (should (equal  0 (mpq-sgn (mpq  0 2))))
  (should (equal -1 (mpq-sgn (mpq -1 2)))))

;; int mpq_equal (const mpq_t OP1, const mpq_t OP2)
(ert-deftest mpq-equal ()
  "Return non-zero if OP1 and OP2 are equal, zero if they are non-equal."
  (should      (mpq-equal (mpq 1 2) (mpq 1 2)))
  (should (not (mpq-equal (mpq 1 2) (mpq 3 2)))))

;;; --------------------------------------------------------------------

(ert-deftest mpq-zero-p ()
  "Return true if OP is zero; otherwise return false."
  (should (not (mpq-zero-p (mpq -1 2))))
  (should      (mpq-zero-p (mpq  0 2)))
  (should (not (mpq-zero-p (mpq +1 2)))))

(ert-deftest mpq-non-zero-p ()
  "Return true if OP is non-zero; otherwise return false."
  (should      (mpq-non-zero-p (mpq -1 2)))
  (should (not (mpq-non-zero-p (mpq  0 2))))
  (should      (mpq-non-zero-p (mpq +1 2))))

;;; --------------------------------------------------------------------

(ert-deftest mpq-positive-p ()
  "Return true if OP is strictly positive; otherwise return false."
  (should (not (mpq-positive-p (mpq -1 2))))
  (should (not (mpq-positive-p (mpq  0 2))))
  (should      (mpq-positive-p (mpq +1 2))))

(ert-deftest mpq-negative-p ()
  "Return true if OP is strictly negative; otherwise return false."
  (should      (mpq-negative-p (mpq -1 2)))
  (should (not (mpq-negative-p (mpq  0 2))))
  (should (not (mpq-negative-p (mpq +1 2)))))

;;; --------------------------------------------------------------------

(ert-deftest mpq-non-positive-p ()
  "Return true if OP is non-positive; otherwise return false."
  (should      (mpq-non-positive-p (mpq -1 2)))
  (should      (mpq-non-positive-p (mpq  0 2)))
  (should (not (mpq-non-positive-p (mpq +1 2)))))

(ert-deftest mpq-non-negative-p ()
  "Return true if OP is non-negative; otherwise return false."
  (should (not (mpq-non-negative-p (mpq -1 2))))
  (should      (mpq-non-negative-p (mpq  0 2)))
  (should      (mpq-non-negative-p (mpq +1 2))))

;;; --------------------------------------------------------------------

(ert-deftest mpq< ()
  "Compare operands."
  (should      (mpq< (mpq 1 2) (mpq 2 2)))
  (should (not (mpq< (mpq 1 2) (mpq 1 2))))
  (should (not (mpq< (mpq 2 2) (mpq 1 2)))))

(ert-deftest mpq> ()
  "Compare operands."
  (should (not (mpq> (mpq 1 2) (mpq 2 2))))
  (should (not (mpq> (mpq 1 2) (mpq 1 2))))
  (should      (mpq> (mpq 2 2) (mpq 1 2))))

(ert-deftest mpq<= ()
  "Compare operands."
  (should      (mpq<= (mpq 1 2) (mpq 2 2)))
  (should      (mpq<= (mpq 1 2) (mpq 1 2)))
  (should (not (mpq<= (mpq 2 2) (mpq 1 2)))))

(ert-deftest mpq>= ()
  "Compare operands."
  (should (not (mpq>= (mpq 1 2) (mpq 2 2))))
  (should      (mpq>= (mpq 1 2) (mpq 1 2)))
  (should      (mpq>= (mpq 2 2) (mpq 1 2))))

(ert-deftest mpq= ()
  "Compare operands."
  (should (not (mpq= (mpq 1 2) (mpq 2 2))))
  (should      (mpq= (mpq 1 2) (mpq 1 2)))
  (should (not (mpq= (mpq 2 2) (mpq 1 2)))))


;;;; done

(garbage-collect)
(ert-run-tests-batch-and-exit)

;;; test.el ends here
