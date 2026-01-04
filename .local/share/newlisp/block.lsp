;; vim:ts=2:sw=2:et:
;;
;;  (require "block")
;;
;;  (let (a 1 b 2)
;;    (block 'a
;;      (println "in-a")
;;      (block 'b
;;        (println "in-b")
;;        (thru 'a (* 2 b))
;;        (println "never here-b") )
;;      (println "never here-a") )
;;    (list a b) ) => (4 2)
;;
;;  (let (a 1 b 2)
;;    (block 'a
;;      (println "in-a")
;;      (block 'b
;;        (println "in-b")
;;        (thru 'b (* 2 b))
;;        (println "never here-b") )
;;      (/ b 2) )
;;    (list a b) ) => (2 4)
;;
(require "isa")

(context 'block)

(define-macro (block:block symbol) (letex (
  x 'x
  symbol symbol
  body (cons 'begin (args))
  )
  (set x (catch body))
  (if (isa x MAIN:thru)
    (if (= (nth 1 x) symbol)
      (set symbol (last x))
      (throw x))
    (set symbol x))))


(context 'thru)

(define (thru:thru symbol value) (throw (list (context) symbol value)))
