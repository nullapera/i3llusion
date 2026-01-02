;; vim:ts=2:sw=2:et:
;;
;;  (require "basename")
;;
;;  (basename "/p1/p2/p3/base.ext") => "base.ext"
;;  (basename "/p1/p2/p3/base.ext" ".ext") => "base"
;;  (basename "/p1/p2/p3/base.Ext" ".ext") => "base.Ext"
;;  (basename "/p1/p2/p3/base.Ext" ".ext" nil 1) => "base"
;;  (basename "/p1/p2/p3/base.any" ".*") => "base"
;;  (basename "/p1/p2/p3/base.any" ".*" true) => ("base" ".any")
;;
(context 'basename)

(define (basename:basename path xext ext? (rxo 0)) (let (
  xt ""
  bs (if
    (find path '("." ".." "/" ""))
    ""
    (regex {([^/]*)\z} path)
    $1
    "")
  )
  (when (and xext (!= bs ""))
    (replace
      (if (= xext ".*")
        {(?<!\A)(\.[^.]*)\z}
        (format {(?<!\A)(\%s)\z} xext))
      bs "" rxo)
    (setq xt $1))
  (if ext?
    (if (!= bs xt) (list bs xt) (list bs ""))
    bs)))

