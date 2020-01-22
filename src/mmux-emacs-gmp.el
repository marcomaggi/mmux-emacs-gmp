;;; mmux-emacs-gmp.el --- gmp module

;; Copyright (C) 2020 Marco Maggi

;; Author: Marco Maggi <mrc.mgg@gmail.com>
;; Created: Jan 15, 2020
;; Time-stamp: <2020-01-22 07:45:34 marco>
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


;;;; user-ptr object wrappers

(cl-defstruct (mpz (:constructor make-mpz))
  obj)

(defun mpz (&optional INIT)
  "Build and return a new, uninitialised, `mpz' object."
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

;;; --------------------------------------------------------------------

(cl-defstruct (mpq (:constructor make-mpq))
  obj)

(defun mpq (&optional INIT DENOMINATOR-INIT)
  "Build and return a new, uninitialised, `mpq' object."
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

;;; --------------------------------------------------------------------

(cl-defstruct (mpf (:constructor make-mpf))
  obj)

(defun mpf (&optional INIT)
  "Build and return a new, uninitialised, `mpf' object."
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

(defun mpz-add-ui (rop op1 op2)
  "Add an `mpz' object to an unsigned exact integer number."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p op1))
  (cl-assert (integerp op2))
  (mmux-gmp-c-mpz-add-ui (mpz-obj rop) (mpz-obj op1) op2))

;;; --------------------------------------------------------------------

(defun mpz-sub (rop op1 op2)
  "Subtract two `mpz' objects."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p op1))
  (cl-assert (mpz-p op2))
  (mmux-gmp-c-mpz-sub (mpz-obj rop) (mpz-obj op1) (mpz-obj op2)))

(defun mpz-sub-ui (rop op1 op2)
  "Subtract an unsigned exact integer number from an `mpz' object."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p op1))
  (cl-assert (integerp op2))
  (mmux-gmp-c-mpz-sub-ui (mpz-obj rop) (mpz-obj op1) op2))

;;; --------------------------------------------------------------------

(defun mpz-addmul (rop op1 op2)
  "Multiply two `mpz' objects, then add the result to another `mpz' object."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p op1))
  (cl-assert (mpz-p op2))
  (mmux-gmp-c-mpz-addmul (mpz-obj rop) (mpz-obj op1) (mpz-obj op2)))

(defun mpz-addmul-ui (rop op1 op2)
  "Multiply an `mpz' object with an unsigned exact integer number, then add the result to another `mpz' object."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p op1))
  (cl-assert (integerp op2))
  (mmux-gmp-c-mpz-addmul-ui (mpz-obj rop) (mpz-obj op1) op2))

;;; --------------------------------------------------------------------

(defun mpz-submul (rop op1 op2)
  "Multiply two `mpz' objects, then subtract the result from another `mpz' object."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p op1))
  (cl-assert (mpz-p op2))
  (mmux-gmp-c-mpz-submul (mpz-obj rop) (mpz-obj op1) (mpz-obj op2)))

(defun mpz-submul-ui (rop op1 op2)
  "Multiply an `mpz' object with an unsigned exact integer number, then subtract the result from another `mpz' object."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p op1))
  (cl-assert (integerp op2))
  (mmux-gmp-c-mpz-submul-ui (mpz-obj rop) (mpz-obj op1) op2))

;;; --------------------------------------------------------------------

(defun mpz-mul (rop op1 op2)
  "Multiply two `mpz' objects."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p op1))
  (cl-assert (mpz-p op2))
  (mmux-gmp-c-mpz-mul (mpz-obj rop) (mpz-obj op1) (mpz-obj op2)))

(defun mpz-mul-si (rop op1 op2)
  "Multiply an `mpz' object by a signed exact integer number."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p op1))
  (cl-assert (integerp op2))
  (mmux-gmp-c-mpz-mul-si (mpz-obj rop) (mpz-obj op1) op2))

(defun mpz-mul-ui (rop op1 op2)
  "Multiply an `mpz' object by an unsigned exact integer number."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p op1))
  (cl-assert (and (integerp op2)
		  (<= 0 op2)))
  (mmux-gmp-c-mpz-mul-ui (mpz-obj rop) (mpz-obj op1) op2))

;;; --------------------------------------------------------------------

(defun mpz-mul-2exp (rop op bitcnt)
  "Left shift an `mpz' object."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p op))
  (cl-assert (integerp bitcnt))
  (mmux-gmp-c-mpz-mul-2exp (mpz-obj rop) (mpz-obj op) bitcnt))

(defun mpz-neg (rop op)
  "Negate an `mpz' object."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p op))
  (mmux-gmp-c-mpz-neg (mpz-obj rop) (mpz-obj op)))

(defun mpz-abs (rop op)
  "Compute the absolute value of an `mpz' object."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p op))
  (mmux-gmp-c-mpz-abs (mpz-obj rop) (mpz-obj op)))


;;;; integer number functions: conversion

(defun mpz-get-ui (op)
  "Convert an object of type `mpz' to an unsigned exact integer number."
  (cl-assert (mpz-p op))
  (mmux-gmp-c-mpz-get-ui (mpz-obj op)))

(defun mpz-get-si (op)
  "Convert an object of type `mpz' to a signed exact integer number."
  (cl-assert (mpz-p op))
  (mmux-gmp-c-mpz-get-si (mpz-obj op)))

(defun mpz-get-d (op)
  "Convert an object of type `mpz' to a floating-point number."
  (cl-assert (mpz-p op))
  (mmux-gmp-c-mpz-get-d (mpz-obj op)))

(defun mpz-get-d-2exp (op)
  "Convert an object of type `mpz' to a floating-point number, returning the exponent separately."
  (cl-assert (mpz-p op))
  (mmux-gmp-c-mpz-get-d-2exp (mpz-obj op)))

(defun mpz-get-str (base op)
  "Convert an object of type `mpz' to a string."
  (cl-assert (and (integerp base)
		  (or (<= +2 base +36)
		      (>= -2 base -36))))
  (cl-assert (mpz-p op))
  (mmux-gmp-c-mpz-get-str base (mpz-obj op)))


;;;; integer number functions: division

;;; void mpz_cdiv_q (mpz_t Q, const mpz_t N, const mpz_t D)
(defun mpz-cdiv-q (Q N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p Q))
  (cl-assert (mpz-p N))
  (cl-assert (mpz-p D))
  (mmux-gmp-c-cdiv-q (mpz-obj Q) (mpz-obj N) (mpz-obj D)))

;;; void mpz_cdiv_r (mpz_t R, const mpz_t N, const mpz_t D) */
(defun mpz-cdiv-r (R N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p R))
  (cl-assert (mpz-p N))
  (cl-assert (mpz-p D))
  (mmux-gmp-c-cdiv-r (mpz-obj R) (mpz-obj N) (mpz-obj D)))

;;; void mpz_cdiv_qr (mpz_t Q, mpz_t R, const mpz_t N, const mpz_t D) */
(defun mpz-cdiv-qr (Q R N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p Q))
  (cl-assert (mpz-p R))
  (cl-assert (mpz-p N))
  (cl-assert (mpz-p D))
  (mmux-gmp-c-cdiv-qr (mpz-obj Q) (mpz-obj R) (mpz-obj N) (mpz-obj D)))

;;; unsigned long int mpz_cdiv_q_ui (mpz_t Q, const mpz_t N, unsigned long int D) */
(defun mpz-cdiv-q-ui (Q N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p Q))
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-cdiv-q-ui (mpz-obj Q) (mpz-obj N) D))

;;; unsigned long int mpz_cdiv_r_ui (mpz_t R, const mpz_t N, unsigned long int D) */
(defun mpz-cdiv-r-ui (R N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p R))
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-cdiv-r-ui (mpz-obj R) (mpz-obj N) D))

;;; unsigned long int mpz_cdiv_qr_ui (mpz_t Q, mpz_t R, const mpz_t N, unsigned long int D) */
(defun mpz-cdiv-qr-ui (Q R N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p Q))
  (cl-assert (mpz-p R))
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-cdiv-qr-ui (mpz-obj Q) (mpz-obj R) (mpz-obj N) D))

;;; unsigned long int mpz_cdiv_ui (const mpz_t N, unsigned long int D) */
(defun mpz-cdiv-ui (N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-cdiv-ui (mpz-obj N) D))

;;; void mpz_cdiv_q_2exp (mpz_t Q, const mpz_t N, mp_bitcnt_t B) */
(defun mpz-cdiv-q-2exp (Q N B)
  "Divide N by D, forming a quotient Q and/or remainder R; compute D as 2^B."
  (cl-assert (mpz-p Q))
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-bitcnt-p B))
  (mmux-gmp-c-cdiv-q-2exp (mpz-obj Q) (mpz-obj N) B))

;;; void mpz_cdiv_r_2exp (mpz_t R, const mpz_t N, mp_bitcnt_t B) */
(defun mpz-cdiv-r-2exp (R N B)
  "Divide N by D, forming a quotient Q and/or remainder R; compute D as 2^B."
  (cl-assert (mpz-p R))
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-bitcnt-p B))
  (mmux-gmp-c-cdiv-r-2exp (mpz-obj R) (mpz-obj N) B))

;;; --------------------------------------------------------------------

;;; void mpz_fdiv_q (mpz_t Q, const mpz_t N, const mpz_t D) */
(defun mpz-fdiv-q (Q N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p Q))
  (cl-assert (mpz-p N))
  (cl-assert (mpz-p D))
  (mmux-gmp-c-fdiv-q (mpz-obj Q) (mpz-obj N) (mpz-obj D)))

;;; void mpz_fdiv_r (mpz_t R, const mpz_t N, const mpz_t D) */
(defun mpz-fdiv-r (R N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p R))
  (cl-assert (mpz-p N))
  (cl-assert (mpz-p D))
  (mmux-gmp-c-fdiv-r (mpz-obj R) (mpz-obj N) (mpz-obj D)))

;;; void mpz_fdiv_qr (mpz_t Q, mpz_t R, const mpz_t N, const mpz_t D) */
(defun mpz-fdiv-qr (Q R N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p Q))
  (cl-assert (mpz-p R))
  (cl-assert (mpz-p N))
  (cl-assert (mpz-p D))
  (mmux-gmp-c-fdiv-qr (mpz-obj Q) (mpz-obj R) (mpz-obj N) (mpz-obj D)))

;;; unsigned long int mpz_fdiv_q_ui (mpz_t Q, const mpz_t N, unsigned long int D) */
(defun mpz-fdiv-q-ui (Q N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p Q))
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-fdiv-q-ui (mpz-obj Q) (mpz-obj N) D))

;;; unsigned long int mpz_fdiv_r_ui (mpz_t R, const mpz_t N, unsigned long int D) */
(defun mpz-fdiv-r-ui (R N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p R))
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-fdiv-r-ui (mpz-obj R) (mpz-obj N) D))

;;; unsigned long int mpz_fdiv_qr_ui (mpz_t Q, mpz_t R, const mpz_t N, unsigned long int D) */
(defun mpz-fdiv-qr-ui (Q R N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p Q))
  (cl-assert (mpz-p R))
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-fdiv-qr-ui (mpz-obj Q) (mpz-obj R) (mpz-obj N) D))

;;; unsigned long int mpz_fdiv_ui (const mpz_t N, unsigned long int D) */
(defun mpz-fdiv-ui (N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-fdiv-ui (mpz-obj N) D))

;;; void mpz_fdiv_q_2exp (mpz_t Q, const mpz_t N, mp_bitcnt_t B) */
(defun mpz-fdiv-q-2exp (Q N B)
  "Divide N by D, forming a quotient Q and/or remainder R; compute D as 2^B."
  (cl-assert (mpz-p Q))
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-bitcnt-p B))
  (mmux-gmp-c-fdiv-q-2exp (mpz-obj Q) (mpz-obj N) B))

;;; void mpz_fdiv_r_2exp (mpz_t R, const mpz_t N, mp_bitcnt_t B) */
(defun mpz-fdiv-r-2exp (R N B)
  "Divide N by D, forming a quotient Q and/or remainder R; compute D as 2^B."
  (cl-assert (mpz-p R))
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-bitcnt-p B))
  (mmux-gmp-c-fdiv-r-2exp (mpz-obj R) (mpz-obj N) B))

;;; --------------------------------------------------------------------

;;; void mpz_tdiv_q (mpz_t Q, const mpz_t N, const mpz_t D) */
(defun mpz-tdiv-q (Q N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p Q))
  (cl-assert (mpz-p N))
  (cl-assert (mpz-p D))
  (mmux-gmp-c-tdiv-q (mpz-obj Q) (mpz-obj N) (mpz-obj D)))

;;; void mpz_tdiv_r (mpz_t R, const mpz_t N, const mpz_t D) */
(defun mpz-tdiv-r (R N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p R))
  (cl-assert (mpz-p N))
  (cl-assert (mpz-p D))
  (mmux-gmp-c-tdiv-r (mpz-obj R) (mpz-obj N) (mpz-obj D)))

;;; void mpz_tdiv_qr (mpz_t Q, mpz_t R, const mpz_t N, const mpz_t D) */
(defun mpz-tdiv-qr (Q R N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p Q))
  (cl-assert (mpz-p R))
  (cl-assert (mpz-p N))
  (cl-assert (mpz-p D))
  (mmux-gmp-c-tdiv-qr (mpz-obj Q) (mpz-obj R) (mpz-obj N) (mpz-obj D)))

;;; unsigned long int mpz_tdiv_q_ui (mpz_t Q, const mpz_t N, unsigned long int D) */
(defun mpz-tdiv-q-ui (Q N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p Q))
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-tdiv-q-ui (mpz-obj Q) (mpz-obj N) D))

;;; unsigned long int mpz_tdiv_r_ui (mpz_t R, const mpz_t N, unsigned long int D) */
(defun mpz-tdiv-r-ui (R N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p R))
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-tdiv-r-ui (mpz-obj R) (mpz-obj N) D))

;;; unsigned long int mpz_tdiv_qr_ui (mpz_t Q, mpz_t R, const mpz_t N, unsigned long int D) */
(defun mpz-tdiv-qr-ui (Q R N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p Q))
  (cl-assert (mpz-p R))
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-tdiv-qr-ui (mpz-obj Q) (mpz-obj R) (mpz-obj N) D))

;;; unsigned long int mpz_tdiv_ui (const mpz_t N, unsigned long int D) */
(defun mpz-tdiv-ui (N D)
  "Divide N by D, forming a quotient Q and/or remainder R."
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-tdiv-ui (mpz-obj N) D))

;;; void mpz_tdiv_q_2exp (mpz_t Q, const mpz_t N, mp_bitcnt_t B) */
(defun mpz-tdiv-q-2exp (Q N B)
  "Divide N by D, forming a quotient Q and/or remainder R; compute D as 2^B."
  (cl-assert (mpz-p Q))
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-bitcnt-p B))
  (mmux-gmp-c-tdiv-q-2exp (mpz-obj Q) (mpz-obj N) B))

;;; void mpz_tdiv_r_2exp (mpz_t R, const mpz_t N, mp_bitcnt_t B) */
(defun mpz-tdiv-r-2exp (R N B)
  "Divide N by D, forming a quotient Q and/or remainder R; compute D as 2^B."
  (cl-assert (mpz-p R))
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-bitcnt-p B))
  (mmux-gmp-c-tdiv-r-2exp (mpz-obj R) (mpz-obj N) B))

;;; --------------------------------------------------------------------

;;; void mpz_mod (mpz_t R, const mpz_t N, const mpz_t D) */
(defun mpz-mod (R N D)
  "Set R to N mod D."
  (cl-assert (mpz-p R))
  (cl-assert (mpz-p N))
  (cl-assert (mpz-p D))
  (mmux-gmp-c-mod (mpz-obj R) (mpz-obj N) (mpz-obj D)))

;;; unsigned long int mpz_mod_ui (mpz_t R, const mpz_t N, unsigned long int D) */
(defun mpz-mod-ui (R N D)
  "Set R to N mod D."
  (cl-assert (mpz-p R))
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-mod-ui (mpz-obj R) (mpz-obj N) D))

;;; --------------------------------------------------------------------

;;; void mpz_divexact (mpz_t Q, const mpz_t N, const mpz_t D) */
(defun mpz-divexact (Q N D)
  "Set Q to N/D."
  (cl-assert (mpz-p Q))
  (cl-assert (mpz-p N))
  (cl-assert (mpz-p D))
  (mmux-gmp-c-divexact (mpz-obj Q) (mpz-obj N) (mpz-obj D)))

;;; void mpz_divexact_ui (mpz_t Q, const mpz_t N, unsigned long D) */
(defun mpz-divexact-ui (Q N D)
  "Set Q to N/D."
  (cl-assert (mpz-p Q))
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-divexact-ui (mpz-obj Q) (mpz-obj N) D))

;;; --------------------------------------------------------------------

;;; int mpz_divisible_p (const mpz_t N, const mpz_t D) */
(defun mpz-divisible-p (N D)
  "Return true if N is exactly divisible by D."
  (cl-assert (mpz-p N))
  (cl-assert (mpz-p D))
  (mmux-gmp-c-divisible-p (mpz-obj N) (mpz-obj D)))

;;; int mpz_divisible_ui_p (const mpz_t N, unsigned long int D) */
(defun mpz-divisible-ui-p (N D)
  "Return true if N is exactly divisible by D."
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-divisible-ui-p (mpz-obj N) D))

;;; int mpz_divisible_2exp_p (const mpz_t N, mp_bitcnt_t B) */
(defun mpz-divisible-2exp-p (N B)
  "Return true if N is exactly divisible by 2^B."
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-bitcnt-p B))
  (mmux-gmp-c-divisible-2exp-p (mpz-obj N) B))

;;; --------------------------------------------------------------------

;;; int mpz_congruent_p (const mpz_t N, const mpz_t C, const mpz_t D) */
(defun mpz-congruent-p (N C D)
  "Return non-zero if N is congruent to C modulo D."
  (cl-assert (mpz-p N))
  (cl-assert (mpz-p C))
  (cl-assert (mpz-p D))
  (mmux-gmp-c-congruent-p (mpz-obj N) (mpz-obj C) (mpz-obj D)))

;;; int mpz_congruent_ui_p (const mpz_t N, unsigned long int C, unsigned long int D) */
(defun mpz-congruent-ui-p (N C D)
  "Return non-zero if N is congruent to C modulo D."
  (cl-assert (mpz-p N))
  (cl-assert (mmux-gmp-ulint-p C))
  (cl-assert (mmux-gmp-ulint-p D))
  (mmux-gmp-c-congruent-ui-p (mpz-obj N) C D))

;;; int mpz_congruent_2exp_p (const mpz_t N, const mpz_t C, mp_bitcnt_t B) */
(defun mpz-congruent-2exp-p (N C B)
  "Return non-zero if N is congruent to C modulo 2^B."
  (cl-assert (mpz-p N))
  (cl-assert (mpz-p C))
  (cl-assert (mmux-gmp-bitcnt-p B))
  (mmux-gmp-c-congruent-2exp-p (mpz-obj N) (mpz-obj C) B))


;;;; integer number functions: exponentiation

;; void mpz_powm (mpz_t ROP, const mpz_t BASE, const mpz_t EXP, const mpz_t MOD)
(defun mpz-powm (rop base exp mod)
  "Set ROP to (BASE raised to EXP) modulo MOD."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p base))
  (cl-assert (mpz-p exp))
  (cl-assert (mpz-p mod))
  (mmux-gmp-c-mpz-powm (mpz-obj rop) (mpz-obj base) (mpz-obj exp) (mpz-obj mod)))

;; void mpz_powm_ui (mpz_t ROP, const mpz_t BASE, unsigned long int EXP, const mpz_t MOD)
(defun mpz-powm-ui (rop base exp mod)
  "Set ROP to (BASE raised to EXP) modulo MOD."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p base))
  (cl-assert (mmux-gmp-ulint-p exp))
  (cl-assert (mpz-p mod))
  (mmux-gmp-c-mpz-powm-ui (mpz-obj rop) (mpz-obj base) exp (mpz-obj mod)))

;; void mpz_powm_sec (mpz_t ROP, const mpz_t BASE, const mpz_t EXP, const mpz_t MOD)
(defun mpz-powm-sec (rop base exp mod)
  "Set ROP to (BASE raised to EXP) modulo MOD.  MOD must be odd."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p base))
  (cl-assert (and (mpz-p exp)
		  (< 0 (mmux-gmp-c-mpz-cmp-si (mpz-obj exp) 0))))
  (cl-assert (and (mpz-p mod)
		  (mmux-gmp-c-mpz-odd-p (mpz-obj mod))))
  (mmux-gmp-c-mpz-powm-sec (mpz-obj rop) (mpz-obj base) (mpz-obj exp) (mpz-obj mod)))

;; void mpz_pow_ui (mpz_t ROP, const mpz_t BASE, unsigned long int EXP)
(defun mpz-pow-ui (rop base exp)
  "Set ROP to BASE raised to EXP."
  (cl-assert (mpz-p rop))
  (cl-assert (mpz-p base))
  (cl-assert (mmux-gmp-ulint-p exp))
  (mmux-gmp-c-mpz-pow-ui (mpz-obj rop) (mpz-obj base) exp))

;; void mpz_ui_pow_ui (mpz_t ROP, unsigned long int BASE, unsigned long int EXP)
(defun mpz-ui-pow-ui (rop base exp)
  "Set ROP to BASE raised to EXP."
  (cl-assert (mpz-p rop))
  (cl-assert (mmux-gmp-ulint-p base))
  (cl-assert (mmux-gmp-ulint-p exp))
  (mmux-gmp-c-mpz-ui-pow-ui (mpz-obj rop) base exp))


;;;; root extraction functions

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


;;;; comparison functions

;; int mpz_cmp (const mpz_t OP1, const mpz_t OP2)
(cl-defgeneric mpz-cmp (op1 op2)
  "Compare OP1 and OP2.")
(cl-defmethod mpz-cmp ((op1 mpz) (op2 mpz))
  "Compare OP1 and OP2."
  (mmux-gmp-c-mpz-cmp (mpz-obj op1) (mpz-obj op2)))

;; int mpz_cmp_d (const mpz_t OP1, double OP2)
(cl-defgeneric mpz-cmp-d (op1 op2)
  "Compare OP1 and OP2.")
(cl-defmethod mpz-cmp-d ((op1 mpz) (op2 float))
  "Compare OP1 and OP2."
  (mmux-gmp-c-mpz-cmp-d (mpz-obj op1) op2))

;; int mpz_cmp_si (const mpz_t OP1, signed long int OP2)
(cl-defgeneric mpz-cmp-si (op1 op2)
  "Compare OP1 and OP2.")
(cl-defmethod mpz-cmp-si ((op1 mpz) (op2 integer))
  "Compare OP1 and OP2."
  (mmux-gmp-c-mpz-cmp-si (mpz-obj op1) op2))

;; int mpz_cmp_ui (const mpz_t OP1, unsigned long int OP2)
(cl-defgeneric mpz-cmp-ui (op1 op2)
  "Compare OP1 and OP2.")
(cl-defmethod mpz-cmp-ui ((op1 mpz) (op2 integer))
  "Compare OP1 and OP2."
  (cl-assert (<= 0 op2))
  (mmux-gmp-c-mpz-cmp-ui (mpz-obj op1) op2))

;;; --------------------------------------------------------------------

;; int mpz_cmpabs (const mpz_t OP1, const mpz_t OP2)
(cl-defgeneric mpz-cmpabs (op1 op2)
  "Compare the absolute values of OP1 and OP2.")
(cl-defmethod mpz-cmpabs ((op1 mpz) (op2 mpz))
  "Compare the absolute values of OP1 and OP2."
  (mmux-gmp-c-mpz-cmpabs (mpz-obj op1) (mpz-obj op2)))

;; int mpz_cmpabs_d (const mpz_t OP1, double OP2)
(cl-defgeneric mpz-cmpabs-d (op1 op2)
  "Compare the absolute values of OP1 and OP2.")
(cl-defmethod mpz-cmpabs-d ((op1 mpz) (op2 float))
  "Compare the absolute values of OP1 and OP2."
  (mmux-gmp-c-mpz-cmpabs-d (mpz-obj op1) op2))

;; int mpz_cmpabs_ui (const mpz_t OP1, unsigned long int OP2)
(cl-defgeneric mpz-cmpabs-ui (op1 op2)
  "Compare the absolute values of OP1 and OP2.")
(cl-defmethod mpz-cmpabs-ui ((op1 mpz) (op2 integer))
  "Compare the absolute values of OP1 and OP2."
  (cl-assert (<= 0 op2))
  (mmux-gmp-c-mpz-cmpabs-ui (mpz-obj op1) op2))

;;; --------------------------------------------------------------------

;; int mpz_sgn (const mpz_t OP)
(cl-defgeneric mpz-sgn (op)
  "Return an integer representing the sign of the operand.")
(cl-defmethod mpz-sgn ((op mpz))
  "Return an integer representing the sign of the operand."
  (mmux-gmp-c-mpz-sgn (mpz-obj op)))


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
  (cl-assert (mpz-p op))
  (mmux-gmp-c-mpq-set-z (mpq-obj rop) (mpz-obj op)))

(defun mpq-set-f (rop op)
  "Assign the value of an `mpf' object to an `mpq' object."
  (cl-assert (mpq-p rop))
  (cl-assert (mpf-p op))
  (mmux-gmp-c-mpq-set-f (mpq-obj rop) (mpf-obj op)))

(defun mpq-set-str (rop str base)
  "Assign the value of a string object to an `mpq' object."
  (cl-assert (mpq-p rop))
  (cl-assert (stringp str))
  (cl-assert (and (integerp base)
		  (or (zerop base)
		      (<= 2 base 62))))
  (mmux-gmp-c-mpq-set-str (mpq-obj rop) str base))

(defun mpq-swap (op1 op2)
  "Swap the values of two `mpq' objects."
  (cl-assert (mpq-p op1))
  (cl-assert (mpq-p op2))
  (mmux-gmp-c-mpq-swap (mpq-obj op1) (mpq-obj op2)))


;;;; rational number functions: conversion

(defun mpq-get-d (op)
  "Convert an object of type `mpq' to a floating-point number."
  (cl-assert (mpq-p op))
  (mmux-gmp-c-mpq-get-d (mpq-obj op)))

(defun mpq-get-str (base op)
  "Convert an object of type `mpq' to a string."
  (cl-assert (and (integerp base)
		  (or (<= +2 base +36)
		      (>= -2 base -36))))
  (cl-assert (mpq-p op))
  (mmux-gmp-c-mpq-get-str base (mpq-obj op)))


;;;; rational number functions: arithmetic

(defun mpq-add (rop op1 op2)
  "Add two `mpq' objects."
  (cl-assert (mpq-p rop))
  (cl-assert (mpq-p op1))
  (cl-assert (mpq-p op2))
  (mmux-gmp-c-mpq-add (mpq-obj rop) (mpq-obj op1) (mpq-obj op2)))


;;;; floating-point number functions: initialisation

(defun mpf-set-default-prec (prec)
  "Set the default precision of `mpf' objects."
  (cl-assert (and (integerp prec)
		  (< 0 prec)))
  (mmux-gmp-c-mpf-set-default-prec prec))

(defun mpf-get-default-prec ()
  "Get the default precision of `mpf' objects."
  (mmux-gmp-c-mpf-get-default-prec))

(defun mpf-set-prec (rop prec)
  "Set the default precision of an `mpf' object."
  (cl-assert (mpf-p rop))
  (cl-assert (and (integerp prec)
		  (< 0 prec)))
  (mmux-gmp-c-mpf-set-prec (mpf-obj rop) prec))

(defun mpf-get-prec (rop)
  "Get the precision of an `mpf' object."
  (mmux-gmp-c-mpf-get-prec (mpf-obj rop)))


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


;;;; floating-point number functions: conversion

(defun mpf-get-ui (op)
  "Convert an object of type `mpf' to an unsigned exact integer number."
  (cl-assert (mpf-p op))
  (mmux-gmp-c-mpf-get-ui (mpf-obj op)))

(defun mpf-get-si (op)
  "Convert an object of type `mpf' to a signed exact integer number."
  (cl-assert (mpf-p op))
  (mmux-gmp-c-mpf-get-si (mpf-obj op)))

(defun mpf-get-d (op)
  "Convert an object of type `mpf' to a floating-point number."
  (cl-assert (mpf-p op))
  (mmux-gmp-c-mpf-get-d (mpf-obj op)))

(defun mpf-get-d-2exp (op)
  "Convert an object of type `mpf' to a floating-point number, returning the exponent separately."
  (cl-assert (mpf-p op))
  (mmux-gmp-c-mpf-get-d-2exp (mpf-obj op)))

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

(defun mpf-add (rop op1 op2)
  "Add two `mpf' objects."
  (cl-assert (mpf-p rop))
  (cl-assert (mpf-p op1))
  (cl-assert (mpf-p op2))
  (mmux-gmp-c-mpf-add (mpf-obj rop) (mpf-obj op1) (mpf-obj op2)))


;;;; done

(provide 'mmux-emacs-gmp)

;;; mmux-emacs-gmp.el ends here
