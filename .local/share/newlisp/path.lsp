;; vim:ts=2:sw=2:et:
;;
;;  (require "path")
;;
;;  (path:dir "/p1/p2/p3/base.ext") => "/p1/p2/p3"
;;  (path:dir "/p1/p2/p3/base.ext" true) => ("/p1/p2/p3" "base.ext")
;;  (path:base "/p1/p2/p3/base.ext") => "base.ext"
;;  (path:base "/p1/p2/p3/base.ext" ".ext") => "base"
;;  (path:base "/p1/p2/p3/base.Ext" ".ext") => "base.Ext"
;;  (path:base "/p1/p2/p3/base.Ext" ".ext" nil 1) => "base"
;;  (path:base "/p1/p2/p3/base.any" ".*") => "base"
;;  (path:base "/p1/p2/p3/base.any" ".*" true) => ("base" ".any")
;;  (path:ext "/p1/p2/p3/base.ext") => ".ext"
;;
(context 'path)

(define (dir pth base?) (let (
  rslt (if
    (or (= "." pth) (= ".." pth) (= "/" pth) (= "" pth))
    (list pth "")
    (regex {\A(.+)/([^/]*)\z} pth)
    (list $1 $2)
    (= (first pth) "/")
    (list (pop pth) pth)
    '("" ""))
  )
  (if base? rslt (first rslt))))

(define (base pth xext ext? (rxo 0)) (let (
  xt ""
  bs (if
    (or (= "." pth) (= ".." pth) (= "/" pth) (= "" pth))
    ""
    (regex {([^/]*)\z} pth)
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

(define (ext pth)
  (if
    (or (= "." pth) (= ".." pth) (= "/" pth) (= "" pth))
    ""
    (regex {(?<!/|\A)(\.[^.]*)\z} pth)
    $1
    ""))

