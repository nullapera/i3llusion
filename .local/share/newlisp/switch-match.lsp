;; :vim:ts=2:sw=2:et:
;;
;;  (require "switch-match")
;;
;;  (switch-match (r (dup 0))
;;    ('(0 0) (println "OK-1"))
;;    ('(? 0) (println "OK-2"))) =>
;;    "OK-1"
;;    "OK-2"
;;
;;  (switch-match (r '(0 2 3 4) (!= r nil))
;;    ('(0 *) (println (apply * (first r))))
;;    ('(0 *) (println (apply + (first r))))) =>
;;    24
;;
(context 'switch-match)

(define-macro (switch-match:switch-match head) (letex (
  var (pop head)
  _that (pop head)
  break (pop head)
  )
  (let (
    var nil
    rslt nil
    that _that
    )
    (doargs (e break)
      (setq var (match (eval (first e)) that))
        (unless (nil? var)
          (setq rslt (eval (cons 'begin (rest e))))))
    rslt)))
