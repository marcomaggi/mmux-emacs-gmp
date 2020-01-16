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


;;;; assignment functions

(ert-deftest mpq-set ()
  "Assign an `mmux-gmp-mpq' object to an `mmux-gmp-mpq' object."
  (defconst rop (make-mmux-gmp-mpq))
  (defconst op  (make-mmux-gmp-mpq))
  (mpq-set-si rop 3 4)
  (mpq-set    op rop)
  (should (equal "3/4" (mpq-get-str 10 op))))

(ert-deftest mpq-set-si ()
  "Assign two signed exact integers to an `mmux-gmp-mpq' object."
  (defconst rop (make-mmux-gmp-mpq))
  (mpq-set-si rop 3 4)
  (should (equal "3/4" (mpq-get-str 10 rop))))

(ert-deftest mpq-set-si-1 ()
  "Assign two signed exact integers to an `mmux-gmp-mpq' object."
  (defconst rop (make-mmux-gmp-mpq))
  (mpq-set-si rop -3 4)
  (should (equal "-3/4" (mpq-get-str 10 rop))))

(ert-deftest mpq-set-ui ()
  "Assign two unsigned exact integers to an `mmux-gmp-mpq' object."
  (defconst rop (make-mmux-gmp-mpq))
  (mpq-set-ui rop 3 4)
  (should (equal "3/4" (mpq-get-str 10 rop))))

(ert-deftest mpq-set-d ()
  "Assign a floating-point to an `mmux-gmp-mpq' object."
  (defconst rop (make-mmux-gmp-mpq))
  (mpq-set-d rop 1.2)
  (should (equal "5404319552844595/4503599627370496" (mpq-get-str 10 rop))))

(ert-deftest mpq-set-str ()
  "Assign a string value to an `mmux-gmp-mpq' object."
  (defconst rop (make-mmux-gmp-mpq))
  (mpq-set-str rop "3/4" 10)
  (should (equal "3/4" (mpq-get-str 10 rop))))

(ert-deftest mpq-swap ()
  "Swap values between `mmux-gmp-mpq' objects."
  (defconst op1 (make-mmux-gmp-mpq))
  (defconst op2 (make-mmux-gmp-mpq))
  (mpq-set-si op1 3 4)
  (mpq-set-si op2 5 6)
  (mpq-swap op1 op2)
  (should (equal "3/4" (mpq-get-str 10 op2)))
  (should (equal "5/6" (mpq-get-str 10 op1))))


;;;; conversion functions

(ert-deftest mpq-get-str ()
  "Conversion to string."
  (defconst op (make-mmux-gmp-mpq))
  (mpq-set-si op 3 4)
  (should (equal "3/4" (mpq-get-str 10 op)))
  (should (equal "3/4" (mpq-get-str 16 op)))
  (should (equal "3/4" (mpq-get-str -16 op))))


;;;; done

(ert-run-tests-batch-and-exit)

;;; test.el ends here
