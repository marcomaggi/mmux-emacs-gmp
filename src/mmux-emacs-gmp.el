;;; mmux-emacs-gmp.el --- gmp module

;; Copyright (C) 2020 Marco Maggi

;; Author: Marco Maggi <mrc.mgg@gmail.com>
;; Created: Jan 15, 2020
;; Time-stamp: <2020-01-15 11:12:36 marco>
;; Keywords: extensions

;; This file is part of MMUX Emacs GMP.
;;
;; This program is  free software: you can redistribute  it and/or modify it under the  terms of the
;; GNU General Public License as published by the  Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
;; even the implied  warranty of MERCHANTABILITY or  FITNESS FOR A PARTICULAR PURPOSE.   See the GNU
;; General Public License for more details.
;;
;; You should have  received a copy of the  GNU General Public License along with  this program.  If
;; not, see <http://www.gnu.org/licenses/>.
;;

;;; Commentary:

;;

;;; Change Log:

;;

;;; Code:

(require 'cl-lib)
(load "libmmux-emacs-gmp")

(define-error 'mmux-gmp-error
  "Error while executing a MMUX Emacs GMP operation."
  'error)

(define-error 'mmux-gmp-no-memory-error
  "Error allocating memory."
  'mmux-gmp-error)

(cl-defstruct mmux-gmp-cplx
  obj)

(defun mmux-gmp-make-cplx (X Y)
  "Build and return a new cplx object."
  (make-mmux-gmp-cplx :obj (mmux-gmp-cplx-cmake X Y)))

(defun mmux-gmp-get-X (obj)
  "Return the X component of an object of type `mmux-gmp-cplx'."
  (cl-assert (mmux-gmp-cplx-p obj))
  (mmux-gmp-cplx-cget-X (mmux-gmp-cplx-obj obj)))

(defun mmux-gmp-get-Y (obj)
  "Return the Y component of an object of type `mmux-gmp-cplx'."
  (cl-assert (mmux-gmp-cplx-p obj))
  (mmux-gmp-cplx-cget-Y (mmux-gmp-cplx-obj obj)))

(provide 'mmux-emacs-gmp)

;;; mmux-emacs-gmp.el ends here
