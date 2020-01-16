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
(require 'mmux-emacs-gmp)


;;;; assignment functions

(ert-deftest mpz-set ()
  "Assign an `mmux-gmp-mpz' object to an `mmux-gmp-mpz' object."
  (let ((rop (make-mmux-gmp-mpz))
	(op  (make-mmux-gmp-mpz)))
    (mpz-set-si rop 123)
    (mpz-set    op rop)
    (should (equal "123" (mpz-get-str 10 op)))))

(ert-deftest mpz-set-si ()
  "Assign an exact integer to an `mmux-gmp-mpz' object."
  (let ((rop (make-mmux-gmp-mpz)))
    (mpz-set-si rop 123)
    (should (equal "123" (mpz-get-str 10 rop)))))

(ert-deftest mpz-set-d ()
  "Assign a floating point to an `mmux-gmp-mpz' object."
  (let ((rop (make-mmux-gmp-mpz)))
    (mpz-set-d rop 12.3)
    (should (equal "12" (mpz-get-str 10 rop)))))

(ert-deftest mpz-set-str ()
  "Assign a string value to an `mmux-gmp-mpz' object."
  (let ((rop (make-mmux-gmp-mpz)))
    (mpz-set-str rop "123" 10)
    (should (equal "123" (mpz-get-str 10 rop)))))

(ert-deftest mpz-swap ()
  "Swap values between `mmux-gmp-mpz' objects."
  (let ((op1 (make-mmux-gmp-mpz))
	(op2 (make-mmux-gmp-mpz)))
    (mpz-set-si op1 123)
    (mpz-set-si op2 456)
    (mpz-swap op1 op2)
    (should (equal "123" (mpz-get-str 10 op2)))
    (should (equal "456" (mpz-get-str 10 op1)))))

(ert-deftest mpz-swap-1 ()
  "Swap values between `mmux-gmp-mpz' objects."
  (defconst op1 (make-mmux-gmp-mpz))
  (defconst op2 (make-mmux-gmp-mpz))
  (mpz-set-si op1 123)
  (mpz-set-si op2 456)
  (mpz-swap op1 op2)
  (should (equal "123" (mpz-get-str 10 op2)))
  (should (equal "456" (mpz-get-str 10 op1))))


;;;; conversion functions

(ert-deftest mpz-get-str ()
  "Conversion to string."
  (let ((op (make-mmux-gmp-mpz)))
    (mpz-set-si op 15)
    (should (equal "15" (mpz-get-str 10 op)))
    (should (equal "f"  (mpz-get-str 16 op)))
    (should (equal "F"  (mpz-get-str -16 op)))))


;;;; done

(ert-run-tests-batch-and-exit)

;;; test.el ends here
