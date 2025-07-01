;; vim:ts=2:sw=2:et:
;;
;;  (require "splat")
;;
;;  (splat func (arg0 arg1 arg2...argn)) =>
;;    (func arg0 arg1 arg2...argn)
;;  (splat append '("qwe" "rtz")) =>
;;    "qwertz"
;;  (splat append (explode (list "if" 'if if))) =>
;;    ("if" if if@xx...xx)
;;
(context 'splat)

(define (splat:splat func lst) (let (
  lst (map quote lst)
  )
  (eval (cons 'func lst))))
