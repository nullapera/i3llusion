;; vim:ts=2:sw=2:et:
;;
;;  (require "mutuple")
;;
;;  (mutuple {Trio} "f1rst s3cond th1rd")
;;  (setq trio (Trio "alfa" "beta" "gamma"))
;;  (:keys@ trio) => ("f1rst" "s3cond" "th1rd")
;;  (:values@ trio) => ("alfa" "beta" "gamma")
;;  (:dict@ trio) => (("f1rst" "alfa") ("s3cond" "beta") ("th1rd" "gamma"))
;;  (:f1rst trio) => "alfa"
;;  (:s3cond! trio "Beta") => "Beta"
;;  (:th1rd! trio upper-case) => "GAMMA"
;;
(context 'mutuple)

(define (mutuple:mutuple ctxname keys) (let (
  ctx (new Class (sym ctxname MAIN))
  keys[] (if (list? keys) keys (parse keys))
  )
  (context ctx 'keys[] keys[])
  (context ctx 'keys@ (lambda () (context (context) 'keys[])))
  (context ctx 'values@ (lambda () (slice (self) 1)))
  (context ctx 'dict@ (lambda ()
    (map list (context (context) 'keys[]) (slice (self) 1))))
  (for (i 1 (length keys[])) (letex (
    i i
    )
    (context ctx (keys[] (- i 1)) (lambda () (self i)))
    (context ctx (string (keys[] (- i 1)) "!")
      (lambda (arg)
        (setf (self i)
              (if (or (primitive? arg) (lambda? arg))
                (arg (self i))
                arg))))))
  (context MAIN ctxname)))
