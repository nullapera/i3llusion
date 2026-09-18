;; vim:ts=2:sw=2:et:
;;
;;  (require "dirname")
;;
;;  (dirname "/p1/p2/p3/base.ext") => "/p1/p2/p3"
;;  (dirname "/p1/p2/p3/base.ext" true) => ("/p1/p2/p3" "base.ext")
;;
(context 'dirname)

(define(dirname:dirname path isbase)
  (let (rslt (if (find path '("." ".." "/" "")) (list path "")
                 (regex {\A(.+)/([^/]*)\z} path) (list $1 $2)
                 (= (first path) "/") (list (pop path) path)
                 '("." "")))
  (if isbase rslt (first rslt))))
