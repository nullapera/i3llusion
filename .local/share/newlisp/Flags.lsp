;; vim:ts=2:sw=2:et:
;;
;;  (require "Flags")
;;
;;  (setq flx (Flags 8 0 1 nil true "" "!=0" '() '(()))) =>
;;    (Flags (nil true nil true nil true nil true))
;;
;;  (:s flx 0) => "0"
;;  (:n flx 1) => 1
;;  (:b flx 2) => nil
;;  (:not! flx 3) => nil
;;  (:to-string flx) => "01000101"
;;  (:to-string flx 3 2) => "00"
;;  (:to-nums flx) => (0 1 0 0 0 1 0 1)
;;  (:to-nums flx -2) => (0 1)
;;  (:to-bools flx) => (nil true nil nil nil true nil true)
;;  (:to-bools flx '(1 3 6)) => (true nil nil)
;;  (:to-int flx 0 4) => 4
;;  (:to-int flx '(1 5 7)) => 7
;;
(require "splat")

(context 'Flags)

(constant '.FLAGS 1)

(define (Flags:Flags nsize) (let (
  obj (list (context) (dup nil nsize))
  )
  (doargs (e)
    (:flag obj $idx e))
  obj))

(define (s idx) (if (self .FLAGS idx) "1" "0"))
(define (n idx) (if (self .FLAGS idx) 1 0))
(define (b idx) (self .FLAGS idx))

(define (flag idx value)
  (setf (self .FLAGS idx) (and (not (null? value)) (!= value "0"))))

(define (not! idx)
  (setf (self .FLAGS idx) (not (self .FLAGS idx))))

(define (set*)
  (if (list? (args 0))
    (dolist (e (args 0))
      (flag $idx e))
    (doargs (e)
      (flag $idx e))))

(define (to-string) (let (
  str (join (map (fn (a) (if a "1" "0")) (self .FLAGS)))
  )
  (if (empty? (args))
    str
    (if (list? (args 0))
      (join (map str (args 0)))
      (splat slice (cons str (args)))))))

(define (to-nums) (let (
  nums (map (fn (a) (if a 1 0)) (self .FLAGS))
  )
  (if (empty? (args))
    nums
    (if (list? (args 0))
      (map 'nums (args 0))
      (splat slice (cons nums (args)))))))

(define (to-bools) (let (
  bools (self .FLAGS)
  )
  (if (empty? (args))
    bools
    (if (list? (args 0))
      (map 'bools (args 0))
      (splat slice (cons bools (args)))))))

(define (to-int) (let (
  str (splat to-string (args))
  )
  (int str 0 2)))
