;; vim:ts=2:sw=2:et:
;;
;;  (require "rcurry")
;;
;;  ((rcurry append "Left") "Right") =>
;;    "RightLeft"
;;
(context 'rcurry)

(define-macro (rcurry:rcurry func arg1)
  (expand (lambda (arg0) (func arg0 arg1)) 'func 'arg1))
