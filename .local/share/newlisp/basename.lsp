;; vim:ts=2:sw=2:et:
;;
;;  (require "basename")
;;
;;  (basename "/p1/p2/p3/base.ext") => "base.ext"
;;  (basename "/p1/p2/p3/base.ext" ".ext") => "base"
;;  (basename "/p1/p2/p3/base.Ext" ".ext") => "base.Ext"
;;  (basename "/p1/p2/p3/base.Ext" ".ext" true 1) => ("base" ".Ext")
;;  (basename "/p1/p2/p3/base.any" ".*") => "base"
;;  (basename "/p1/p2/p3/base.any" ".*" true) => ("base" ".any")
;;
(context 'basename)

(define (basename:basename path (xext "") ext? (rxo 0)) (letn (
  obs (if
    (find path '("." ".." "/" "")) ""
    (regex {([^/]*)\z} path) $1
    "")
  bs obs
  )
  (unless (or (empty? xext) (empty? bs))
    (replace
      (if (= xext ".*")
        {(?<!\A)(\.[^.]*)\z}
        (format {(?<!\A)(%s)\z} (replace "." xext "\\.")))
      bs "" rxo))
  (if ext?
    (list bs (if (= bs obs) "" $1))
    bs)))
