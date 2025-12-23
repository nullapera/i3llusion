;; vim:ts=2:sw=2:et:
;;
;;  (require "extname")
;;
;;  (extname "/p1/p2/p3/base.ext") => ".ext"
;;
(context 'extname)

(define (extname:extname path)
  (if
    (or (= "." path) (= ".." path) (= "/" path) (= "" path))
    ""
    (regex {(?<!/|\A)(\.[^.]*)\z} path)
    $1
    ""))

