;;; mmux-emacs-gmp.el --- gmp module

;; Copyright (C) 2020 Marco Maggi

;; Author: Marco Maggi <mrc.mgg@gmail.com>
;; Created: Jan 15, 2020
;; Time-stamp: <2020-01-17 06:58:14 marco>
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

(cl-defstruct (mpz (:constructor make-mpz))
  obj)

(defun mpz ()
  "Build and return a new, uninitialised, mpz object."
  (make-mpz :obj (mmux-gmp-c-mpz-make)))

;;; --------------------------------------------------------------------

(cl-defstruct (mpq (:constructor make-mpq))
  obj)

(defun mpq ()
  "Build and return a new, uninitialised, `mpq' object."
  (make-mpq :obj (mmux-gmp-c-mpq-make)))

;;; --------------------------------------------------------------------

(cl-defstruct (mpf (:constructor make-mpf))
  obj)

(defun mpf ()
  "Build and return a new, uninitialised, mpf object."
  (make-mpf :obj (mmux-gmp-c-mpf-make)))


;;;; integer number functions: assignment

(defun mpz-set (rop op)
  "Assign the value of an `mpz' object to another `mpz' object."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p op))
  (mmux-gmp-c-mpz-set (mpz-obj rop) (mpz-obj op)))

(defun mpz-set-si (rop op)
  "Assign the value of an exact integer object to an `mpz' object."
  (cl-assert (mpz-p rop))
  (cl-assert (integerp op))
  (mmux-gmp-c-mpz-set-si (mpz-obj rop) op))

(defun mpz-set-ui (rop op)
  "Assign the value of an exact integer object to an `mpz' object."
  (cl-assert (mpz-p rop))
  (cl-assert (and (integerp op)
		  (<= 0 op)))
  (mmux-gmp-c-mpz-set-ui (mpz-obj rop) op))

(defun mpz-set-d (rop op)
  "Assign the value of a floating-point object to an `mpz' object."
  (cl-assert (mpz-p rop))
  (cl-assert (floatp op))
  (mmux-gmp-c-mpz-set-d (mpz-obj rop) op))

(defun mpz-set-q (rop op)
  "Assign the value of an `mpq' object to an `mpz' object."
  (cl-assert (mpz-p rop))
  (cl-assert (mpq-p op))
  (mmux-gmp-c-mpz-set-q (mpz-obj rop) (mpq-obj op)))

(defun mpz-set-f (rop op)
  "Assign the value of an `mpf' object to an `mpz' object."
  (cl-assert (mpz-p rop))
  (cl-assert (mpf-p op))
  (mmux-gmp-c-mpz-set-f (mpz-obj rop) (mpf-obj op)))

(defun mpz-set-str (rop str base)
  "Assign the value of a string object to an `mpz' object."
  (cl-assert (mpz-p rop))
  (cl-assert (stringp str))
  (cl-assert (and (integerp base)
		  (or (zerop base)
		      (<= 2 base 36))))
  (mmux-gmp-c-mpz-set-str (mpz-obj rop) str base))

(defun mpz-swap (op1 op2)
  "Swap the values of two `mpz' objects."
  (cl-assert (mpz-p op1))
  (cl-assert (mpz-p op2))
  (mmux-gmp-c-mpz-swap (mpz-obj op1) (mpz-obj op2)))


;;;; integer number functions: arithmetic

(defun mpz-add (rop op1 op2)
  "Add two `mpz' objects."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p op1))
  (cl-assert (mpz-p op2))
  (mmux-gmp-c-mpz-add (mpz-obj rop) (mpz-obj op1) (mpz-obj op2)))


;;;; integer number functions: conversion

(defun mpz-get-str (base op)
  "Convert an object of type `mpz' to a string."
  (cl-assert (and (integerp base)
		  (or (<= +2 base +36)
		      (>= -2 base -36))))
  (cl-assert (mpz-p op))
  (mmux-gmp-c-mpz-get-str base (mpz-obj op)))


;;;; rational number functions: assignment

(defun mpq-set (rop op)
  "Assign the value of an `mpq' object to another `mpq' object."
  (cl-assert (mpq-p rop))
  (cl-assert (mpq-p op))
  (mmux-gmp-c-mpq-set (mpq-obj rop) (mpq-obj op)))

(defun mpq-set-si (rop op1 op2)
  "Assign the values of two exact signed integer objects to an `mpq' object."
  (cl-assert (mpq-p rop))
  (cl-assert (integerp op1))
  (cl-assert (and (integerp op2)
		  (not (zerop op2))))
  (mmux-gmp-c-mpq-set-si (mpq-obj rop) op1 op2))

(defun mpq-set-ui (rop op1 op2)
  "Assign the values of two exact unsigned integer objects to an `mpq' object."
  (cl-assert (mpq-p rop))
  (cl-assert (and (integerp op1)
		  (<= 0 op1)))
  (cl-assert (and (integerp op2)
		  (<  0 op2)))
  (mmux-gmp-c-mpq-set-ui (mpq-obj rop) op1 op2))

(defun mpq-set-d (rop op)
  "Assign the value of a floating-point object to an `mpq' object."
  (cl-assert (mpq-p rop))
  (cl-assert (floatp op))
  (mmux-gmp-c-mpq-set-d (mpq-obj rop) op))

(defun mpq-set-z (rop op)
  "Assign the value of an `mpz' object to an `mpq' object."
  (cl-assert (mpq-p rop))
  (cl-assert (mpq-p op))
  (mmux-gmp-c-mpq-set-z (mpq-obj rop) op))

(defun mpq-set-f (rop op)
  "Assign the value of an `mpf' object to an `mpq' object."
  (cl-assert (mpq-p rop))
  (cl-assert (mpf-p op))
  (mmux-gmp-c-mpq-set-f (mpq-obj rop) op))

(defun mpq-set-str (rop str base)
  "Assign the value of a string object to an `mpq' object."
  (cl-assert (mpq-p rop))
  (cl-assert (stringp str))
  (cl-assert (and (integerp base)
		  (or (zerop base)
		      (<= 2 base 36))))
  (mmux-gmp-c-mpq-set-str (mpq-obj rop) str base))

(defun mpq-swap (op1 op2)
  "Swap the values of two `mpq' objects."
  (cl-assert (mpq-p op1))
  (cl-assert (mpq-p op2))
  (mmux-gmp-c-mpq-swap (mpq-obj op1) (mpq-obj op2)))


;;;; rational number functions: arithmetic

(defun mpq-add (rop op1 op2)
  "Add two `mpq' objects."
  (cl-assert (mpq-p rop))
  (cl-assert (mpq-p op1))
  (cl-assert (mpq-p op2))
  (mmux-gmp-c-mpq-add (mpq-obj rop) (mpq-obj op1) (mpq-obj op2)))


;;;; rational number functions: conversion

(defun mpq-get-str (base op)
  "Convert an object of type `mpq' to a string."
  (cl-assert (and (integerp base)
		  (or (<= +2 base +36)
		      (>= -2 base -36))))
  (cl-assert (mpq-p op))
  (mmux-gmp-c-mpq-get-str base (mpq-obj op)))


;;;; floating-point number functions: assignment

(defun mpf-set (rop op)
  "Assign the value of an `mpf' object to another `mpf' object."
  (cl-assert (mpf-p rop))
  (cl-assert (mpf-p op))
  (mmux-gmp-c-mpf-set (mpf-obj rop) (mpf-obj op)))

(defun mpf-set-si (rop op)
  "Assign the value of an exact integer object to an `mpf' object."
  (cl-assert (mpf-p rop))
  (cl-assert (integerp op))
  (mmux-gmp-c-mpf-set-si (mpf-obj rop) op))

(defun mpf-set-ui (rop op)
  "Assign the value of an exact integer object to an `mpf' object."
  (cl-assert (mpf-p rop))
  (cl-assert (and (integerp op)
		  (<= 0 op)))
  (mmux-gmp-c-mpf-set-ui (mpf-obj rop) op))

(defun mpf-set-d (rop op)
  "Assign the value of a floating-point object to an `mpf' object."
  (cl-assert (mpf-p rop))
  (cl-assert (floatp op))
  (mmux-gmp-c-mpf-set-d (mpf-obj rop) op))

(defun mpf-set-z (rop op)
  "Assign the value of an `mpz' object to an `mpf' object."
  (cl-assert (mpf-p rop))
  (cl-assert (mpz-p op))
  (mmux-gmp-c-mpf-set-q (mpf-obj rop) (mpz-obj op)))

(defun mpf-set-q (rop op)
  "Assign the value of an `mpq' object to an `mpf' object."
  (cl-assert (mpf-p rop))
  (cl-assert (mpq-p op))
  (mmux-gmp-c-mpf-set-q (mpf-obj rop) (mpq-obj op)))

(defun mpf-set-str (rop str base)
  "Assign the value of a string object to an `mpf' object."
  (cl-assert (mpf-p rop))
  (cl-assert (stringp str))
  (cl-assert (and (integerp base)
		  (or (<= +2 base +62)
		      (>= -2 base -62))))
  (mmux-gmp-c-mpf-set-str (mpf-obj rop) str base))

(defun mpf-swap (op1 op2)
  "Swap the values of two `mpf' objects."
  (cl-assert (mpf-p op1))
  (cl-assert (mpf-p op2))
  (mmux-gmp-c-mpf-swap (mpf-obj op1) (mpf-obj op2)))


;;;; floating-point number functions: arithmetic

(defun mpf-add (rop op1 op2)
  "Add two `mpf' objects."
  (cl-assert (mpf-p rop))
  (cl-assert (mpf-p op1))
  (cl-assert (mpf-p op2))
  (mmux-gmp-c-mpf-add (mpf-obj rop) (mpf-obj op1) (mpf-obj op2)))


;;;; floating-point number functions: conversion

(defun mpf-get-str (base ndigits op)
  "Convert an object of type `mpf' to a string."
  (cl-assert (and (integerp base)
		  (or (<= +2 base +62)
		      (>= -2 base -36))))
  (cl-assert (and (integerp ndigits)
		  (<= 0 ndigits)))
  (cl-assert (mpf-p op))
  (mmux-gmp-c-mpf-get-str base ndigits (mpf-obj op)))

(defun mpf-get-str* (base ndigits op)
  "Convert an object of type `mpf' to a formatted string."
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
