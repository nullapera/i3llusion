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
(context 'Flags)

(constant '.FLAGS 1)

(define (Flags:Flags nsize) (let (
  obj (list (context) (dup nil nsize))
  )
  (doargs (e) (:flag obj $idx e))
  obj))

(define (s idx) (if (self .FLAGS idx) "1" "0"))
(define (n idx) (if (self .FLAGS idx) 1 0))
(define (b idx) (self .FLAGS idx))

(define (flag idx value)
  (setf (self .FLAGS idx) (and (not (null? value)) (!= value "0"))))

(define (not! idx)
  (setf (self .FLAGS idx) (not $it)))

(define (set-from lst) (dolist (e lst) (flag $idx e)))

(define (to-bools a0 a1)
  (if
    (nil? a0) (self .FLAGS)
    (list? a0) (select (self .FLAGS) a0)
    (nil? a1) (a0 (self .FLAGS))
    (a0 a1 (self .FLAGS))))

(define (to-nums a0 a1)
  (map (fn (a) (if a 1 0)) (to-bools a0 a1)))

(define (to-string a0 a1)
  (join (map (fn (a) (if a "1" "0")) (to-bools a0 a1))))

(define (to-int a0 a1) (int (to-string a0 a1) 0 2))
