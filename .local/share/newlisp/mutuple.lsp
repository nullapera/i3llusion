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
  i nil
  code [text] (begin
    (setq keys[] (if (list? mutuple:keys) mutuple:keys (parse mutuple:keys)))
    (define (keys@) keys[])
    (define (values@) (slice (self) 1))
    (define (dict@) (map list keys[] (slice (self) 1)))
    (for (mutuple:i 1 (length keys[]))
      (set (sym (keys[] (- mutuple:i 1)))
           (expand (lambda () (self mutuple:i)) 'mutuple:i))
      (set (sym (string (keys[] (- mutuple:i 1)) "!"))
           (expand (lambda (arg) (setf (self mutuple:i)
             (if (or (primitive? arg) (lambda? arg))
               (arg (self mutuple:i))
               arg)))
             'mutuple:i)))) [/text]
  )
  (eval-string code (new Class (sym ctxname MAIN)))
  (context MAIN ctxname)))
