;; vim:ts=2:sw=2:et:
;;
;;  (require "permutations")
;;
;;  (permutations 3 '(1 2 3)) =>
;;    ((1 2 3) (1 3 2) (2 1 3) (2 3 1) (3 1 2) (3 2 1))
;;
(context 'permutations)

(define (permutations:permutations r lst)
  (if
    (or (< r 1) (< (length lst) r)) '()
    (= r 1) (map list lst)
    (let (
      perm (lambda (r lst)
        (if (= r 1)
          (map list lst)
          (let (
            rslt '()
            l nil
            x nil
            )
            (for (i 0 (-- (length lst)))
              (setq l (copy lst)
                    x (pop l i))
              (dolist (e (perm (- r 1) l))
                (push (push x e) rslt -1))))))
      )
      (perm r lst))))
