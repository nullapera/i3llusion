;; vim:ts=2:sw=2:et:
;;
;;  (require "Flag")
;;
;;  (setq fl (Flag 8 '(0 1 nil true 0 1 nil true))) =>
;;    (Flag (0 1 0 1 0 1 0 1))
;;
;;  (:on? fl 2) => nil
;;  (:off? fl 2) => true
;;  (:toggle fl 3) => nil
;;  (:nums fl) => (0 1 0 0 0 1 0 1)
;;  (:nums fl -2) => (0 1)
;;  (:to-int fl 0 4) => 4
;;  (:to-int fl '(1 5 7)) => 7
;;
(context 'Flag)

(constant
  'NT '(nil true) 'TN '(true nil) 'OZ '(1 0) 'ZOSTR '("0" "1") '.FLAGS 1)

(define(Flag:Flag nsize lst)
  (let(obj (list (context) (dup 0 nsize)))
    (when lst (:set-from obj lst))
    obj))

(define(on idx)
  (setf (self .FLAGS idx) 1)
  true)

(define(off idx)
  (setf (self .FLAGS idx) 0)
  nil)

(define(toggle idx)
  (NT (setf (self .FLAGS idx) (OZ $it))))

(define(on? idx) (NT (self .FLAGS idx)))

(define(off? idx) (TN (self .FLAGS idx)))

(define(flag idx value)
  (setf (self .FLAGS idx) (if(or (= value 1) (= value true)) 1 0)))

(define(set-from lst) (dolist(e lst) (flag $idx e)))

(define(nums a0 a1)
  (if(nil? a0) (self .FLAGS)
     (list? a0) (select (self .FLAGS) a0)
     (nil? a1) (a0 (self .FLAGS))
     (a0 a1 (self .FLAGS))))

(define(to-int a0 a1)
  (let(lst (select ZOSTR (nums a0 a1)))
    (int (join lst) 0 2)))
