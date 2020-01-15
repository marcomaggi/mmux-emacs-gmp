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

(ert-deftest use-integer ()
  "Use an integer."
  (should (= +101 (mmux-gmp-use-integer +100)))
  (should (= -320 (mmux-gmp-use-integer -321))))

(ert-deftest use-float ()
  "Use a float."
  (should (= +101.0 (mmux-gmp-use-float +100.0)))
  (should (= -320.0 (mmux-gmp-use-float -321.0))))

(ert-deftest use-string ()
  "Use a string."
  (should (string= "" (mmux-gmp-use-string "")))
  (should (string= "ciao mamma" (mmux-gmp-use-string "ciao mamma"))))

(ert-run-tests-batch-and-exit)

;;; test.el ends here
