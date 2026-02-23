;; vim:ts=2:sw=2:et:
;;
;;  (require "product")
;;
;;  (product '(0 1) '(0 1) '(0 1)) =>
;;    ((0 0 0) (0 0 1) (0 1 0) (0 1 1) (1 0 0) (1 0 1) (1 1 0) (1 1 1))
;;
(context 'product)

(define(product:product)
  (letn(lst (replace '() (args))
        rslt (map list (or (pop lst) '()))
        tmp '())
    (dolist(L lst)
      (dolist(a rslt)
        (dolist(b L) (push (push b (copy a) -1) tmp -1)))
      (setq rslt tmp
            tmp '()))
    rslt))
