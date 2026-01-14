;; vim:ts=2:sw=2:et:
;;
;;  (require "isa")
;;
;;  (new Class 'A)
;;  (new Class 'B)
;;  (isa (A) A) => true
;;  (isa (A) B) => nil
;;
(context 'isa)

(define (isa:isa obj ctx)
  (and (list? obj) (true? obj) (context? ctx) (= (first obj) ctx)))
