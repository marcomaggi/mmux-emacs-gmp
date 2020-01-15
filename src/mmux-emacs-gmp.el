;;; mmux-emacs-gmp.el --- gmp module

;; Copyright (C) 2020 Marco Maggi

;; Author: Marco Maggi <mrc.mgg@gmail.com>
;; Created: Jan 15, 2020
;; Time-stamp: <2020-01-15 16:23:47 marco>
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
(eval-when-compile
  (load "libmmux-emacs-gmp"))
(load "libmmux-emacs-gmp")


;;;; error definitions

(define-error 'mmux-gmp-error
  "Error while executing a MMUX Emacs GMP operation."
  'error)

(define-error 'mmux-gmp-no-memory-error
  "Error allocating memory."
  'mmux-gmp-error)


;;;; user-ptr object wrappers

(cl-defstruct (mmux-gmp-mpz (:constructor make-mmux-gmp-mpz*))
  obj)

(defun make-mmux-gmp-mpz ()
  "Build and return a new, uninitialised, mmux-gmp-mpz object."
  (make-mmux-gmp-mpz* :obj (mmux-gmp-c-mpz-make)))

;;; --------------------------------------------------------------------

(cl-defstruct (mmux-gmp-mpq (:constructor make-mmux-gmp-mpq*))
  obj)

(defun make-mmux-gmp-mpq ()
  "Build and return a new, uninitialised, mmux-gmp-mpq object."
  (make-mmux-gmp-mpq* :obj (mmux-gmp-c-mpq-make)))

;;; --------------------------------------------------------------------

(cl-defstruct (mmux-gmp-mpf (:constructor make-mmux-gmp-mpf*))
  obj)

(defun make-mmux-gmp-mpf ()
  "Build and return a new, uninitialised, mmux-gmp-mpf object."
  (make-mmux-gmp-mpf* :obj (mmux-gmp-c-mpf-make)))


;;;; integer functions: assignment

(defun mpz-set (rop op)
  "Assign the value of an mmux-gmp-mpz object to another mmux-gmp-mpz object."
  (cl-assert (mmux-gmp-mpz-p rop))
  (cl-assert (mmux-gmp-mpz-p op))
  (mmux-gmp-c-mpz-set (mmux-gmp-mpz-obj rop) (mmux-gmp-mpz-obj op)))

(defun mpz-set-si (rop op)
  "Assign the value of an exact integer_t object to an mmux-gmp-mpz object."
  (cl-assert (mmux-gmp-mpz-p rop))
  (cl-assert (integerp op))
  (mmux-gmp-c-mpz-set-si (mmux-gmp-mpz-obj rop) op))

(defun mpz-set-d (rop op)
  "Assign the value of a floating point object to an mmux-gmp-mpz object."
  (cl-assert (mmux-gmp-mpz-p rop))
  (cl-assert (floatp op))
  (mmux-gmp-c-mpz-set-d (mmux-gmp-mpz-obj rop) op))

(defun mpz-set-q (rop op)
  "Assign the value of an mmux-gmp-mpq object to another mmux-gmp-mpz object."
  (cl-assert (mmux-gmp-mpz-p rop))
  (cl-assert (mmux-gmp-mpq-p op))
  (mmux-gmp-c-mpz-set-q (mmux-gmp-mpz-obj rop) op))

(defun mpz-set-f (rop op)
  "Assign the value of an mmux-gmp-mpf object to another mmux-gmp-mpz object."
  (cl-assert (mmux-gmp-mpz-p rop))
  (cl-assert (mmux-gmp-mpf-p op))
  (mmux-gmp-c-mpz-set-f (mmux-gmp-mpz-obj rop) op))

(defun mpz-set-str (rop str base)
  "Assign the value of a string object to another mmux-gmp-mpz object."
  (cl-assert (mmux-gmp-mpz-p rop))
  (cl-assert (stringp str))
  (cl-assert (and (integerp base)
		  (or (= 0 base)
		      (<= 2 base 36))))
  (mmux-gmp-c-mpz-set-str (mmux-gmp-mpz-obj rop) str base))

(defun mpz-swap (op1 op2)
  "Swap the values of two mmux-gmp-mpz objects."
  (cl-assert (mmux-gmp-mpz-p op1))
  (cl-assert (mmux-gmp-mpz-p op2))
  (mmux-gmp-c-mpz-swap (mmux-gmp-mpz-obj op1) (mmux-gmp-mpz-obj op2)))


;;;; integer functions: arithmetic

(defun mmux-gmp-mpz-add (rop op1 op2)
  "Add two mmux-gmp-mpz objects."
  (cl-assert (mmux-gmp-mpz-p rop))
  (cl-assert (mmux-gmp-mpz-p op1))
  (cl-assert (mmux-gmp-mpz-p op2))
  (mmux-gmp-c-mpz-add (mmux-gmp-mpz-obj rop) (mmux-gmp-mpz-obj op1) (mmux-gmp-mpz-obj op2)))


;;;; integer functions: conversion

(defun %base-p (N)
  (and (integerp N)
       (or (<= +2 N +36)
	   (>= -2 N -36))))

(defun mpz-get-str (base op)
  "Convert an object of type mmux-gmp-mpz to a string."
  (cl-assert (%base-p base))
  (cl-assert (mmux-gmp-mpz-p op))
  (mmux-gmp-c-mpz-get-str base (mmux-gmp-mpz-obj op)))


;;;; done

(provide 'mmux-emacs-gmp)

;;; mmux-emacs-gmp.el ends here
