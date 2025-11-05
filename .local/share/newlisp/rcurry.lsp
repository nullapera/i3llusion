;; vim:ts=2:sw=2:et:
;;
;;  (require "rcurry")
;;
;;  ((rcurry append "Left") "Right") =>
;;    "RightLeft"
;;
(context 'rcurry)

(define-macro (rcurry:rcurry FN ARG)
  (expand (lambda (arg) (FN arg ARG))))
