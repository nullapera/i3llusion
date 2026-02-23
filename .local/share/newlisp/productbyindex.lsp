;; vim:ts=2:sw=2:et:
;;
;;  (require "productbyindex")
;;
;;  (productbyindex 5 '(0 1) '(0 1) '(0 1)) =>
;;    (1 0 1)
;;
(context 'productbyindex)

(define(productbyindex:productbyindex ndx)
  (letn(lst (replace '() (args))
        len (map length lst))
    (if(or (< ndx 0) (<= (apply * len) ndx))
      '()
      (let(rslt '()
           rem 0)
        (for(i (-- (length lst)) 0 -1)
          (setq rem (% ndx (len i))
                ndx (/ ndx (len i)))
          (push ((lst i) rem) rslt))))))
