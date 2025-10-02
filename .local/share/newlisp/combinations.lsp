;; vim:ts=2:sw=2:et:
;;
;;  (require "combinations")
;;
;;  (combinations 2 '(1 2 3)) =>
;;    ((1 2) (1 3) (2 3))
;;
(context 'combinations)

(define (combinations:combinations r lst) (let (
  n (length lst)
  )
  (if
    (or (< r 1) (< n r)) '()
    (= r 1) (map list lst)
    (= n r) (list lst)
    (let (
      comb (lambda (r lst , x (rslt '()))
        (if (= r 1)
          (map list lst)
          (dotimes (_ (++ (- (length lst) r)))
            (setq x (pop lst))
            (dolist (e (comb (- r 1) lst))
              (push (push x e) rslt -1)))))
      )
      (comb r lst)))))
