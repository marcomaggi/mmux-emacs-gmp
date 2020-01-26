;;; mmux-emacs-gmp.el --- gmp module

;; Copyright (C) 2020 Marco Maggi

;; Author: Marco Maggi <mrc.mgg@gmail.com>
;; Created: Jan 15, 2020
;; Time-stamp: <2020-01-26 07:18:12 marco>
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

(define-error 'mmux-gmp-invalid-initialisation-value
  "Invalid initialisation value."
  'mmux-gmp-error)


;;;; helpers

(defun mmux-gmp-bitcnt-p (obj)
  "Return true if OBJ is compatible with `mp_bitcnt_t'."
  (and (integerp obj)
       (<= 0 obj)))

(defun mmux-gmp-ulint-p (N)
  "Return true if N is compatible with `unsigned long int'."
  (and (integerp N)
       (<= 0 N)))

(defun mmux-gmp-slint-p (N)
  "Return true if N is compatible with `signed long int'."
  (integerp N))

;;; --------------------------------------------------------------------

(defmacro mmux-gmp-positive-p (obj)
  `(< 0 ,obj))

(defmacro mmux-gmp-negative-p (obj)
  `(> 0 ,obj))

(defmacro mmux-gmp-non-negative-p (obj)
  `(<= 0 ,obj))

(defmacro mmux-gmp-non-positive-p (obj)
  `(>= 0 ,obj))


;;;; user-ptr object wrappers: multiple precision integers

(cl-defstruct (mpz (:constructor make-mpz))
  obj)

(defun mpz (&optional INIT)
  "Build and return a new `mpz' object."
  (let ((Z (mmux-gmp-c-mpz-make)))
    (cond ((integerp INIT)
	   (mmux-gmp-c-mpz-set-si Z INIT))
	  ((floatp INIT)
	   (mmux-gmp-c-mpz-set-d  Z INIT))
	  ((mpz-p INIT)
	   (mmux-gmp-c-mpz-set    Z INIT))
	  ((mpq-p INIT)
	   (mmux-gmp-c-mpz-set-q  Z INIT))
	  ((mpf-p INIT)
	   (mmux-gmp-c-mpz-set-f  Z INIT))
	  (INIT
	   (signal 'mmux-gmp-invalid-initialisation-value (list INIT))))
    (make-mpz :obj Z)))


;;;; user-ptr object wrappers: multiple precision rationals

(cl-defstruct (mpq (:constructor make-mpq))
  obj)

(defun mpq (&optional INIT DENOMINATOR-INIT)
  "Build and return a new `mpq' object."
  (let ((Q (mmux-gmp-c-mpq-make)))
    (if DENOMINATOR-INIT
	(cond ((and (integerp INIT)
		    (integerp DENOMINATOR-INIT))
	       (mmux-gmp-c-mpq-set-si Q INIT DENOMINATOR-INIT))
	      (INIT
	       (signal 'mmux-gmp-invalid-initialisation-value (list INIT DENOMINATOR-INIT))))
      (cond ((floatp INIT)
	     (mmux-gmp-c-mpq-set-d  Q INIT))
	    ((mpq-p INIT)
	     (mmux-gmp-c-mpq-set    Q INIT))
	    ((mpz-p INIT)
	     (mmux-gmp-c-mpq-set-z  Q INIT))
	    ((mpf-p INIT)
	     (mmux-gmp-c-mpq-set-f  Q INIT))
	    (INIT
	     (signal 'mmux-gmp-invalid-initialisation-value (list INIT)))))
    (make-mpq :obj Q)))


;;;; user-ptr object wrappers: multiple precision floating-point

(cl-defstruct (mpf (:constructor make-mpf))
  obj)

(defun mpf (&optional INIT)
  "Build and return a new `mpf' object."
  (let ((F (mmux-gmp-c-mpf-make)))
    (cond ((integerp INIT)
	   (mmux-gmp-c-mpf-set-si F INIT))
	  ((floatp INIT)
	   (mmux-gmp-c-mpf-set-d  F INIT))
	  ((mpf-p INIT)
	   (mmux-gmp-c-mpf-set    F INIT))
	  ((mpz-p INIT)
	   (mmux-gmp-c-mpf-set-z  F INIT))
	  ((mpq-p INIT)
	   (mmux-gmp-c-mpf-set-q  F INIT))
	  (INIT
	   (signal 'mmux-gmp-invalid-initialisation-value (list INIT))))
    (make-mpf :obj F)))


;;;; user-ptr object wrappers: random numbers generators

(cl-defstruct (gmp-randstate (:constructor make-gmp-randstate))
  obj)

(defun gmp-randstate ()
  "Build and return a new `gmp-randstate' object."
  (let ((obj (mmux-gmp-c-gmp-randstate-make)))
    (make-gmp-randstate :obj obj)))


;;;; integer number functions: assignment

(cl-defgeneric mpz-set (rop op)
  "Assign the value of an `mpz' object to another `mpz' object.")
(cl-defmethod  mpz-set ((rop mpz) (op mpz))
  "Assign the value of an `mpz' object to another `mpz' object."
  (mmux-gmp-c-mpz-set (mpz-obj rop) (mpz-obj op)))

(cl-defgeneric mpz-set-si (rop op)
  "Assign the value of an exact integer object to an `mpz' object.")
(cl-defmethod  mpz-set-si ((rop mpz) (op integer))
  "Assign the value of an exact integer object to an `mpz' object."
  (mmux-gmp-c-mpz-set-si (mpz-obj rop) op))

(cl-defgeneric mpz-set-ui (rop op)
  "Assign the value of an exact integer object to an `mpz' object.")
(cl-defmethod  mpz-set-ui ((rop mpz) (op integer))
  "Assign the value of an exact integer object to an `mpz' object."
  (cl-assert (<= 0 op))
  (mmux-gmp-c-mpz-set-ui (mpz-obj rop) op))

(cl-defgeneric mpz-set-d (rop op)
  "Assign the value of a floating-point object to an `mpz' object.")
(cl-defmethod  mpz-set-d ((rop mpz) (op float))
  "Assign the value of a floating-point object to an `mpz' object."
  (mmux-gmp-c-mpz-set-d (mpz-obj rop) op))

(cl-defgeneric mpz-set-q (rop op)
  "Assign the value of an `mpq' object to an `mpz' object.")
(cl-defmethod  mpz-set-q ((rop mpz) (op mpq))
  "Assign the value of an `mpq' object to an `mpz' object."
  (mmux-gmp-c-mpz-set-q (mpz-obj rop) (mpq-obj op)))

(cl-defgeneric mpz-set-f (rop op)
  "Assign the value of an `mpf' object to an `mpz' object.")
(cl-defmethod  mpz-set-f ((rop mpz) (op mpf))
  "Assign the value of an `mpf' object to an `mpz' object."
  (mmux-gmp-c-mpz-set-f (mpz-obj rop) (mpf-obj op)))

(cl-defgeneric mpz-set-str (rop str base)
  "Assign the value of a string object to an `mpz' object.")
(cl-defmethod  mpz-set-str ((rop mpz) (str string) (base integer))
  "Assign the value of a string object to an `mpz' object."
  (cl-assert (or (zerop base)
		 (<= 2 base 36)))
  (mmux-gmp-c-mpz-set-str (mpz-obj rop) str base))

(cl-defgeneric mpz-swap (op1 op2)
  "Swap the values of two `mpz' objects.")
(cl-defmethod  mpz-swap ((op1 mpz) (op2 mpz))
  "Swap the values of two `mpz' objects."
  (mmux-gmp-c-mpz-swap (mpz-obj op1) (mpz-obj op2)))


;;;; integer number functions: arithmetic

(cl-defgeneric mpz-add (rop op1 op2)
  "Add two `mpz' objects.")
(cl-defmethod  mpz-add ((rop mpz) (op1 mpz) (op2 mpz))
  "Add two `mpz' objects."
  (mmux-gmp-c-mpz-add (mpz-obj rop) (mpz-obj op1) (mpz-obj op2)))

(cl-defgeneric mpz-add-ui (rop op1 op2)
  "Add an `mpz' object to an unsigned exact integer number.")
(cl-defmethod  mpz-add-ui ((rop mpz) (op1 mpz) (op2 integer))
  "Add an `mpz' object to an unsigned exact integer number."
  (mmux-gmp-c-mpz-add-ui (mpz-obj rop) (mpz-obj op1) op2))

;;; --------------------------------------------------------------------

(cl-defgeneric mpz-sub (rop op1 op2)
  "Subtract two `mpz' objects.")
(cl-defmethod  mpz-sub ((rop mpz) (op1 mpz) (op2 mpz))
  "Subtract two `mpz' objects."
  (mmux-gmp-c-mpz-sub (mpz-obj rop) (mpz-obj op1) (mpz-obj op2)))

(cl-defgeneric mpz-sub-ui (rop op1 op2)
  "Subtract an unsigned exact integer number from an `mpz' object.")
(cl-defmethod  mpz-sub-ui ((rop mpz) (op1 mpz) (op2 integer))
  "Subtract an unsigned exact integer number from an `mpz' object."
  (mmux-gmp-c-mpz-sub-ui (mpz-obj rop) (mpz-obj op1) op2))

;;; --------------------------------------------------------------------

(cl-defgeneric mpz-addmul (rop op1 op2)
  "Multiply two `mpz' objects, then add the result to another `mpz' object.")
(cl-defmethod  mpz-addmul ((rop mpz) (op1 mpz) (op2 mpz))
  "Multiply two `mpz' objects, then add the result to another `mpz' object."
  (mmux-gmp-c-mpz-addmul (mpz-obj rop) (mpz-obj op1) (mpz-obj op2)))

(cl-defgeneric mpz-addmul-ui (rop op1 op2)
  "Multiply an `mpz' object with an unsigned exact integer number, then add the result to another `mpz' object.")
(cl-defmethod  mpz-addmul-ui ((rop mpz) (op1 mpz) (op2 integer))
  "Multiply an `mpz' object with an unsigned exact integer number, then add the result to another `mpz' object."
  (mmux-gmp-c-mpz-addmul-ui (mpz-obj rop) (mpz-obj op1) op2))

;;; --------------------------------------------------------------------

(cl-defgeneric mpz-submul (rop op1 op2)
  "Multiply two `mpz' objects, then subtract the result from another `mpz' object.")
(cl-defmethod  mpz-submul ((rop mpz) (op1 mpz) (op2 mpz))
  "Multiply two `mpz' objects, then subtract the result from another `mpz' object."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p op1))
  (cl-assert (mpz-p op2))
  (mmux-gmp-c-mpz-submul (mpz-obj rop) (mpz-obj op1) (mpz-obj op2)))

(cl-defgeneric mpz-submul-ui (rop op1 op2)
  "Multiply an `mpz' object with an unsigned exact integer number, then subtract the result from another `mpz' object.")
(cl-defmethod  mpz-submul-ui ((rop mpz) (op1 mpz) (op2 integer))
  "Multiply an `mpz' object with an unsigned exact integer number, then subtract the result from another `mpz' object."
  (mmux-gmp-c-mpz-submul-ui (mpz-obj rop) (mpz-obj op1) op2))

;;; --------------------------------------------------------------------

(cl-defgeneric mpz-mul (rop op1 op2)
  "Multiply two `mpz' objects.")
(cl-defmethod  mpz-mul ((rop mpz) (op1 mpz) (op2 mpz))
  "Multiply two `mpz' objects."
  (mmux-gmp-c-mpz-mul (mpz-obj rop) (mpz-obj op1) (mpz-obj op2)))

(cl-defgeneric mpz-mul-si (rop op1 op2)
  "Multiply an `mpz' object by a signed exact integer number.")
(cl-defmethod  mpz-mul-si ((rop mpz) (op1 mpz) (op2 integer))
  "Multiply an `mpz' object by a signed exact integer number."
  (mmux-gmp-c-mpz-mul-si (mpz-obj rop) (mpz-obj op1) op2))

(cl-defgeneric mpz-mul-ui (rop op1 op2)
  "Multiply an `mpz' object by an unsigned exact integer number.")
(cl-defmethod  mpz-mul-ui ((rop mpz) (op1 mpz) (op2 integer))
  "Multiply an `mpz' object by an unsigned exact integer number."
  (cl-assert (<= 0 op2))
  (mmux-gmp-c-mpz-mul-ui (mpz-obj rop) (mpz-obj op1) op2))

;;; --------------------------------------------------------------------

(cl-defgeneric mpz-mul-2exp (rop op bitcnt)
  "Left shift an `mpz' object.")
(cl-defmethod  mpz-mul-2exp ((rop mpz) (op mpz) (bitcnt integer))
  "Left shift an `mpz' object."
  (mmux-gmp-c-mpz-mul-2exp (mpz-obj rop) (mpz-obj op) bitcnt))

(cl-defgeneric mpz-neg (rop op)
  "Negate an `mpz' object.")
(cl-defmethod  mpz-neg ((rop mpz) (op mpz))
  "Negate an `mpz' object."
  (mmux-gmp-c-mpz-neg (mpz-obj rop) (mpz-obj op)))

(cl-defgeneric mpz-abs (rop op)
  "Compute the absolute value of an `mpz' object.")
(cl-defmethod  mpz-abs ((rop mpz) (op mpz))
  "Compute the absolute value of an `mpz' object."
  (mmux-gmp-c-mpz-abs (mpz-obj rop) (mpz-obj op)))


;;;; integer number functions: conversion

(cl-defgeneric mpz-get-ui (op)
  "Convert an object of type `mpz' to an unsigned exact integer number.")
(cl-defmethod  mpz-get-ui ((op mpz))
  "Convert an object of type `mpz' to an unsigned exact integer number."
  (mmux-gmp-c-mpz-get-ui (mpz-obj op)))

(cl-defgeneric mpz-get-si (op)
  "Convert an object of type `mpz' to a signed exact integer number.")
(cl-defmethod  mpz-get-si ((op mpz))
  "Convert an object of type `mpz' to a signed exact integer number."
  (mmux-gmp-c-mpz-get-si (mpz-obj op)))

(cl-defgeneric mpz-get-d (op)
  "Convert an object of type `mpz' to a floating-point number.")
(cl-defmethod  mpz-get-d ((op mpz))
  "Convert an object of type `mpz' to a floating-point number."
  (mmux-gmp-c-mpz-get-d (mpz-obj op)))

(cl-defgeneric mpz-get-d-2exp (op)
  "Convert an object of type `mpz' to a floating-point number, returning the exponent separately.")
(cl-defmethod  mpz-get-d-2exp ((op mpz))
  "Convert an object of type `mpz' to a floating-point number, returning the exponent separately."
  (mmux-gmp-c-mpz-get-d-2exp (mpz-obj op)))

(cl-defgeneric mpz-get-str (base op)
  "Convert an object of type `mpz' to a string.")
(cl-defmethod  mpz-get-str ((base integer) (op mpz))
  "Convert an object of type `mpz' to a string."
  (cl-assert (or (<= +2 base +36)
		 (>= -2 base -36)))
  (mmux-gmp-c-mpz-get-str base (mpz-obj op)))


;;;; integer number functions: division

;;; void mpz_cdiv_q (mpz_t Q, const mpz_t N, const mpz_t D)
(cl-defgeneric mpz-cdiv-q (Q N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-cdiv-q ((Q mpz) (N mpz) (D mpz))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (mmux-gmp-c-cdiv-q (mpz-obj Q) (mpz-obj N) (mpz-obj D)))

;;; void mpz_cdiv_r (mpz_t R, const mpz_t N, const mpz_t D) */
(cl-defgeneric mpz-cdiv-r (R N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-cdiv-r ((R mpz) (N mpz) (D mpz))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (mmux-gmp-c-cdiv-r (mpz-obj R) (mpz-obj N) (mpz-obj D)))

;;; void mpz_cdiv_qr (mpz_t Q, mpz_t R, const mpz_t N, const mpz_t D) */
(cl-defgeneric mpz-cdiv-qr (Q R N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-cdiv-qr ((Q mpz) (R mpz) (N mpz) (D mpz))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (mmux-gmp-c-cdiv-qr (mpz-obj Q) (mpz-obj R) (mpz-obj N) (mpz-obj D)))

;;; unsigned long int mpz_cdiv_q_ui (mpz_t Q, const mpz_t N, unsigned long int D) */
(cl-defgeneric mpz-cdiv-q-ui (Q N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-cdiv-q-ui ((Q mpz) (N mpz) (D integer))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-cdiv-q-ui (mpz-obj Q) (mpz-obj N) D))

;;; unsigned long int mpz_cdiv_r_ui (mpz_t R, const mpz_t N, unsigned long int D) */
(cl-defgeneric mpz-cdiv-r-ui (R N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-cdiv-r-ui ((R mpz) (N mpz) (D integer))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-cdiv-r-ui (mpz-obj R) (mpz-obj N) D))

;;; unsigned long int mpz_cdiv_qr_ui (mpz_t Q, mpz_t R, const mpz_t N, unsigned long int D) */
(cl-defgeneric mpz-cdiv-qr-ui (Q R N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-cdiv-qr-ui ((Q mpz) (R mpz) (N mpz) (D integer))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-cdiv-qr-ui (mpz-obj Q) (mpz-obj R) (mpz-obj N) D))

;;; unsigned long int mpz_cdiv_ui (const mpz_t N, unsigned long int D) */
(cl-defgeneric mpz-cdiv-ui (N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-cdiv-ui ((N mpz) (D integer))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-cdiv-ui (mpz-obj N) D))

;;; void mpz_cdiv_q_2exp (mpz_t Q, const mpz_t N, mp_bitcnt_t B) */
(cl-defgeneric mpz-cdiv-q-2exp (Q N B)
  "Divide N by D, forming a quotient Q and/or remainder R; compute D as 2^B.")
(cl-defmethod  mpz-cdiv-q-2exp ((Q mpz) (N mpz) (B integer))
  "Divide N by D, forming a quotient Q and/or remainder R; compute D as 2^B."
  (cl-assert (mmux-gmp-bitcnt-p B))
  (mmux-gmp-c-cdiv-q-2exp (mpz-obj Q) (mpz-obj N) B))

;;; void mpz_cdiv_r_2exp (mpz_t R, const mpz_t N, mp_bitcnt_t B) */
(cl-defgeneric mpz-cdiv-r-2exp (R N B)
  "Divide N by D, forming a quotient Q and/or remainder R; compute D as 2^B.")
(cl-defmethod  mpz-cdiv-r-2exp ((R mpz) (N mpz) (B integer))
  "Divide N by D, forming a quotient Q and/or remainder R; compute D as 2^B."
  (cl-assert (mmux-gmp-bitcnt-p B))
  (mmux-gmp-c-cdiv-r-2exp (mpz-obj R) (mpz-obj N) B))

;;; --------------------------------------------------------------------

;;; void mpz_fdiv_q (mpz_t Q, const mpz_t N, const mpz_t D) */
(cl-defgeneric mpz-fdiv-q (Q N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-fdiv-q ((Q mpz) (N mpz) (D mpz))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (mmux-gmp-c-fdiv-q (mpz-obj Q) (mpz-obj N) (mpz-obj D)))

;;; void mpz_fdiv_r (mpz_t R, const mpz_t N, const mpz_t D) */
(cl-defgeneric mpz-fdiv-r (R N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-fdiv-r ((R mpz) (N mpz) (D mpz))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (mmux-gmp-c-fdiv-r (mpz-obj R) (mpz-obj N) (mpz-obj D)))

;;; void mpz_fdiv_qr (mpz_t Q, mpz_t R, const mpz_t N, const mpz_t D) */
(cl-defgeneric mpz-fdiv-qr (Q R N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-fdiv-qr ((Q mpz) (R mpz) (N mpz) (D mpz))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (mmux-gmp-c-fdiv-qr (mpz-obj Q) (mpz-obj R) (mpz-obj N) (mpz-obj D)))

;;; unsigned long int mpz_fdiv_q_ui (mpz_t Q, const mpz_t N, unsigned long int D) */
(cl-defgeneric mpz-fdiv-q-ui (Q N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-fdiv-q-ui ((Q mpz) (N mpz) (D integer))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-fdiv-q-ui (mpz-obj Q) (mpz-obj N) D))

;;; unsigned long int mpz_fdiv_r_ui (mpz_t R, const mpz_t N, unsigned long int D) */
(cl-defgeneric mpz-fdiv-r-ui (R N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-fdiv-r-ui ((R mpz) (N mpz) (D integer))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-fdiv-r-ui (mpz-obj R) (mpz-obj N) D))

;;; unsigned long int mpz_fdiv_qr_ui (mpz_t Q, mpz_t R, const mpz_t N, unsigned long int D) */
(cl-defgeneric mpz-fdiv-qr-ui (Q R N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-fdiv-qr-ui ((Q mpz) (R mpz) (N mpz) (D integer))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-fdiv-qr-ui (mpz-obj Q) (mpz-obj R) (mpz-obj N) D))

;;; unsigned long int mpz_fdiv_ui (const mpz_t N, unsigned long int D) */
(cl-defgeneric mpz-fdiv-ui (N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-fdiv-ui ((N mpz) (D integer))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-fdiv-ui (mpz-obj N) D))

;;; void mpz_fdiv_q_2exp (mpz_t Q, const mpz_t N, mp_bitcnt_t B) */
(cl-defgeneric mpz-fdiv-q-2exp (Q N B)
  "Divide N by D, forming a quotient Q and/or remainder R; compute D as 2^B.")
(cl-defmethod  mpz-fdiv-q-2exp ((Q mpz) (N mpz) (B integer))
  "Divide N by D, forming a quotient Q and/or remainder R; compute D as 2^B."
  (cl-assert (mmux-gmp-bitcnt-p B))
  (mmux-gmp-c-fdiv-q-2exp (mpz-obj Q) (mpz-obj N) B))

;;; void mpz_fdiv_r_2exp (mpz_t R, const mpz_t N, mp_bitcnt_t B) */
(cl-defgeneric mpz-fdiv-r-2exp (R N B)
  "Divide N by D, forming a quotient Q and/or remainder R; compute D as 2^B.")
(cl-defmethod  mpz-fdiv-r-2exp ((R mpz) (N mpz) (B integer))
  "Divide N by D, forming a quotient Q and/or remainder R; compute D as 2^B."
  (cl-assert (mmux-gmp-bitcnt-p B))
  (mmux-gmp-c-fdiv-r-2exp (mpz-obj R) (mpz-obj N) B))

;;; --------------------------------------------------------------------

;;; void mpz_tdiv_q (mpz_t Q, const mpz_t N, const mpz_t D) */
(cl-defgeneric mpz-tdiv-q (Q N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-tdiv-q ((Q mpz) (N mpz) (D mpz))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (mmux-gmp-c-tdiv-q (mpz-obj Q) (mpz-obj N) (mpz-obj D)))

;;; void mpz_tdiv_r (mpz_t R, const mpz_t N, const mpz_t D) */
(cl-defgeneric mpz-tdiv-r (R N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-tdiv-r ((R mpz) (N mpz) (D mpz))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (mmux-gmp-c-tdiv-r (mpz-obj R) (mpz-obj N) (mpz-obj D)))

;;; void mpz_tdiv_qr (mpz_t Q, mpz_t R, const mpz_t N, const mpz_t D) */
(cl-defgeneric mpz-tdiv-qr (Q R N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-tdiv-qr ((Q mpz) (R mpz) (N mpz) (D mpz))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (mmux-gmp-c-tdiv-qr (mpz-obj Q) (mpz-obj R) (mpz-obj N) (mpz-obj D)))

;;; unsigned long int mpz_tdiv_q_ui (mpz_t Q, const mpz_t N, unsigned long int D) */
(cl-defgeneric mpz-tdiv-q-ui (Q N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-tdiv-q-ui ((Q mpz) (N mpz) (D integer))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-tdiv-q-ui (mpz-obj Q) (mpz-obj N) D))

;;; unsigned long int mpz_tdiv_r_ui (mpz_t R, const mpz_t N, unsigned long int D) */
(cl-defgeneric mpz-tdiv-r-ui (R N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-tdiv-r-ui ((R mpz) (N mpz) (D integer))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-tdiv-r-ui (mpz-obj R) (mpz-obj N) D))

;;; unsigned long int mpz_tdiv_qr_ui (mpz_t Q, mpz_t R, const mpz_t N, unsigned long int D) */
(cl-defgeneric mpz-tdiv-qr-ui (Q R N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-tdiv-qr-ui ((Q mpz) (R mpz) (N mpz) (D integer))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-tdiv-qr-ui (mpz-obj Q) (mpz-obj R) (mpz-obj N) D))

;;; unsigned long int mpz_tdiv_ui (const mpz_t N, unsigned long int D) */
(cl-defgeneric mpz-tdiv-ui (N D)
  "Divide N by D, forming a quotient Q and/or remainder R.")
(cl-defmethod  mpz-tdiv-ui ((N mpz) (D integer))
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-tdiv-ui (mpz-obj N) D))

;;; void mpz_tdiv_q_2exp (mpz_t Q, const mpz_t N, mp_bitcnt_t B) */
(cl-defgeneric mpz-tdiv-q-2exp (Q N B)
  "Divide N by D, forming a quotient Q and/or remainder R; compute D as 2^B.")
(cl-defmethod  mpz-tdiv-q-2exp ((Q mpz) (N mpz) (B integer))
  "Divide N by D, forming a quotient Q and/or remainder R; compute D as 2^B."
  (cl-assert (mmux-gmp-bitcnt-p B))
  (mmux-gmp-c-tdiv-q-2exp (mpz-obj Q) (mpz-obj N) B))

;;; void mpz_tdiv_r_2exp (mpz_t R, const mpz_t N, mp_bitcnt_t B) */
(cl-defgeneric mpz-tdiv-r-2exp (R N B)
  "Divide N by D, forming a quotient Q and/or remainder R; compute D as 2^B.")
(cl-defmethod  mpz-tdiv-r-2exp ((R mpz) (N mpz) (B integer))
  "Divide N by D, forming a quotient Q and/or remainder R; compute D as 2^B."
  (cl-assert (mmux-gmp-bitcnt-p B))
  (mmux-gmp-c-tdiv-r-2exp (mpz-obj R) (mpz-obj N) B))

;;; --------------------------------------------------------------------

;;; void mpz_mod (mpz_t R, const mpz_t N, const mpz_t D) */
(cl-defgeneric mpz-mod (R N D)
  "Set R to N mod D.")
(cl-defmethod  mpz-mod ((R mpz) (N mpz) (D mpz))
  "Set R to N mod D."
  (mmux-gmp-c-mod (mpz-obj R) (mpz-obj N) (mpz-obj D)))

;;; unsigned long int mpz_mod_ui (mpz_t R, const mpz_t N, unsigned long int D) */
(cl-defgeneric mpz-mod-ui (R N D)
  "Set R to N mod D.")
(cl-defmethod  mpz-mod-ui ((R mpz) (N mpz) (D integer))
  "Set R to N mod D."
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-mod-ui (mpz-obj R) (mpz-obj N) D))

;;; --------------------------------------------------------------------

;;; void mpz_divexact (mpz_t Q, const mpz_t N, const mpz_t D) */
(cl-defgeneric mpz-divexact (Q N D)
  "Set Q to N/D.")
(cl-defmethod  mpz-divexact ((Q mpz) (N mpz) (D mpz))
  "Set Q to N/D."
  (mmux-gmp-c-divexact (mpz-obj Q) (mpz-obj N) (mpz-obj D)))

;;; void mpz_divexact_ui (mpz_t Q, const mpz_t N, unsigned long D) */
(cl-defgeneric mpz-divexact-ui (Q N D)
  "Set Q to N/D.")
(cl-defmethod  mpz-divexact-ui ((Q mpz) (N mpz) (D integer))
  "Set Q to N/D."
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-divexact-ui (mpz-obj Q) (mpz-obj N) D))

;;; --------------------------------------------------------------------

;;; int mpz_divisible_p (const mpz_t N, const mpz_t D) */
(cl-defgeneric mpz-divisible-p (N D)
  "Return true if N is exactly divisible by D.")
(cl-defmethod  mpz-divisible-p ((N mpz) (D mpz))
  "Return true if N is exactly divisible by D."
  (mmux-gmp-c-divisible-p (mpz-obj N) (mpz-obj D)))

;;; int mpz_divisible_ui_p (const mpz_t N, unsigned long int D) */
(cl-defgeneric mpz-divisible-ui-p (N D)
  "Return true if N is exactly divisible by D.")
(cl-defmethod  mpz-divisible-ui-p ((N mpz) (D integer))
  "Return true if N is exactly divisible by D."
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-divisible-ui-p (mpz-obj N) D))

;;; int mpz_divisible_2exp_p (const mpz_t N, mp_bitcnt_t B) */
(cl-defgeneric mpz-divisible-2exp-p (N B)
  "Return true if N is exactly divisible by 2^B.")
(cl-defmethod  mpz-divisible-2exp-p ((N mpz) (B integer))
  "Return true if N is exactly divisible by 2^B."
  (cl-assert (mmux-gmp-bitcnt-p B))
  (mmux-gmp-c-divisible-2exp-p (mpz-obj N) B))

;;; --------------------------------------------------------------------

;;; int mpz_congruent_p (const mpz_t N, const mpz_t C, const mpz_t D) */
(cl-defgeneric mpz-congruent-p (N C D)
  "Return non-zero if N is congruent to C modulo D.")
(cl-defmethod  mpz-congruent-p ((N mpz) (C mpz) (D mpz))
  "Return non-zero if N is congruent to C modulo D."
  (mmux-gmp-c-congruent-p (mpz-obj N) (mpz-obj C) (mpz-obj D)))

;;; int mpz_congruent_ui_p (const mpz_t N, unsigned long int C, unsigned long int D) */
(cl-defgeneric mpz-congruent-ui-p (N C D)
  "Return non-zero if N is congruent to C modulo D.")
(cl-defmethod  mpz-congruent-ui-p ((N mpz) (C integer) (D integer))
  "Return non-zero if N is congruent to C modulo D."
  (cl-assert (mmux-gmp-ulint-p C))
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-congruent-ui-p (mpz-obj N) C D))

;;; int mpz_congruent_2exp_p (const mpz_t N, const mpz_t C, mp_bitcnt_t B) */
(cl-defgeneric mpz-congruent-2exp-p (N C B)
  "Return non-zero if N is congruent to C modulo 2^B.")
(cl-defmethod  mpz-congruent-2exp-p ((N mpz) (C mpz) (B integer))
  "Return non-zero if N is congruent to C modulo 2^B."
  (cl-assert (mmux-gmp-bitcnt-p B))
  (mmux-gmp-c-congruent-2exp-p (mpz-obj N) (mpz-obj C) B))


;;;; integer number functions: exponentiation

;; void mpz_powm (mpz_t ROP, const mpz_t BASE, const mpz_t EXP, const mpz_t MOD)
(cl-defgeneric mpz-powm (rop base exp mod)
  "Set ROP to (BASE raised to EXP) modulo MOD.")
(cl-defmethod  mpz-powm (rop base exp mod)
  "Set ROP to (BASE raised to EXP) modulo MOD."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p base))
  (cl-assert (mpz-p exp))
  (cl-assert (mpz-p mod))
  (mmux-gmp-c-mpz-powm (mpz-obj rop) (mpz-obj base) (mpz-obj exp) (mpz-obj mod)))

;; void mpz_powm_ui (mpz_t ROP, const mpz_t BASE, unsigned long int EXP, const mpz_t MOD)
(cl-defgeneric mpz-powm-ui (rop base exp mod)
  "Set ROP to (BASE raised to EXP) modulo MOD.")
(cl-defmethod  mpz-powm-ui (rop base exp mod)
  "Set ROP to (BASE raised to EXP) modulo MOD."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p base))
  (cl-assert (mmux-gmp-ulint-p exp))
  (cl-assert (mpz-p mod))
  (mmux-gmp-c-mpz-powm-ui (mpz-obj rop) (mpz-obj base) exp (mpz-obj mod)))

;; void mpz_powm_sec (mpz_t ROP, const mpz_t BASE, const mpz_t EXP, const mpz_t MOD)
(cl-defgeneric mpz-powm-sec (rop base exp mod)
  "Set ROP to (BASE raised to EXP) modulo MOD.  MOD must be odd.")
(cl-defmethod  mpz-powm-sec (rop base exp mod)
  "Set ROP to (BASE raised to EXP) modulo MOD.  MOD must be odd."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p base))
  (cl-assert (and (mpz-p exp)
		  (< 0 (mmux-gmp-c-mpz-cmp-si (mpz-obj exp) 0))))
  (cl-assert (and (mpz-p mod)
		  (mmux-gmp-c-mpz-odd-p (mpz-obj mod))))
  (mmux-gmp-c-mpz-powm-sec (mpz-obj rop) (mpz-obj base) (mpz-obj exp) (mpz-obj mod)))

;; void mpz_pow_ui (mpz_t ROP, const mpz_t BASE, unsigned long int EXP)
(cl-defgeneric mpz-pow-ui (rop base exp)
  "Set ROP to BASE raised to EXP.")
(cl-defmethod  mpz-pow-ui (rop base exp)
  "Set ROP to BASE raised to EXP."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p base))
  (cl-assert (mmux-gmp-ulint-p exp))
  (mmux-gmp-c-mpz-pow-ui (mpz-obj rop) (mpz-obj base) exp))

;; void mpz_ui_pow_ui (mpz_t ROP, unsigned long int BASE, unsigned long int EXP)
(cl-defgeneric mpz-ui-pow-ui (rop base exp)
  "Set ROP to BASE raised to EXP.")
(cl-defmethod  mpz-ui-pow-ui (rop base exp)
  "Set ROP to BASE raised to EXP."
  (cl-assert (mpz-p rop))
  (cl-assert (mmux-gmp-ulint-p base))
  (cl-assert (mmux-gmp-ulint-p exp))
  (mmux-gmp-c-mpz-ui-pow-ui (mpz-obj rop) base exp))


;;;; integer number functions: root extraction functions

;; int mpz_root (mpz_t ROP, const mpz_t OP, unsigned long int N)
(cl-defgeneric mpz-root (rop op N)
  "Set ROP to the truncated integer part of the Nth root of OP.")
(cl-defmethod mpz-root ((rop mpz) (op mpz) (N integer))
  "Set ROP to the truncated integer part of the Nth root of OP."
  (cl-assert (mmux-gmp-positive-p N))
  (mmux-gmp-c-mpz-root (mpz-obj rop) (mpz-obj op) N))

;; void mpz_rootrem (mpz_t ROOT, mpz_t REM, const mpz_t U, unsigned long int N)
(cl-defgeneric mpz-rootrem (root rem U N)
  "Set ROOT to the truncated integer part of the Nth root of U.  Set REM to the remainder, U-ROOT^N.")
(cl-defmethod mpz-rootrem ((root mpz) (rem mpz) (U mpz) (N integer))
  "Set ROOT to the truncated integer part of the Nth root of U.  Set REM to the remainder, U-ROOT^N."
  (cl-assert (mmux-gmp-positive-p N))
  (mmux-gmp-c-mpz-rootrem (mpz-obj root) (mpz-obj rem) (mpz-obj U) N))

;; void mpz_sqrt (mpz_t ROP, const mpz_t OP)
(cl-defgeneric mpz-sqrt (rop op)
  "Set ROP to the truncated integer part of the square root of OP.")
(cl-defmethod mpz-sqrt ((rop mpz) (op mpz))
  "Set ROP to the truncated integer part of the square root of OP."
  (mmux-gmp-c-mpz-sqrt (mpz-obj rop) (mpz-obj op)))

;; void mpz_sqrtrem (mpz_t ROP1, mpz_t ROP2, const mpz_t OP)
(cl-defgeneric mpz-sqrtrem (rop1 rop2 op)
  "Set ROP1 to the truncated integer part of the square root of OP.  Set ROP2 to the remainder OP-ROP1*ROP1.")
(cl-defmethod mpz-sqrtrem ((rop1 mpz) (rop2 mpz) (op mpz))
  "Set ROP1 to the truncated integer part of the square root of OP.  Set ROP2 to the remainder OP-ROP1*ROP1."
  (mmux-gmp-c-mpz-sqrtrem (mpz-obj rop1) (mpz-obj rop2) (mpz-obj op)))

;; int mpz_perfect_power_p (const mpz_t OP)
(cl-defgeneric mpz-perfect-power-p (op)
  "Return true if OP is a perfect power.")
(cl-defmethod mpz-perfect-power-p ((op mpz))
  "Return true if OP is a perfect power."
  (mmux-gmp-c-mpz-perfect-power-p (mpz-obj op)))

;; int mpz_perfect_square_p (const mpz_t OP)
(cl-defgeneric mpz-perfect-square-p (op)
  "Return true if OP is a perfect square.")
(cl-defmethod mpz-perfect-square-p ((op mpz))
  "Return true if OP is a perfect square."
  (mmux-gmp-c-mpz-perfect-square-p (mpz-obj op)))


;;;; integer number functions: number theoretic functions

;; int mpz_probab_prime_p (const mpz_t N, int REPS)
(cl-defgeneric mpz-probab-prime-p (N reps)
  "Determine whether N is prime.")
(cl-defmethod  mpz-probab-prime-p ((N mpz) (reps integer))
  "Determine whether N is prime."
  (mmux-gmp-c-mpz-probab-prime-p (mpz-obj N) reps))

;; void mpz_nextprime (mpz_t ROP, const mpz_t OP)
(cl-defgeneric mpz-nextprime (rop op)
  "Set ROP to the next prime greater than OP.")
(cl-defmethod  mpz-nextprime ((rop mpz) (op mpz))
  "Set ROP to the next prime greater than OP."
  (mmux-gmp-c-mpz-nextprime (mpz-obj rop) (mpz-obj op)))

;; void mpz_gcd (mpz_t ROP, const mpz_t OP1, const mpz_t OP2)
(cl-defgeneric mpz-gcd (rop op1 op2)
  "Set ROP to the greatest common divisor of OP1 and OP2.")
(cl-defmethod  mpz-gcd ((rop mpz) (op1 mpz) (op2 mpz))
  "Set ROP to the greatest common divisor of OP1 and OP2."
  (mmux-gmp-c-mpz-gcd (mpz-obj rop) (mpz-obj op1) (mpz-obj op2)))

;; unsigned long int mpz_gcd_ui (mpz_t ROP, const mpz_t OP1, unsigned long int OP2)
(cl-defgeneric mpz-gcd-ui (rop op1 op2)
  "Set ROP to the greatest common divisor of OP1 and OP2.")
(cl-defmethod  mpz-gcd-ui ((rop mpz) (op1 mpz) (op2 integer))
  "Set ROP to the greatest common divisor of OP1 and OP2."
  (cl-assert (mmux-gmp-non-negative-p op2))
  (mmux-gmp-c-mpz-gcd-ui (mpz-obj rop) (mpz-obj op1) op2))

;; void mpz_gcdext (mpz_t G, mpz_t S, mpz_t T, const mpz_t A, const mpz_t B)
(cl-defgeneric mpz-gcdext (G S T A B)
  "Set G to the greatest common divisor of A and B, and in addition set S and T to coefficients satisfying A*S + B*T = G.")
(cl-defmethod  mpz-gcdext ((G mpz) (S mpz) (T mpz) (A mpz) (B mpz))
  "Set G to the greatest common divisor of A and B, and in addition set S and T to coefficients satisfying A*S + B*T = G."
  (mmux-gmp-c-mpz-gcdext (mpz-obj G) (mpz-obj S) (mpz-obj T) (mpz-obj A) (mpz-obj B)))

;; void mpz_lcm (mpz_t ROP, const mpz_t OP1, const mpz_t OP2)
(cl-defgeneric mpz-lcm (rop op1 op2)
  "Set ROP to the least common multiple of OP1 and OP2.")
(cl-defmethod  mpz-lcm ((rop mpz) (op1 mpz) (op2 mpz))
  "Set ROP to the least common multiple of OP1 and OP2."
  (mmux-gmp-c-mpz-lcm (mpz-obj rop) (mpz-obj op1) (mpz-obj op2)))

;; void mpz_lcm_ui (mpz_t ROP, const mpz_t OP1, unsigned long OP2)
(cl-defgeneric mpz-lcm-ui (rop op1 op2)
  "Set ROP to the least common multiple of OP1 and OP2.")
(cl-defmethod  mpz-lcm-ui ((rop mpz) (op1 mpz) (op2 integer))
  "Set ROP to the least common multiple of OP1 and OP2."
  (cl-assert (mmux-gmp-non-negative-p op2))
  (mmux-gmp-c-mpz-lcm-ui (mpz-obj rop) (mpz-obj op1) op2))

;; int mpz_invert (mpz_t ROP, const mpz_t OP1, const mpz_t OP2)
(cl-defgeneric mpz-invert (rop op1 op2)
  "Compute the inverse of OP1 modulo OP2 and put the result in ROP.")
(cl-defmethod  mpz-invert ((rop mpz) (op1 mpz) (op2 mpz))
  "Compute the inverse of OP1 modulo OP2 and put the result in ROP."
  (cl-assert (mpz-non-zero-p op2))
  (mmux-gmp-c-mpz-invert (mpz-obj rop) (mpz-obj op1) (mpz-obj op2)))

;; int mpz_jacobi (const mpz_t A, const mpz_t B)
(cl-defgeneric mpz-jacobi (A B)
  "Calculate the Jacobi symbol (A/B).  This is defined only for B odd.")
(cl-defmethod  mpz-jacobi ((A mpz) (B mpz))
  "Calculate the Jacobi symbol (A/B).  This is defined only for B odd."
  (cl-assert (mpz-odd-p B))
  (mmux-gmp-c-mpz-jacobi (mpz-obj A) (mpz-obj B)))

;; int mpz_legendre (const mpz_t A, const mpz_t P)
(cl-defgeneric mpz-legendre (A B)
  "Calculate the Legendre symbol (A/P).")
(cl-defmethod  mpz-legendre ((A mpz) (B mpz))
  "Calculate the Legendre symbol (A/P)."
  (mmux-gmp-c-mpz-legendre (mpz-obj A) (mpz-obj B)))

;; int mpz_kronecker (const mpz_t A, const mpz_t B)
(cl-defgeneric mpz-kronecker (A B)
  "Calculate the Jacobi symbol (A/B) with the Kronecker extension (a/2)=(2/a) when a odd, or (a/2)=0 when a even.")
(cl-defmethod  mpz-kronecker ((A mpz) (B mpz))
  "Calculate the Jacobi symbol (A/B) with the Kronecker extension (a/2)=(2/a) when a odd, or (a/2)=0 when a even."
  (mmux-gmp-c-mpz-kronecker (mpz-obj A) (mpz-obj B)))

;; int mpz_kronecker_si (const mpz_t A, long B)
(cl-defgeneric mpz-kronecker-si (A B)
  "Calculate the Jacobi symbol (A/B) with the Kronecker extension (a/2)=(2/a) when a odd, or (a/2)=0 when a even.")
(cl-defmethod  mpz-kronecker-si ((A mpz) (B integer))
  "Calculate the Jacobi symbol (A/B) with the Kronecker extension (a/2)=(2/a) when a odd, or (a/2)=0 when a even."
  (mmux-gmp-c-mpz-kronecker-si (mpz-obj A) B))

;; int mpz_kronecker_ui (const mpz_t A, unsigned long B)
(cl-defgeneric mpz-kronecker-ui (A B)
  "Calculate the Jacobi symbol (A/B) with the Kronecker extension (a/2)=(2/a) when a odd, or (a/2)=0 when a even.")
(cl-defmethod  mpz-kronecker-ui ((A mpz) (B integer))
  "Calculate the Jacobi symbol (A/B) with the Kronecker extension (a/2)=(2/a) when a odd, or (a/2)=0 when a even."
  (cl-assert (mmux-gmp-non-negative-p B))
  (mmux-gmp-c-mpz-kronecker-ui (mpz-obj A) B))

;; int mpz_si_kronecker (long A, const mpz_t B)
(cl-defgeneric mpz-si-kronecker (A B)
  "Calculate the Jacobi symbol (A/B) with the Kronecker extension (a/2)=(2/a) when a odd, or (a/2)=0 when a even.")
(cl-defmethod  mpz-si-kronecker ((A integer) (B mpz))
  "Calculate the Jacobi symbol (A/B) with the Kronecker extension (a/2)=(2/a) when a odd, or (a/2)=0 when a even."
  (mmux-gmp-c-mpz-si-kronecker A (mpz-obj B)))

;; int mpz_ui_kronecker (unsigned long A, const mpz_t B)
(cl-defgeneric mpz-ui-kronecker (A B)
  "Calculate the Jacobi symbol (A/B) with the Kronecker extension (a/2)=(2/a) when a odd, or (a/2)=0 when a even.")
(cl-defmethod  mpz-ui-kronecker ((A integer) (B mpz))
  "Calculate the Jacobi symbol (A/B) with the Kronecker extension (a/2)=(2/a) when a odd, or (a/2)=0 when a even."
  (mmux-gmp-c-mpz-ui-kronecker A (mpz-obj B)))

;; mp_bitcnt_t mpz_remove (mpz_t ROP, const mpz_t OP, const mpz_t F)
(cl-defgeneric mpz-remove (rop op F)
  "Remove all occurrences of the factor F from OP and store the result in ROP.")
(cl-defmethod  mpz-remove ((rop mpz) (op mpz) (F mpz))
  "Remove all occurrences of the factor F from OP and store the result in ROP."
  (mmux-gmp-c-mpz-remove (mpz-obj rop) (mpz-obj op) (mpz-obj F)))

;; void mpz_fac_ui (mpz_t ROP, unsigned long int N)
(cl-defgeneric mpz-fac-ui (rop N)
  "Set ROP to the factorial of N.")
(cl-defmethod  mpz-fac-ui ((rop mpz) (N integer))
  "Set ROP to the factorial of N."
  (cl-assert (mmux-gmp-non-negative-p N))
  (mmux-gmp-c-mpz-fac-ui (mpz-obj rop) N))

;; void mpz_2fac_ui (mpz_t ROP, unsigned long int N)
(cl-defgeneric mpz-2fac-ui (rop N)
  "Set ROP to the double factorial of N: N!!.")
(cl-defmethod  mpz-2fac-ui ((rop mpz) (N integer))
  "Set ROP to the double factorial of N: N!!."
  (cl-assert (mmux-gmp-non-negative-p N))
  (mmux-gmp-c-mpz-2fac-ui (mpz-obj rop) N))

;; void mpz_mfac_uiui (mpz_t ROP, unsigned long int N, unsigned long int M)
(cl-defgeneric mpz-mfac-uiui (rop N M)
  "Set ROP to the M-multi-factorial of N: N!^(M).")
(cl-defmethod  mpz-mfac-uiui ((rop mpz) (N integer) (M integer))
  "Set ROP to the M-multi-factorial of N: N!^(M)."
  (cl-assert (mmux-gmp-non-negative-p N))
  (cl-assert (mmux-gmp-non-negative-p M))
  (mmux-gmp-c-mpz-mfac-uiui (mpz-obj rop) N M))

;; void mpz_primorial_ui (mpz_t ROP, unsigned long int N)
(cl-defgeneric mpz-primorial-ui (rop N)
  "Set ROP to the primorial of N: the product of all positive prime numbers <=N.")
(cl-defmethod  mpz-primorial-ui ((rop mpz) (N integer))
  "Set ROP to the primorial of N: the product of all positive prime numbers <=N."
  (cl-assert (mmux-gmp-non-negative-p N))
  (mmux-gmp-c-mpz-primorial-ui (mpz-obj rop) N))

;; void mpz_bin_ui (mpz_t ROP, const mpz_t N, unsigned long int K)
(cl-defgeneric mpz-bin-ui (rop N K)
  "Compute the binomial coefficient N over K and store the result in ROP.")
(cl-defmethod  mpz-bin-ui ((rop mpz) (N mpz) (K integer))
  "Compute the binomial coefficient N over K and store the result in ROP."
  (cl-assert (mmux-gmp-non-negative-p K))
  (mmux-gmp-c-mpz-bin-ui (mpz-obj rop) (mpz-obj N) K))

;; void mpz_bin_uiui (mpz_t ROP, unsigned long int N, unsigned long int K)
(cl-defgeneric mpz-bin-uiui (rop N K)
  "Compute the binomial coefficient N over K and store the result in ROP.")
(cl-defmethod  mpz-bin-uiui ((rop mpz) (N integer) (K integer))
  "Compute the binomial coefficient N over K and store the result in ROP."
  (cl-assert (mmux-gmp-non-negative-p K))
  (mmux-gmp-c-mpz-bin-uiui (mpz-obj rop) N K))

;; void mpz_fib_ui (mpz_t FN, unsigned long int N)
(cl-defgeneric mpz-fib-ui (FN N)
  "Set FN to to F[N]: the N'th Fibonacci number.")
(cl-defmethod  mpz-fib-ui ((FN mpz) (N integer))
  "Set FN to to F[N]: the N'th Fibonacci number."
  (cl-assert (mmux-gmp-non-negative-p N))
  (mmux-gmp-c-mpz-fib-ui (mpz-obj FN) N))

;; void mpz_fib2_ui (mpz_t FN, mpz_t FNSUB1, unsigned long int N)
(cl-defgeneric mpz-fib2-ui (FN FNSUB1 N)
  "Set FN to to F[N]: the N'th Fibonacci number.  Set FNSUB1 to to F[N-1].")
(cl-defmethod  mpz-fib2-ui ((FN mpz) (FNSUB1 mpz) (N integer))
  "Set FN to to F[N]: the N'th Fibonacci number.  Set FNSUB1 to to F[N-1]."
  (cl-assert (mmux-gmp-non-negative-p N))
  (mmux-gmp-c-mpz-fib2-ui (mpz-obj FN) (mpz-obj FNSUB1) N))

;; void mpz_lucnum_ui (mpz_t LN, unsigned long int N)
(cl-defgeneric mpz-lucnum-ui (LN N)
  "Set LN to to L[N]: the N'th Lucas number.")
(cl-defmethod  mpz-lucnum-ui ((LN mpz) (N integer))
  "Set LN to to L[N]: the N'th Lucas number."
  (cl-assert (mmux-gmp-non-negative-p N))
  (mmux-gmp-c-mpz-lucnum-ui (mpz-obj LN) N))

;; void mpz_lucnum2_ui (mpz_t LN, mpz_t LNSUB1, unsigned long int N)
(cl-defgeneric mpz-lucnum2-ui (LN LNSUB1 N)
  "Set LN to to L[N]: the N'th Lucas number.  Set LNSUB1 to to L[N-1].")
(cl-defmethod  mpz-lucnum2-ui ((LN mpz) (LNSUB1 mpz) (N integer))
  "Set LN to to L[N]: the N'th Lucas number.  Set LNSUB1 to to L[N-1]."
  (cl-assert (mmux-gmp-non-negative-p N))
  (mmux-gmp-c-mpz-lucnum2-ui (mpz-obj LN) (mpz-obj LNSUB1) N))


;;;; integer number functions: comparison functions

;; int mpz_cmp (const mpz_t OP1, const mpz_t OP2)
(cl-defgeneric mpz-cmp (op1 op2)
  "Compare OP1 and OP2.")
(cl-defmethod  mpz-cmp ((op1 mpz) (op2 mpz))
  "Compare OP1 and OP2."
  (mmux-gmp-c-mpz-cmp (mpz-obj op1) (mpz-obj op2)))

;; int mpz_cmp_d (const mpz_t OP1, double OP2)
(cl-defgeneric mpz-cmp-d (op1 op2)
  "Compare OP1 and OP2.")
(cl-defmethod  mpz-cmp-d ((op1 mpz) (op2 float))
  "Compare OP1 and OP2."
  (mmux-gmp-c-mpz-cmp-d (mpz-obj op1) op2))

;; int mpz_cmp_si (const mpz_t OP1, signed long int OP2)
(cl-defgeneric mpz-cmp-si (op1 op2)
  "Compare OP1 and OP2.")
(cl-defmethod  mpz-cmp-si ((op1 mpz) (op2 integer))
  "Compare OP1 and OP2."
  (mmux-gmp-c-mpz-cmp-si (mpz-obj op1) op2))

;; int mpz_cmp_ui (const mpz_t OP1, unsigned long int OP2)
(cl-defgeneric mpz-cmp-ui (op1 op2)
  "Compare OP1 and OP2.")
(cl-defmethod  mpz-cmp-ui ((op1 mpz) (op2 integer))
  "Compare OP1 and OP2."
  (cl-assert (<= 0 op2))
  (mmux-gmp-c-mpz-cmp-ui (mpz-obj op1) op2))

;;; --------------------------------------------------------------------

;; int mpz_cmpabs (const mpz_t OP1, const mpz_t OP2)
(cl-defgeneric mpz-cmpabs (op1 op2)
  "Compare the absolute values of OP1 and OP2.")
(cl-defmethod  mpz-cmpabs ((op1 mpz) (op2 mpz))
  "Compare the absolute values of OP1 and OP2."
  (mmux-gmp-c-mpz-cmpabs (mpz-obj op1) (mpz-obj op2)))

;; int mpz_cmpabs_d (const mpz_t OP1, double OP2)
(cl-defgeneric mpz-cmpabs-d (op1 op2)
  "Compare the absolute values of OP1 and OP2.")
(cl-defmethod  mpz-cmpabs-d ((op1 mpz) (op2 float))
  "Compare the absolute values of OP1 and OP2."
  (mmux-gmp-c-mpz-cmpabs-d (mpz-obj op1) op2))

;; int mpz_cmpabs_ui (const mpz_t OP1, unsigned long int OP2)
(cl-defgeneric mpz-cmpabs-ui (op1 op2)
  "Compare the absolute values of OP1 and OP2.")
(cl-defmethod  mpz-cmpabs-ui ((op1 mpz) (op2 integer))
  "Compare the absolute values of OP1 and OP2."
  (cl-assert (<= 0 op2))
  (mmux-gmp-c-mpz-cmpabs-ui (mpz-obj op1) op2))

;;; --------------------------------------------------------------------

;; int mpz_sgn (const mpz_t OP)
(cl-defgeneric mpz-sgn (op)
  "Return an integer representing the sign of the operand.")
(cl-defmethod  mpz-sgn ((op mpz))
  "Return an integer representing the sign of the operand."
  (mmux-gmp-c-mpz-sgn (mpz-obj op)))

;;; --------------------------------------------------------------------

(cl-defgeneric mpz-zero-p (op)
  "Return true if OP is zero; otherwise return false.")
(cl-defmethod  mpz-zero-p ((op mpz))
  "Return true if OP is zero; otherwise return false."
  (= 0 (mpz-cmp-si op 0)))

(cl-defgeneric mpz-non-zero-p (op)
  "Return true if OP is non-zero; otherwise return false.")
(cl-defmethod  mpz-non-zero-p ((op mpz))
  "Return true if OP is non-zero; otherwise return false."
  (not (= 0 (mpz-cmp-si op 0))))

;;; --------------------------------------------------------------------

(cl-defgeneric mpz-positive-p (op)
  "Return true if OP is strictly positive; otherwise return false.")
(cl-defmethod  mpz-positive-p ((op mpz))
  "Return true if OP is strictly positive; otherwise return false."
  (= +1 (mpz-cmp-si op 0)))

(cl-defgeneric mpz-negative-p (op)
  "Return true if OP is strictly negative; otherwise return false.")
(cl-defmethod  mpz-negative-p ((op mpz))
  "Return true if OP is strictly negative; otherwise return false."
  (= -1 (mpz-cmp-si op 0)))

;;; --------------------------------------------------------------------

(cl-defgeneric mpz-non-positive-p (op)
  "Return true if OP is non-positive; otherwise return false.")
(cl-defmethod  mpz-non-positive-p ((op mpz))
  "Return true if OP is non-positive; otherwise return false."
  (>= 0 (mpz-cmp-si op 0)))

(cl-defgeneric mpz-non-negative-p (op)
  "Return true if OP is non-negative; otherwise return false.")
(cl-defmethod  mpz-non-negative-p ((op mpz))
  "Return true if OP is non-negative; otherwise return false."
  (<= 0 (mpz-cmp-si op 0)))


;;;; integer number functions: logical and bit manipulation functions

;; void mpz_and (mpz_t ROP, const mpz_t OP1, const mpz_t OP2)
(cl-defgeneric mpz-and (rop op1 op2)
  "Set ROP to OP1 bitwise-and OP2.")
(cl-defmethod mpz-and ((rop mpz) (op1 mpz) (op2 mpz))
  "Set ROP to OP1 bitwise-and OP2."
  (mmux-gmp-c-mpz-and (mpz-obj rop) (mpz-obj op1) (mpz-obj op2)))

;; void mpz_ior (mpz_t ROP, const mpz_t OP1, const mpz_t OP2)
(cl-defgeneric mpz-ior (rop op1 op2)
  "Set ROP to OP1 bitwise inclusive-or OP2.")
(cl-defmethod mpz-ior ((rop mpz) (op1 mpz) (op2 mpz))
  "Set ROP to OP1 bitwise inclusive-or OP2."
  (mmux-gmp-c-mpz-ior (mpz-obj rop) (mpz-obj op1) (mpz-obj op2)))

;; void mpz_xor (mpz_t ROP, const mpz_t OP1, const mpz_t OP2)
(cl-defgeneric mpz-xor (rop op1 op2)
  "Set ROP to OP1 bitwise exclusive-or OP2.")
(cl-defmethod mpz-xor ((rop mpz) (op1 mpz) (op2 mpz))
  "Set ROP to OP1 bitwise exclusive-or OP2."
  (mmux-gmp-c-mpz-xor (mpz-obj rop) (mpz-obj op1) (mpz-obj op2)))

;; void mpz_com (mpz_t ROP, const mpz_t OP)
(cl-defgeneric mpz-com (rop op)
  "Set ROP to the one's complement of OP.")
(cl-defmethod mpz-com ((rop mpz) (op mpz))
  "Set ROP to the one's complement of OP."
  (mmux-gmp-c-mpz-com (mpz-obj rop) (mpz-obj op)))

;; mp_bitcnt_t mpz_popcount (const mpz_t OP)
(cl-defgeneric mpz-popcount (op)
  "Return the population count of OP.")
(cl-defmethod mpz-popcount ((op mpz))
  "Return the population count of OP."
  (mmux-gmp-c-mpz-popcount (mpz-obj op)))

;; mp_bitcnt_t mpz_hamdist (const mpz_t OP1, const mpz_t OP2)
(cl-defgeneric mpz-hamdist (op1 op2)
  "Return the hamming distance between the two operands.")
(cl-defmethod mpz-hamdist ((op1 mpz) (op2 mpz))
  "Return the hamming distance between the two operands."
  (mmux-gmp-c-mpz-hamdist (mpz-obj op1) (mpz-obj op2)))

;; mp_bitcnt_t mpz_scan0 (const mpz_t OP, mp_bitcnt_t STARTING_BIT)
(cl-defgeneric mpz-scan0 (op starting-bit)
  "Scan OP for the first 0 bit.")
(cl-defmethod mpz-scan0 ((op mpz) (starting-bit integer))
  "Scan OP for the first 0 bit."
  (mmux-gmp-c-mpz-scan0 (mpz-obj op) starting-bit))

;; mp_bitcnt_t mpz_scan1 (const mpz_t OP, mp_bitcnt_t STARTING_BIT)
(cl-defgeneric mpz-scan1 (op starting-bit)
  "Scan OP for the first 1 bit.")
(cl-defmethod mpz-scan1 ((op mpz) (starting-bit integer))
  "Scan OP for the first 1 bit."
  (mmux-gmp-c-mpz-scan1 (mpz-obj op) starting-bit))

;; void mpz_setbit (mpz_t ROP, mp_bitcnt_t BIT_INDEX)
(cl-defgeneric mpz-setbit (rop bit-index)
  "Set bit BIT_INDEX in ROP.")
(cl-defmethod mpz-setbit ((rop mpz) (bit-index integer))
  "Set bit BIT_INDEX in ROP."
  (mmux-gmp-c-mpz-setbit (mpz-obj rop) bit-index))

;; void mpz_clrbit (mpz_t ROP, mp_bitcnt_t BIT_INDEX)
(cl-defgeneric mpz-clrbit (rop bit-index)
  "Clear bit BIT_INDEX in ROP.")
(cl-defmethod mpz-clrbit ((rop mpz) (bit-index integer))
  "Clear bit BIT_INDEX in ROP."
  (mmux-gmp-c-mpz-clrbit (mpz-obj rop) bit-index))

;; void mpz_combit (mpz_t ROP, mp_bitcnt_t BIT_INDEX)
(cl-defgeneric mpz-combit (rop bit-index)
  "Complement bit BIT_INDEX in ROP.")
(cl-defmethod mpz-combit ((rop mpz) (bit-index integer))
  "Complement bit BIT_INDEX in ROP."
  (mmux-gmp-c-mpz-combit (mpz-obj rop) bit-index))

;; int mpz_tstbit (const mpz_t OP, mp_bitcnt_t BIT_INDEX)
(cl-defgeneric mpz-tstbit (op bit-index)
  "Test bit BIT_INDEX in OP and return 0 or 1 accordingly.")
(cl-defmethod mpz-tstbit ((op mpz) (bit-index integer))
  "Test bit BIT_INDEX in OP and return 0 or 1 accordingly."
  (mmux-gmp-c-mpz-tstbit (mpz-obj op) bit-index))


;;;; integer number functions: random number functions

;; void mpz_urandomb (mpz_t ROP, gmp_randstate_t STATE, mp_bitcnt_t N)
(cl-defgeneric mpz-urandomb (rop state N)
  "Generate a uniformly distributed random integer in the range 0 to 2^N-1, inclusive.")
(cl-defmethod  mpz-urandomb ((rop mpz) (state gmp-randstate) (N integer))
  "Generate a uniformly distributed random integer in the range 0 to 2^N-1, inclusive."
  (mmux-gmp-c-mpz-urandomb (mpz-obj rop) (gmp-randstate-obj state) N))

;; void mpz_urandomm (mpz_t ROP, gmp_randstate_t STATE, const mpz_t N)
(cl-defgeneric mpz-urandomm (rop state N)
  "Generate a uniform random integer in the range 0 to N-1, inclusive.")
(cl-defmethod  mpz-urandomm ((rop mpz) (state gmp-randstate) (N mpz))
  "Generate a uniform random integer in the range 0 to N-1, inclusive."
  (mmux-gmp-c-mpz-urandomm (mpz-obj rop) (gmp-randstate-obj state) (mpz-obj N)))

;; void mpz_rrandomb (mpz_t ROP, gmp_randstate_t STATE, mp_bitcnt_t N)
(cl-defgeneric mpz-rrandomb (rop state N)
  "Generate a random integer with long strings of zeros and ones in the binary representation. ")
(cl-defmethod  mpz-rrandomb ((rop mpz) (state gmp-randstate) (N integer))
  "Generate a random integer with long strings of zeros and ones in the binary representation. "
  (mmux-gmp-c-mpz-rrandomb (mpz-obj rop) (gmp-randstate-obj state) N))

;; void mpz_random (mpz_t ROP, mp_size_t MAX_SIZE)
(cl-defgeneric mpz-random (rop max-size)
  "Generate a random integer of at most MAX-SIZE limbs.")
(cl-defmethod  mpz-random ((rop mpz) (max-size integer))
  "Generate a random integer of at most MAX-SIZE limbs."
  (mmux-gmp-c-mpz-random (mpz-obj rop) max-size))

;; void mpz_random2 (mpz_t ROP, mp_size_t MAX_SIZE)
(cl-defgeneric mpz-random2 (rop max-size)
  "Generate a random integer of at most MAX-SIZE limbs, with long strings of zeros and ones in the binary representation.")
(cl-defmethod  mpz-random2 ((rop mpz) (max-size integer))
  "Generate a random integer of at most MAX-SIZE limbs, with long strings of zeros and ones in the binary representation."
  (mmux-gmp-c-mpz-random2 (mpz-obj rop) max-size))


;;;; integer number functions: miscellaneous

;; int mpz_fits_ulong_p (const mpz_t OP)
(cl-defgeneric mpz-fits-ulong-p (op))
(cl-defmethod mpz-fits-ulong-p ((op mpz))
  "Return true if the operand fits an `unsigned long int'; otherwise return false."
  (mmux-gmp-c-mpz-fits-ulong-p (mpz-obj op)))

;; int mpz_fits_slong_p (const mpz_t OP)
(cl-defgeneric mpz-fits-slong-p (op))
(cl-defmethod mpz-fits-slong-p ((op mpz))
  "Return true if the operand fits a `signed long int'; otherwise return false."
  (mmux-gmp-c-mpz-fits-slong-p (mpz-obj op)))

;; int mpz_fits_uint_p (const mpz_t OP)
(cl-defgeneric mpz-fits-uint-p (op))
(cl-defmethod mpz-fits-uint-p ((op mpz))
  "Return true if the operand fits an `unsigned int'; otherwise return false."
  (mmux-gmp-c-mpz-fits-uint-p (mpz-obj op)))

;; int mpz_fits_sint_p (const mpz_t OP)
(cl-defgeneric mpz-fits-sint-p (op))
(cl-defmethod mpz-fits-sint-p ((op mpz))
  "Return true if the operand fits n `signed int'; otherwise return false."
  (mmux-gmp-c-mpz-fits-sint-p (mpz-obj op)))

;; int mpz_fits_ushort_p (const mpz_t OP)
(cl-defgeneric mpz-fits-ushort-p (op))
(cl-defmethod mpz-fits-ushort-p ((op mpz))
  "Return true if the operand fits an `unsigned short int'; otherwise return false."
  (mmux-gmp-c-mpz-fits-ushort-p (mpz-obj op)))

;; int mpz_fits_sshort_p (const mpz_t OP)
(cl-defgeneric mpz-fits-sshort-p (op))
(cl-defmethod mpz-fits-sshort-p ((op mpz))
  "Return true if the operand fits a `signed short int'; otherwise return false."
  (mmux-gmp-c-mpz-fits-sshort-p (mpz-obj op)))

;;; --------------------------------------------------------------------

;; int mpz_odd_p (const mpz_t OP)
(cl-defgeneric mpz-odd-p (op))
(cl-defmethod mpz-odd-p ((op mpz))
  "Return true if the operand is odd; otherwise return false."
  (mmux-gmp-c-mpz-odd-p (mpz-obj op)))

;; int mpz_even_p (const mpz_t OP)
(cl-defgeneric mpz-even-p (op))
(cl-defmethod mpz-even-p ((op mpz))
  "Return true if the operand is even; otherwise return false."
  (mmux-gmp-c-mpz-even-p (mpz-obj op)))

;;; --------------------------------------------------------------------

;; size_t mpz_sizeinbase (const mpz_t OP, int BASE)
(cl-defgeneric mpz-sizeinbase (op base))
(cl-defmethod mpz-sizeinbase ((op mpz) (base integer))
  "Return the size of OP measured in number of digits in the given BASE.

The argument BASE can vary from 2 to 62."
  (cl-assert (<= 2 base 62))
  (mmux-gmp-c-mpz-sizeinbase (mpz-obj op) base))


;;;; rational number functions: assignment

(cl-defgeneric mpq-set (rop op)
  "Assign the value of an `mpq' object to another `mpq' object.")
(cl-defmethod  mpq-set ((rop mpq) (op mpq))
  "Assign the value of an `mpq' object to another `mpq' object."
  (mmux-gmp-c-mpq-set (mpq-obj rop) (mpq-obj op)))

(cl-defgeneric mpq-set-si (rop op1 op2)
  "Assign the values of two exact signed integer objects to an `mpq' object.")
(cl-defmethod  mpq-set-si ((rop mpq) (op1 integer) (op2 integer))
  "Assign the values of two exact signed integer objects to an `mpq' object."
  (cl-assert (not (zerop op2)))
  (mmux-gmp-c-mpq-set-si (mpq-obj rop) op1 op2))

(cl-defgeneric mpq-set-ui (rop op1 op2)
  "Assign the values of two exact unsigned integer objects to an `mpq' object.")
(cl-defmethod  mpq-set-ui ((rop mpq) (op1 integer) (op2 integer))
  "Assign the values of two exact unsigned integer objects to an `mpq' object."
  (cl-assert (<= 0 op1))
  (cl-assert (<  0 op2))
  (mmux-gmp-c-mpq-set-ui (mpq-obj rop) op1 op2))

(cl-defgeneric mpq-set-d (rop op)
  "Assign the value of a floating-point object to an `mpq' object.")
(cl-defmethod  mpq-set-d ((rop mpq) (op float))
  "Assign the value of a floating-point object to an `mpq' object."
  (mmux-gmp-c-mpq-set-d (mpq-obj rop) op))

(cl-defgeneric mpq-set-z (rop op)
  "Assign the value of an `mpz' object to an `mpq' object.")
(cl-defmethod  mpq-set-z ((rop mpq) (op mpz))
  "Assign the value of an `mpz' object to an `mpq' object."
  (mmux-gmp-c-mpq-set-z (mpq-obj rop) (mpz-obj op)))

(cl-defgeneric mpq-set-f (rop op)
  "Assign the value of an `mpf' object to an `mpq' object.")
(cl-defmethod  mpq-set-f ((rop mpq) (op mpf))
  "Assign the value of an `mpf' object to an `mpq' object."
  (mmux-gmp-c-mpq-set-f (mpq-obj rop) (mpf-obj op)))

(cl-defgeneric mpq-set-str (rop str base)
  "Assign the value of a string object to an `mpq' object.")
(cl-defmethod  mpq-set-str ((rop mpq) (str string) (base integer))
  "Assign the value of a string object to an `mpq' object."
  (cl-assert (or (zerop base)
		 (<= 2 base 62)))
  (mmux-gmp-c-mpq-set-str (mpq-obj rop) str base))

(cl-defgeneric mpq-swap (op1 op2)
  "Swap the values of two `mpq' objects.")
(cl-defmethod  mpq-swap ((op1 mpq) (op2 mpq))
  "Swap the values of two `mpq' objects."
  (mmux-gmp-c-mpq-swap (mpq-obj op1) (mpq-obj op2)))


;;;; rational number functions: conversion

(cl-defgeneric mpq-get-d (op)
  "Convert an object of type `mpq' to a floating-point number.")
(cl-defmethod  mpq-get-d ((op mpq))
  "Convert an object of type `mpq' to a floating-point number."
  (mmux-gmp-c-mpq-get-d (mpq-obj op)))

(cl-defgeneric mpq-get-str (base op)
  "Convert an object of type `mpq' to a string.")
(cl-defmethod  mpq-get-str ((base integer) (op mpq))
  "Convert an object of type `mpq' to a string."
  (cl-assert (or (<= +2 base +36)
		 (>= -2 base -36)))
  (mmux-gmp-c-mpq-get-str base (mpq-obj op)))


;;;; rational number functions: arithmetic

(cl-defgeneric mpq-add (rop op1 op2)
  "Add two `mpq' objects.")
(cl-defmethod  mpq-add ((rop mpq) (op1 mpq) (op2 mpq))
  "Add two `mpq' objects."
  (mmux-gmp-c-mpq-add (mpq-obj rop) (mpq-obj op1) (mpq-obj op2)))


;;;; floating-point number functions: initialisation

(cl-defgeneric mpf-set-default-prec (prec)
  "Set the default precision of `mpf' objects.")
(cl-defmethod  mpf-set-default-prec ((prec integer))
  "Set the default precision of `mpf' objects."
  (cl-assert (< 0 prec))
  (mmux-gmp-c-mpf-set-default-prec prec))

(cl-defgeneric mpf-get-default-prec ()
  "Get the default precision of `mpf' objects.")
(cl-defmethod  mpf-get-default-prec ()
  "Get the default precision of `mpf' objects."
  (mmux-gmp-c-mpf-get-default-prec))

(cl-defgeneric mpf-set-prec (rop prec)
  "Set the default precision of an `mpf' object.")
(cl-defmethod  mpf-set-prec ((rop mpf) (prec integer))
  "Set the default precision of an `mpf' object."
  (cl-assert (< 0 prec))
  (mmux-gmp-c-mpf-set-prec (mpf-obj rop) prec))

(cl-defgeneric mpf-get-prec (rop)
  "Get the precision of an `mpf' object.")
(cl-defmethod  mpf-get-prec ((rop mpf))
  "Get the precision of an `mpf' object."
  (mmux-gmp-c-mpf-get-prec (mpf-obj rop)))


;;;; floating-point number functions: assignment

(cl-defgeneric mpf-set (rop op)
  "Assign the value of an `mpf' object to another `mpf' object.")
(cl-defmethod  mpf-set ((rop mpf) (op mpf))
  "Assign the value of an `mpf' object to another `mpf' object."
  (mmux-gmp-c-mpf-set (mpf-obj rop) (mpf-obj op)))

(cl-defgeneric mpf-set-si (rop op)
  "Assign the value of an exact integer object to an `mpf' object.")
(cl-defmethod  mpf-set-si ((rop mpf) (op integer))
  "Assign the value of an exact integer object to an `mpf' object."
  (mmux-gmp-c-mpf-set-si (mpf-obj rop) op))

(cl-defgeneric mpf-set-ui (rop op)
  "Assign the value of an exact integer object to an `mpf' object.")
(cl-defmethod  mpf-set-ui ((rop mpf) (op integer))
  "Assign the value of an exact integer object to an `mpf' object."
  (cl-assert (<= 0 op))
  (mmux-gmp-c-mpf-set-ui (mpf-obj rop) op))

(cl-defgeneric mpf-set-d (rop op)
  "Assign the value of a floating-point object to an `mpf' object.")
(cl-defmethod  mpf-set-d ((rop mpf) (op float))
  "Assign the value of a floating-point object to an `mpf' object."
  (mmux-gmp-c-mpf-set-d (mpf-obj rop) op))

(cl-defgeneric mpf-set-z (rop op)
  "Assign the value of an `mpz' object to an `mpf' object.")
(cl-defmethod  mpf-set-z ((rop mpf) (op mpz))
  "Assign the value of an `mpz' object to an `mpf' object."
  (mmux-gmp-c-mpf-set-z (mpf-obj rop) (mpz-obj op)))

(cl-defgeneric mpf-set-q (rop op)
  "Assign the value of an `mpq' object to an `mpf' object.")
(cl-defmethod  mpf-set-q ((rop mpf) (op mpq))
  "Assign the value of an `mpq' object to an `mpf' object."
  (mmux-gmp-c-mpf-set-q (mpf-obj rop) (mpq-obj op)))

(cl-defgeneric mpf-set-str (rop str base)
  "Assign the value of a string object to an `mpf' object.")
(cl-defmethod  mpf-set-str ((rop mpf) (str string) (base integer))
  "Assign the value of a string object to an `mpf' object."
  (cl-assert (or (<= +2 base +62)
		 (>= -2 base -62)))
  (mmux-gmp-c-mpf-set-str (mpf-obj rop) str base))

(cl-defgeneric mpf-swap (op1 op2)
  "Swap the values of two `mpf' objects.")
(cl-defmethod  mpf-swap ((op1 mpf) (op2 mpf))
  "Swap the values of two `mpf' objects."
  (mmux-gmp-c-mpf-swap (mpf-obj op1) (mpf-obj op2)))


;;;; floating-point number functions: conversion

(cl-defgeneric mpf-get-ui (op)
  "Convert an object of type `mpf' to an unsigned exact integer number.")
(cl-defmethod  mpf-get-ui ((op mpf))
  "Convert an object of type `mpf' to an unsigned exact integer number."
  (mmux-gmp-c-mpf-get-ui (mpf-obj op)))

(cl-defgeneric mpf-get-si (op)
  "Convert an object of type `mpf' to a signed exact integer number.")
(cl-defmethod  mpf-get-si ((op mpf))
  "Convert an object of type `mpf' to a signed exact integer number."
  (mmux-gmp-c-mpf-get-si (mpf-obj op)))

(cl-defgeneric mpf-get-d (op)
  "Convert an object of type `mpf' to a floating-point number.")
(cl-defmethod  mpf-get-d ((op mpf))
  "Convert an object of type `mpf' to a floating-point number."
  (mmux-gmp-c-mpf-get-d (mpf-obj op)))

(cl-defgeneric mpf-get-d-2exp (op)
  "Convert an object of type `mpf' to a floating-point number, returning the exponent separately.")
(cl-defmethod  mpf-get-d-2exp ((op mpf))
  "Convert an object of type `mpf' to a floating-point number, returning the exponent separately."
  (mmux-gmp-c-mpf-get-d-2exp (mpf-obj op)))

(cl-defgeneric mpf-get-str (base ndigits op)
  "Convert an object of type `mpf' to a string.")
(cl-defmethod  mpf-get-str ((base integer) (ndigits integer) (op mpf))
  "Convert an object of type `mpf' to a string."
  (cl-assert (or (<= +2 base +62)
		 (>= -2 base -36)))
  (cl-assert (<= 0 ndigits))
  (mmux-gmp-c-mpf-get-str base ndigits (mpf-obj op)))

(cl-defgeneric mpf-get-str* (base ndigits op)
  "Convert an object of type `mpf' to a formatted string.")
(cl-defmethod  mpf-get-str* ((base integer) (ndigits integer) (op mpf))
  "Convert an object of type `mpf' to a formatted string."
  (let* ((rv		(mpf-get-str base ndigits op))
	 (mantissa.str	(car rv))
	 (exponent	(cdr rv)))
    (if (string= "" mantissa.str)
	"0.0"
      (let ((negative?	(if (string= "-" (substring mantissa.str 0 1)) t nil)))
	(format "%s0.%se%s%d"
		(if negative? "-" "+")
		(if negative? (substring mantissa.str 1) mantissa.str)
		(cond ((< 0 exponent)	"+")
		      ((> 0 exponent)	"-")
		      (t		""))
		(abs exponent))))))


;;;; floating-point number functions: arithmetic

(cl-defgeneric mpf-add (rop op1 op2)
  "Add two `mpf' objects.")
(cl-defmethod  mpf-add ((rop mpf) (op1 mpf) (op2 mpf))
  "Add two `mpf' objects."
  (mmux-gmp-c-mpf-add (mpf-obj rop) (mpf-obj op1) (mpf-obj op2)))


;;;; random number functions: state initialisation

;; void gmp_randinit_default (gmp_randstate_t STATE)
(cl-defgeneric gmp-randinit-default (state)
  "Initialize STATE with a default algorithm.")
(cl-defmethod  gmp-randinit-default ((state gmp-randstate))
  "Initialize STATE with a default algorithm."
  (mmux-gmp-c-gmp-randinit-default (gmp-randstate-obj state)))

;; void gmp_randinit_mt (gmp_randstate_t STATE)
(cl-defgeneric gmp-randinit-mt (state)
  "Initialize STATE for a Mersenne Twister algorithm.")
(cl-defmethod  gmp-randinit-mt ((state gmp-randstate))
  "Initialize STATE for a Mersenne Twister algorithm."
  (mmux-gmp-c-gmp-randinit-mt (gmp-randstate-obj state)))

;; void gmp_randinit_lc_2exp (gmp_randstate_t STATE, const mpz_t A, unsigned long C, mp_bitcnt_t M2EXP)
(cl-defgeneric gmp-randinit-lc-2exp (state A C M2EXP)
  "Initialize STATE with a linear congruential algorithm.")
(cl-defmethod  gmp-randinit-lc-2exp ((state gmp-randstate) (A mpz) (C integer) (M2EXP integer))
  "Initialize STATE with a linear congruential algorithm."
  (mmux-gmp-c-gmp-randinit-lc-2exp (gmp-randstate-obj state) (mpz-obj A) C M2EXP))

;; int gmp-randinit-lc-2exp_size (gmp_randstate_t STATE, mp_bitcnt_t SIZE)
(cl-defgeneric gmp-randinit-lc-2exp-size (state size)
  "Initialize STATE with a linear congruential algorithm.")
(cl-defmethod  gmp-randinit-lc-2exp-size ((state gmp-randstate) (size integer))
  "Initialize STATE with a linear congruential algorithm."
  (mmux-gmp-c-gmp-randinit-lc-2exp-size (gmp-randstate-obj state) size))

;; void gmp-randinit-set (gmp_randstate_t ROP, gmp_randstate_t OP)
(cl-defgeneric gmp-randinit-set (rop op)
  "Initialize ROP with a copy of the algorithm and state from OP.")
(cl-defmethod  gmp-randinit-set ((rop gmp-randstate) (op gmp-randstate))
  "Initialize ROP with a copy of the algorithm and state from OP."
  (mmux-gmp-c-gmp-randinit-set (gmp-randstate-obj rop) (gmp-randstate-obj op)))


;;;; random number functions: state seeding

;; void gmp_randseed (gmp_randstate_t STATE, const mpz_t SEED)
(cl-defgeneric gmp-randseed (state seed)
  "Set an initial seed value into STATE.")
(cl-defmethod  gmp-randseed ((state gmp-randstate) (seed mpz))
  "Set an initial seed value into STATE."
  (mmux-gmp-c-gmp-randseed (gmp-randstate-obj state) (mpz-obj seed)))

;; void gmp_randseed_ui (gmp_randstate_t STATE, unsigned long int SEED)
(cl-defgeneric gmp-randseed-ui (state seed)
  "Set an initial seed value into STATE.")
(cl-defmethod  gmp-randseed-ui ((state gmp-randstate) (seed integer))
  "Set an initial seed value into STATE."
  (mmux-gmp-c-gmp-randseed-ui (gmp-randstate-obj state) seed))


;;;; random number functions: number generation

;; unsigned long gmp_urandomb_ui (gmp_randstate_t STATE, unsigned long N)
(cl-defgeneric gmp-urandomb-ui (state N)
  "Return a uniformly distributed random number of N bits, in the range 0 to 2^N-1 inclusive.")
(cl-defmethod  gmp-urandomb-ui ((state gmp-randstate) (N integer))
  "Return a uniformly distributed random number of N bits, in the range 0 to 2^N-1 inclusive."
  (mmux-gmp-c-gmp-urandomb-ui (gmp-randstate-obj state) N))

;; unsigned long gmp_urandomm_ui (gmp_randstate_t STATE, unsigned long N)
(cl-defgeneric gmp-urandomm-ui (state N)
  "Return a uniformly distributed random number in the range 0 to N-1, inclusive.")
(cl-defmethod  gmp-urandomm-ui ((state gmp-randstate) (N integer))
  "Return a uniformly distributed random number in the range 0 to N-1, inclusive."
  (mmux-gmp-c-gmp-urandomm-ui (gmp-randstate-obj state) N))


;;;; done

(provide 'mmux-emacs-gmp)

;;; mmux-emacs-gmp.el ends here
