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

(ert-deftest mpz-get-str ()
  "Conversion to string."
  (let ((op (mpz)))
    (mpz-set-si op 15)
    (should (equal "15" (mpz-get-str 10 op)))
    (should (equal "f"  (mpz-get-str 16 op)))
    (should (equal "F"  (mpz-get-str -16 op)))))


;;;; done

(garbage-collect)
(ert-run-tests-batch-and-exit)

;;; test.el ends here
