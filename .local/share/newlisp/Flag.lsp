;; vim:ts=2:sw=2:et:
;;
;;  (require "Flag")
;;
;;  (setq fl (Flag 8 '(0 1 nil true "" "!=0" () (()) ))) =>
;;    (Flag (0 1 0 1 0 1 0 1))
;;
;;  (:num fl 1) => 1
;;  (:?? fl 2) => nil
;;  (:toggle fl 3) => nil
;;  (:nums fl) => (0 1 0 0 0 1 0 1)
;;  (:nums fl -2) => (0 1)
;;  (:bools fl) => (nil true nil nil nil true nil true)
;;  (:bools fl '(1 3 6)) => (true nil nil)
;;  (:to-int fl 0 4) => 4
;;  (:to-int fl '(1 5 7)) => 7
;;
(context 'Flag)

(constant 'NT '(nil true) '.FLAGS 1)

(define(Flag:Flag nsize lst)
  (let(obj (list (context) (dup 0 nsize)))
    (when lst (:set-from obj lst))
    obj))

(define(@@ idx) (self .FLAGS idx))

(define(?? idx) (NT (self .FLAGS idx)))

(define(yes idx)
  (setf (self .FLAGS idx) 1)
  true)

(define(no idx)
  (setf (self .FLAGS idx) 0)
  nil)

(define(flag idx value)
  (setf (self .FLAGS idx) (if(or (null? value) (= value "0")) 0 1)))

(define(toggle idx)
  (NT (setf (self .FLAGS idx) ('(1 0) $it))))

(define(set-from lst) (dolist(e lst) (flag $idx e)))

(define(nums a0 a1)
  (if(nil? a0) (self .FLAGS)
     (list? a0) (select (self .FLAGS) a0)
     (nil? a1) (a0 (self .FLAGS))
     (a0 a1 (self .FLAGS))))

(define(to-int a0 a1)
  (let (lst (select '("0" "1") (nums a0 a1)))
    (int (join lst) 0 2)))
