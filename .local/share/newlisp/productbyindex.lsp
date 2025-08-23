;; vim:ts=2:sw=2:et:
;;
;;  (require "productbyindex")
;;
;;  (productbyindex 5 '((0 1) (0 1) (0 1))) =>
;;    (1 0 1)
;;
(context 'productbyindex)

(define (productbyindex:productbyindex ndx lst) (letn (
  _lst (replace '() (map (fn (a) (if (list? a) a (list a))) lst))
  lst (if (or (< ndx) (< (apply * (map length _lst)) ndx)) '() _lst)
  )
  (when lst (let (
    rslt '()
    rem 0
    len 0
    )
    (for (i (-- (length lst)) 0 -1)
      (setq len (length (lst i))
            rem (% ndx len)
            ndx (/ ndx len))
      (push ((lst i) rem) rslt))))))
