;; vim:ts=2:sw=2:et:
;;
;;  (require "Slider")
;;
;;  (setq sl (Slider 22 0 100 5))
;;
;;  (:value! sl 33) => 33
;;
;;  set to default:
;;  (:value! sl) => 22
;;
;;  (:valueR sl 13) => 15 ;rounded by step
;;
;;  step [+]n => steps towards maxvalue (no over step)
;;  step -n => steps towards minvalue (no over step)
;;
;;  (:step sl +2) => 25
;;  (:step sl -4) => 5
;;
(require "mutuple")
(mutuple {Slider} "value defvalue minvalue maxvalue stepvalue")


(context Slider)

(constant '.VALUE 1 '.DEFAULT 2 '.MIN 3 '.MAX 4 '.STEP 5)

(define (Slider:Slider (defaultval 0) (minval 0) (maxval 100) (stepval 1))
  (list (context) defaultval defaultval minval maxval (abs stepval)))

(define (value! newval)
  (setf (self .VALUE)
        (min (max (or newval (self .DEFAULT)) (self .MIN))
             (self .MAX))))

(define (valueR newval) (letn (
  s (self .STEP)
  r (% newval s)
  )
  (value!
    (if (zero? r)
      newval
      (+ (- newval r) (if (< (/ s 2) (abs r)) (* (sgn newval) s) 0))))))

(define (step n)
  (if (null? n)
    (self .VALUE)
    (value! (+ (self .VALUE) (* n (self .STEP))))))
