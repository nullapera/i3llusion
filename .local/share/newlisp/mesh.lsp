;; vim:ts=2:sw=2:et:
;;
;;  (require "mesh")
;;
;;  (mesh '(1 2) '(11) '(111 222 333)) =>
;;    ((1 11 111) (2 222) (333))
;;
(context 'mesh)

(define (mesh:mesh) (let (
  rslt (dup '() (apply max (map length (args))))
  )
  (doargs (lst)
    (dolist (e lst) (push e (rslt $idx) -1)))
  rslt))
