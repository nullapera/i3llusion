;; vim:ts=2:sw=2:et:
;;
;;  (require "chunk-by")
;;
;;  (chunk-by (fn(a) (% a 3)) '(0 1 2 3 4 5 6 7 8 9)) =>
;;    ((0 (0 3 6 9)) (1 (1 4 7)) (2 (2 5 8)))
;;
(context 'chunk-by)

(define(chunk-by:chunk-by func lst) (let(
  rslt '()
  key nil
  )
  (dolist(e lst)
    (setq key (func e))
    (if(lookup key rslt)
      (push e (lookup key rslt) -1)
      (push (list key (list e)) rslt -1)))
  rslt))
