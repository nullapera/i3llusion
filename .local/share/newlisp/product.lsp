;; vim:ts=2:sw=2:et:
;;
;;  (require "product")
;;
;;  (product '((0 1) (0 1) (0 1))) =>
;;    ((0 0 0) (0 0 1) (0 1 0) (0 1 1) (1 0 0) (1 0 1) (1 1 0) (1 1 1))
;;
(context 'product)

(define (product:product lst) (let (
  lst (clean empty? (map (fn (a) (if (list? a) a (list a))) lst))
  )
  (when lst
    (let (
      prod (lambda (lstA lstB) (let (
        rslt '()
        )
        (dolist (a lstA)
          (dolist (b lstB)
            (push (push b (copy a) -1) rslt -1)))))
      )
      (apply prod (push '(()) lst) 2)))))
