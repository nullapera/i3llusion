;; :vim:ts=2:sw=2:et:
;;
;;  (require "case-match")
;;
;;  (case-match(r (dup 0))
;;    ('(1 0) (println "OK-1"))
;;    ('(? 0) (println "OK-2"))) =>
;;    "OK-2"
;;
(context 'case-match)

(define-macro(case-match:case-match head) (letex(
  var (pop head)
  _that (pop head)
  )
  (let(var nil
       rslt nil
       that _that)
    (doargs(e var)
      (setq var (match (eval (pop e)) that))
      (unless (nil? var) (setq rslt (eval (cons 'begin e)))))
    rslt)))
