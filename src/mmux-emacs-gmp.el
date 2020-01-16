;;; mmux-emacs-gmp.el --- gmp module

;; Copyright (C) 2020 Marco Maggi

;; Author: Marco Maggi <mrc.mgg@gmail.com>
;; Created: Jan 15, 2020
;; Time-stamp: <2020-01-16 11:54:07 marco>
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

(define-error 'mmux-gmp-string-too-long
  "String exceeds maximum length."
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
  "Build and return a new, uninitialised, `mmux-gmp-mpq' object."
  (make-mmux-gmp-mpq* :obj (mmux-gmp-c-mpq-make)))

;;; --------------------------------------------------------------------

(cl-defstruct (mmux-gmp-mpf (:constructor make-mmux-gmp-mpf*))
  obj)

(defun make-mmux-gmp-mpf ()
  "Build and return a new, uninitialised, mmux-gmp-mpf object."
  (make-mmux-gmp-mpf* :obj (mmux-gmp-c-mpf-make)))


;;;; integer number functions: assignment

(defun mpz-set (rop op)
  "Assign the value of an `mmux-gmp-mpz' object to another `mmux-gmp-mpz' object."
  (cl-assert (mmux-gmp-mpz-p rop))
  (cl-assert (mmux-gmp-mpz-p op))
  (mmux-gmp-c-mpz-set (mmux-gmp-mpz-obj rop) (mmux-gmp-mpz-obj op)))

(defun mpz-set-si (rop op)
  "Assign the value of an exact integer object to an `mmux-gmp-mpz' object."
  (cl-assert (mmux-gmp-mpz-p rop))
  (cl-assert (integerp op))
  (mmux-gmp-c-mpz-set-si (mmux-gmp-mpz-obj rop) op))

(defun mpz-set-ui (rop op)
  "Assign the value of an exact integer object to an `mmux-gmp-mpz' object."
  (cl-assert (mmux-gmp-mpz-p rop))
  (cl-assert (and (integerp op)
		  (<= 0 op)))
  (mmux-gmp-c-mpz-set-ui (mmux-gmp-mpz-obj rop) op))

(defun mpz-set-d (rop op)
  "Assign the value of a floating-point object to an `mmux-gmp-mpz' object."
  (cl-assert (mmux-gmp-mpz-p rop))
  (cl-assert (floatp op))
  (mmux-gmp-c-mpz-set-d (mmux-gmp-mpz-obj rop) op))

(defun mpz-set-q (rop op)
  "Assign the value of an `mmux-gmp-mpq' object to an `mmux-gmp-mpz' object."
  (cl-assert (mmux-gmp-mpz-p rop))
  (cl-assert (mmux-gmp-mpq-p op))
  (mmux-gmp-c-mpz-set-q (mmux-gmp-mpz-obj rop) (mmux-gmp-mpq-obj op)))

(defun mpz-set-f (rop op)
  "Assign the value of an `mmux-gmp-mpf' object to an `mmux-gmp-mpz' object."
  (cl-assert (mmux-gmp-mpz-p rop))
  (cl-assert (mmux-gmp-mpf-p op))
  (mmux-gmp-c-mpz-set-f (mmux-gmp-mpz-obj rop) (mmux-gmp-mpf-obj op)))

(defun mpz-set-str (rop str base)
  "Assign the value of a string object to an `mmux-gmp-mpz' object."
  (cl-assert (mmux-gmp-mpz-p rop))
  (cl-assert (stringp str))
  (cl-assert (and (integerp base)
		  (or (zerop base)
		      (<= 2 base 36))))
  (mmux-gmp-c-mpz-set-str (mmux-gmp-mpz-obj rop) str base))

(defun mpz-swap (op1 op2)
  "Swap the values of two `mmux-gmp-mpz' objects."
  (cl-assert (mmux-gmp-mpz-p op1))
  (cl-assert (mmux-gmp-mpz-p op2))
  (mmux-gmp-c-mpz-swap (mmux-gmp-mpz-obj op1) (mmux-gmp-mpz-obj op2)))


;;;; integer number functions: arithmetic

(defun mpz-add (rop op1 op2)
  "Add two `mmux-gmp-mpz' objects."
  (cl-assert (mmux-gmp-mpz-p rop))
  (cl-assert (mmux-gmp-mpz-p op1))
  (cl-assert (mmux-gmp-mpz-p op2))
  (mmux-gmp-c-mpz-add (mmux-gmp-mpz-obj rop) (mmux-gmp-mpz-obj op1) (mmux-gmp-mpz-obj op2)))


;;;; integer number functions: conversion

(defun mpz-get-str (base op)
  "Convert an object of type `mmux-gmp-mpz' to a string."
  (cl-assert (and (integerp base)
		  (or (<= +2 base +36)
		      (>= -2 base -36))))
  (cl-assert (mmux-gmp-mpz-p op))
  (mmux-gmp-c-mpz-get-str base (mmux-gmp-mpz-obj op)))


;;;; rational number functions: assignment

(defun mpq-set (rop op)
  "Assign the value of an `mmux-gmp-mpq' object to another `mmux-gmp-mpq' object."
  (cl-assert (mmux-gmp-mpq-p rop))
  (cl-assert (mmux-gmp-mpq-p op))
  (mmux-gmp-c-mpq-set (mmux-gmp-mpq-obj rop) (mmux-gmp-mpq-obj op)))

(defun mpq-set-si (rop op1 op2)
  "Assign the values of two exact signed integer objects to an `mmux-gmp-mpq' object."
  (cl-assert (mmux-gmp-mpq-p rop))
  (cl-assert (integerp op1))
  (cl-assert (and (integerp op2)
		  (not (zerop op2))))
  (mmux-gmp-c-mpq-set-si (mmux-gmp-mpq-obj rop) op1 op2))

(defun mpq-set-ui (rop op1 op2)
  "Assign the values of two exact unsigned integer objects to an `mmux-gmp-mpq' object."
  (cl-assert (mmux-gmp-mpq-p rop))
  (cl-assert (and (integerp op1)
		  (<= 0 op1)))
  (cl-assert (and (integerp op2)
		  (<  0 op2)))
  (mmux-gmp-c-mpq-set-ui (mmux-gmp-mpq-obj rop) op1 op2))

(defun mpq-set-d (rop op)
  "Assign the value of a floating-point object to an `mmux-gmp-mpq' object."
  (cl-assert (mmux-gmp-mpq-p rop))
  (cl-assert (floatp op))
  (mmux-gmp-c-mpq-set-d (mmux-gmp-mpq-obj rop) op))

(defun mpq-set-z (rop op)
  "Assign the value of an `mmux-gmp-mpz' object to an `mmux-gmp-mpq' object."
  (cl-assert (mmux-gmp-mpq-p rop))
  (cl-assert (mmux-gmp-mpq-p op))
  (mmux-gmp-c-mpq-set-z (mmux-gmp-mpq-obj rop) op))

(defun mpq-set-f (rop op)
  "Assign the value of an `mmux-gmp-mpf' object to an `mmux-gmp-mpq' object."
  (cl-assert (mmux-gmp-mpq-p rop))
  (cl-assert (mmux-gmp-mpf-p op))
  (mmux-gmp-c-mpq-set-f (mmux-gmp-mpq-obj rop) op))

(defun mpq-set-str (rop str base)
  "Assign the value of a string object to an `mmux-gmp-mpq' object."
  (cl-assert (mmux-gmp-mpq-p rop))
  (cl-assert (stringp str))
  (cl-assert (and (integerp base)
		  (or (zerop base)
		      (<= 2 base 36))))
  (mmux-gmp-c-mpq-set-str (mmux-gmp-mpq-obj rop) str base))

(defun mpq-swap (op1 op2)
  "Swap the values of two `mmux-gmp-mpq' objects."
  (cl-assert (mmux-gmp-mpq-p op1))
  (cl-assert (mmux-gmp-mpq-p op2))
  (mmux-gmp-c-mpq-swap (mmux-gmp-mpq-obj op1) (mmux-gmp-mpq-obj op2)))


;;;; rational number functions: arithmetic

(defun mpq-add (rop op1 op2)
  "Add two `mmux-gmp-mpq' objects."
  (cl-assert (mmux-gmp-mpq-p rop))
  (cl-assert (mmux-gmp-mpq-p op1))
  (cl-assert (mmux-gmp-mpq-p op2))
  (mmux-gmp-c-mpq-add (mmux-gmp-mpq-obj rop) (mmux-gmp-mpq-obj op1) (mmux-gmp-mpq-obj op2)))


;;;; rational number functions: conversion

(defun mpq-get-str (base op)
  "Convert an object of type `mmux-gmp-mpq' to a string."
  (cl-assert (and (integerp base)
		  (or (<= +2 base +36)
		      (>= -2 base -36))))
  (cl-assert (mmux-gmp-mpq-p op))
  (mmux-gmp-c-mpq-get-str base (mmux-gmp-mpq-obj op)))


;;;; floating-point number functions: assignment

(defun mpf-set (rop op)
  "Assign the value of an `mmux-gmp-mpf' object to another `mmux-gmp-mpf' object."
  (cl-assert (mmux-gmp-mpf-p rop))
  (cl-assert (mmux-gmp-mpf-p op))
  (mmux-gmp-c-mpf-set (mmux-gmp-mpf-obj rop) (mmux-gmp-mpf-obj op)))

(defun mpf-set-si (rop op)
  "Assign the value of an exact integer object to an `mmux-gmp-mpf' object."
  (cl-assert (mmux-gmp-mpf-p rop))
  (cl-assert (integerp op))
  (mmux-gmp-c-mpf-set-si (mmux-gmp-mpf-obj rop) op))

(defun mpf-set-ui (rop op)
  "Assign the value of an exact integer object to an `mmux-gmp-mpf' object."
  (cl-assert (mmux-gmp-mpf-p rop))
  (cl-assert (and (integerp op)
		  (<= 0 op)))
  (mmux-gmp-c-mpf-set-ui (mmux-gmp-mpf-obj rop) op))

(defun mpf-set-d (rop op)
  "Assign the value of a floating-point object to an `mmux-gmp-mpf' object."
  (cl-assert (mmux-gmp-mpf-p rop))
  (cl-assert (floatp op))
  (mmux-gmp-c-mpf-set-d (mmux-gmp-mpf-obj rop) op))

(defun mpf-set-z (rop op)
  "Assign the value of an `mmux-gmp-mpz' object to an `mmux-gmp-mpf' object."
  (cl-assert (mmux-gmp-mpf-p rop))
  (cl-assert (mmux-gmp-mpz-p op))
  (mmux-gmp-c-mpf-set-q (mmux-gmp-mpf-obj rop) (mmux-gmp-mpz-obj op)))

(defun mpf-set-q (rop op)
  "Assign the value of an `mmux-gmp-mpq' object to an `mmux-gmp-mpf' object."
  (cl-assert (mmux-gmp-mpf-p rop))
  (cl-assert (mmux-gmp-mpq-p op))
  (mmux-gmp-c-mpf-set-q (mmux-gmp-mpf-obj rop) (mmux-gmp-mpq-obj op)))

(defun mpf-set-str (rop str base)
  "Assign the value of a string object to an `mmux-gmp-mpf' object."
  (cl-assert (mmux-gmp-mpf-p rop))
  (cl-assert (stringp str))
  (cl-assert (and (integerp base)
		  (or (<= +2 base +62)
		      (>= -2 base -62))))
  (mmux-gmp-c-mpf-set-str (mmux-gmp-mpf-obj rop) str base))

(defun mpf-swap (op1 op2)
  "Swap the values of two `mmux-gmp-mpf' objects."
  (cl-assert (mmux-gmp-mpf-p op1))
  (cl-assert (mmux-gmp-mpf-p op2))
  (mmux-gmp-c-mpf-swap (mmux-gmp-mpf-obj op1) (mmux-gmp-mpf-obj op2)))


;;;; floating-point number functions: arithmetic

(defun mpf-add (rop op1 op2)
  "Add two `mmux-gmp-mpf' objects."
  (cl-assert (mmux-gmp-mpf-p rop))
  (cl-assert (mmux-gmp-mpf-p op1))
  (cl-assert (mmux-gmp-mpf-p op2))
  (mmux-gmp-c-mpf-add (mmux-gmp-mpf-obj rop) (mmux-gmp-mpf-obj op1) (mmux-gmp-mpf-obj op2)))


;;;; floating-point number functions: conversion

(defun mpf-get-str (base ndigits op)
  "Convert an object of type `mmux-gmp-mpf' to a string."
  (cl-assert (and (integerp base)
		  (or (<= +2 base +62)
		      (>= -2 base -36))))
  (cl-assert (and (integerp ndigits)
		  (<= 0 ndigits)))
  (cl-assert (mmux-gmp-mpf-p op))
  (mmux-gmp-c-mpf-get-str base ndigits (mmux-gmp-mpf-obj op)))

(defun mpf-get-str* (base ndigits op)
  "Convert an object of type `mmux-gmp-mpf' to a formatted string."
  (let* ((rv		(mpf-get-str base ndigits op))
	 (mantissa.str	(car rv))
	 (exponent	(cdr rv))
	 (negative?	(string= "-" (substring mantissa.str 0 1))))
    (format "%s0.%se%s%d"
	    (if negative? "-" "+")
	    (if negative? (substring mantissa.str 1) mantissa.str)
	    (cond ((< 0 exponent)	"+")
		  ((> 0 exponent)	"-")
		  (t			""))
	    (abs exponent))))


;;;; done

(provide 'mmux-emacs-gmp)

;;; mmux-emacs-gmp.el ends here
