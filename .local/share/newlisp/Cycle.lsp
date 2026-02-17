;; vim:ts=2:sw=2:et:
;;
;;  (require "Cycle")
;;
;;  (setq cy (Cycle '("0" "1" "2" "3" "4"))
;;
;;  (:at! cy 2) => "2"
;;  (:at! cy -2) => "3"
;;  (:at cy) => "3"
;;
;;  (:step cy +2) => "0"
;;  (:step cy +7) => "2"
;;  (:step cy -3) => "4"
;;  (:step cy -13) => "1"
;;
(context 'Cycle)

(constant '.INDEX 1 '.LIST 2 '.LENGTH 3)

(define(Cycle:Cycle lst) (list (context) 0 lst (length lst)))

(define(Cycle:index) (self .INDEX))

(define(at) ((self .LIST) (self .INDEX)))

(define(at! newindex)
  (let(x (% newindex (self .LENGTH)))
    (setf (self .INDEX) (if (< x 0) (+ (self .LENGTH) x) x))
    ((self .LIST) (self .INDEX))))

(define(step n)
  (if (null? n)
    ((self .LIST) (self .INDEX))
    (at! (+ (self .INDEX) n))))

(define(set-to item)
  (let(ndx (find item (self .LIST)))
    (when ndx (setf (self .INDEX) ndx))))
