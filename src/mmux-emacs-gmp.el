;;; mmux-emacs-gmp.el --- gmp module

;; Copyright (C) 2020 Marco Maggi

;; Author: Marco Maggi <mrc.mgg@gmail.com>
;; Created: Jan 15, 2020
;; Time-stamp: <2020-01-20 10:55:39 marco>
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
