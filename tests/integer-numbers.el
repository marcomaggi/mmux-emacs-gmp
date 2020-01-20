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
		   (mpz-get-ui rop)))))

(ert-deftest mpz-add-ui ()
  "Add an `mpz' object to an unsigned integer."
  (should (equal 11
		 (let ((rop	(mpz))
		       (op1	(mpz 10))
		       (op2	1))
		   (mpz-add-ui rop op1 op2)
		   (mpz-get-ui rop)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-sub ()
  "Subtract an `mpz' objects from an `mpz' object."
  (should (equal 10
		 (let ((rop	(mpz))
		       (op1	(mpz 11))
		       (op2	(mpz 1)))
		   (mpz-sub rop op1 op2)
		   (mpz-get-ui rop)))))

(ert-deftest mpz-sub-ui ()
  "Subtract an unsigned integer from an `mpz' object."
  (should (equal 10
		 (let ((rop	(mpz))
		       (op1	(mpz 11))
		       (op2	1))
		   (mpz-sub-ui rop op1 op2)
		   (mpz-get-ui rop)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-addmul ()
  "Multiply two `mpz' objects, then add the result to another `mpz' object."
  (should (equal (+ 100 (* 11 2))
		 (let ((rop	(mpz 100))
		       (op1	(mpz 11))
		       (op2	(mpz 2)))
		   (mpz-addmul rop op1 op2)
		   (mpz-get-ui rop)))))

(ert-deftest mpz-addmul-ui ()
  "Multiply an `mpz' object by an unsigned integer, then add the result to an `mpz' object."
  (should (equal (+ 100 (* 11 2))
		 (let ((rop	(mpz 100))
		       (op1	(mpz 11))
		       (op2	2))
		   (mpz-addmul-ui rop op1 op2)
		   (mpz-get-ui rop)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-submul ()
  "Multiply two `mpz' objects, then subtract the result from another `mpz' object."
  (should (equal (- 100 (* 11 2))
		 (let ((rop	(mpz 100))
		       (op1	(mpz 11))
		       (op2	(mpz 2)))
		   (mpz-submul rop op1 op2)
		   (mpz-get-ui rop)))))

(ert-deftest mpz-submul-ui ()
  "Multiply an `mpz' object by an unsigned integer, then subtract the result from an `mpz' object."
  (should (equal (- 100 (* 11 2))
		 (let ((rop	(mpz 100))
		       (op1	(mpz 11))
		       (op2	2))
		   (mpz-submul-ui rop op1 op2)
		   (mpz-get-ui rop)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-mul ()
  "Multiply two `mpz' objects."
  (should (equal 222
		 (let ((rop	(mpz))
		       (op1	(mpz 111))
		       (op2	(mpz 2)))
		   (mpz-mul rop op1 op2)
		   (mpz-get-ui rop)))))

(ert-deftest mpz-mul-si ()
  "Multiply an `mpz' object by a signed exact integer number."
  (should (equal 222
		 (let ((rop	(mpz))
		       (op1	(mpz 111))
		       (op2	2))
		   (mpz-mul-si rop op1 op2)
		   (mpz-get-ui rop)))))

(ert-deftest mpz-mul-ui ()
  "Multiply an `mpz' object by an unsigned exact integer number."
  (should (equal 222
		 (let ((rop	(mpz))
		       (op1	(mpz 111))
		       (op2	2))
		   (mpz-mul-ui rop op1 op2)
		   (mpz-get-ui rop)))))

;;; --------------------------------------------------------------------

(ert-deftest mpz-mul-2exp ()
  "Left shift an `mpz' object."
  (should (equal #b1010100
		 (let ((rop	(mpz))
		       (op	(mpz #b10101))
		       (bitcnt	2))
		   (mpz-mul-2exp rop op bitcnt)
		   (mpz-get-ui rop)))))

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
		   (mpz-get-ui rop)))))


;;;; integer division functions: ceil rounding

(ert-deftest mpz-cdiv-q ()
  ""
  (check
      (let ((Q	(mpz))
	    (N	(mpz 10))
	    (D	(mpz 3)))
	(mpz-cdiv-q Q N D)
	(mpz-get-ui Q))
    => 4))

@defun mpz-cdiv-q Q N D


@defun mpz-cdiv-r R N D


@defun mpz-cdiv-qr Q R N D


@defun mpz-cdiv-q-ui Q N D


@defun mpz-cdiv-r-ui R N D


@defun mpz-cdiv-qr-ui Q R N D


@defun mpz-cdiv-ui N D


@defun mpz-cdiv-q-2exp Q N B


@defun mpz-cdiv-2-2exp R N B


;;;; integer division functions: floor rounding



;;;; integer division functions: truncate rounding



;;;; integer division functions: modulo functions



;;;; integer division functions: exact division



;;;; done

(garbage-collect)
(ert-run-tests-batch-and-exit)

;;; test.el ends here
