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

(ert-deftest mpf-set ()
  "Assign an `mmux-gmp-mpf' object to an `mmux-gmp-mpf' object."
  (defconst rop (make-mmux-gmp-mpf))
  (defconst op  (make-mmux-gmp-mpf))
  (mpf-set-si rop 123)
  (mpf-set    op rop)
  (should (equal "+0.123e+3" (mpf-get-str* 10 8 op))))

(ert-deftest mpf-set-si ()
  "Assign a signed exact integer to an `mmux-gmp-mpf' object."
  (defconst rop (make-mmux-gmp-mpf))
  (mpf-set-si rop 123)
  (should (equal "+0.123e+3" (mpf-get-str* 10 8 rop))))

(ert-deftest mpf-set-ui ()
  "Assign an unsigned exact integer to an `mmux-gmp-mpf' object."
  (defconst rop (make-mmux-gmp-mpf))
  (mpf-set-ui rop 123)
  (should (equal "+0.123e+3" (mpf-get-str* 10 8 op))))

(ert-deftest mpf-set-d ()
  "Assign a floating point to an `mmux-gmp-mpf' object."
  (should (equal "+0.123e+2" (let ((rop (make-mmux-gmp-mpf)))
			       (mpf-set-d rop 12.3)
			       (mpf-get-str* 10 8 rop)))))

(ert-deftest mpf-set-str ()
  "Assign a string value to an `mmux-gmp-mpf' object."
  (let ((rop (make-mmux-gmp-mpf)))
    (mpf-set-str rop "123" 10)
    (should (equal "+0.123e+3" (mpf-get-str* 10 8 rop)))))

(ert-deftest mpf-swap ()
  "Swap values between `mmux-gmp-mpf' objects."
  (let ((op1 (make-mmux-gmp-mpf))
	(op2 (make-mmux-gmp-mpf)))
    (mpf-set-si op1 123)
    (mpf-set-si op2 456)
    (mpf-swap op1 op2)
    (should (equal "+0.123e+3" (mpf-get-str* 10 8 op2)))
    (should (equal "+0.456e+3" (mpf-get-str* 10 8 op1)))))


;;;; conversion functions

(ert-deftest mpf-get-str ()
  "Conversion to string."
  (defconst op (make-mmux-gmp-mpf))
  (defconst ndigits 5)
  (mpf-set-si op 15)
  (should (equal '("15" . 2) (mpf-get-str +10 ndigits op)))
  (should (equal '("f"  . 1) (mpf-get-str +16 ndigits op)))
  (should (equal '("F"  . 1) (mpf-get-str -16 ndigits op))))

(ert-deftest mpf-get-str-1 ()
  "Conversion to string: floating-point object as source."
  (defconst op (make-mmux-gmp-mpf))
  (defconst ndigits 5)
  (mpf-set-d op 12.34)
  (should (equal '("1234" . 2) (mpf-get-str +10 ndigits op))))

(ert-deftest mpf-get-str-2 ()
  "Conversion to string: negative floating-point object as source."
  (defconst op (make-mmux-gmp-mpf))
  (defconst ndigits 5)
  (mpf-set-d op -12.34)
  (should (equal '("-1234" . 2) (mpf-get-str +10 ndigits op))))

(ert-deftest mpf-get-str-3 ()
  "Conversion to string: negative floating-point object as source, less than zero."
  (defconst op (make-mmux-gmp-mpf))
  (defconst ndigits 5)
  (mpf-set-d op -0.1234)
  (should (equal '("-1234" . 0) (mpf-get-str +10 ndigits op))))

(ert-deftest mpf-get-str-4 ()
  "Conversion to string: negative floating-point object as source, less than zero."
  (defconst op (make-mmux-gmp-mpf))
  (defconst ndigits 5)
  (mpf-set-d op -0.001234)
  (should (equal '("-1234" . -2) (mpf-get-str +10 ndigits op))))

;;; --------------------------------------------------------------------

(ert-deftest mpf-get-str*-1 ()
  "Conversion to formatted string: positive double as source."
  (let ((op (make-mmux-gmp-mpf))
	(ndigits 5))
    (mpf-set-d op +0.001234)
    (should (equal "+0.1234e-2" (mpf-get-str* +10 ndigits op))))
  (let ((op (make-mmux-gmp-mpf))
	(ndigits 5))
    (mpf-set-d op +12.34)
    (should (equal "+0.1234e+2" (mpf-get-str* +10 ndigits op)))))

(ert-deftest mpf-get-str*-2 ()
  "Conversion to formatted string: negative double as source."
  (let ((op (make-mmux-gmp-mpf))
	(ndigits 5))
    (mpf-set-d op -0.001234)
    (should (equal "-0.1234e-2" (mpf-get-str* +10 ndigits op))))
  (let ((op (make-mmux-gmp-mpf))
	(ndigits 5))
    (mpf-set-d op -12.34)
    (should (equal "-0.1234e+2" (mpf-get-str* +10 ndigits op)))))


;;;; done

(ert-run-tests-batch-and-exit)

;;; test.el ends here
