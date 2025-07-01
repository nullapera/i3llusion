;; vim:ts=2:sw=2:et:
;;
;;  (require "Flags")
;;
;;  (setq flx (Flags 8 0 1 nil true "" "!=0" '() '(()))) =>
;;    (Flags (0 1 0 1 0 1 0 1))
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

(constant
  '.FLAGS 1)

(define (Flags:Flags nsize) (let (
  obj (list (context) (dup 0 nsize))
  )
  (doargs (e)
    (:flag obj $idx e))
  obj))

(define (s idx) (string (self .FLAGS idx)))
(define (n idx) (self .FLAGS idx))
(define (b idx) (!= (self .FLAGS idx)))

(define (flag idx value)
  (setf (self .FLAGS idx)
        (if (or (null? value) (= value "0")) 0 1)))

(define (not! idx)
  (!= (setf (self .FLAGS idx)
            (if (= (self .FLAGS idx)) 1 0))))

(define (set*)
  (if (list? (args 0))
    (dolist (e (args 0))
      (flag $idx e))
    (doargs (e)
      (flag $idx e))))

(define (to-string) (let (
  str (join (map string (self .FLAGS)))
  )
  (if (empty? (args))
    str
    (if (list? (args 0))
      (join (map str (args 0)))
      (splat slice (cons str (args)))))))

(define (to-nums)
  (if (empty? (args))
    (self .FLAGS)
    (if (list? (args 0))
      (map (self .FLAGS) (args 0))
      (splat slice (cons (self .FLAGS) (args))))))

(define (to-bools) (let (
  lst (map != (self .FLAGS))
  )
  (if (empty? (args))
    lst
    (if (list? (args 0))
      (map lst (args 0))
      (splat slice (cons lst (args)))))))

(define (to-int) (let (
  str (splat to-string (args))
  )
  (int str 0 2)))

