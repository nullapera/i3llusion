;; vim:ts=2:sw=2:et:
;;
;;  (require "Path")
;;
;;  (setq p (Path "p1/p2/p3/base.ext")) =>
;;    (Path ("p1" "p2" "p3") ("base" "ext"))
;;
;;  (:dirname p) =>
;;    "p1/p2/p3/"
;;  (:dirname! p "P1/P2/P3/") =>
;;    "P1/P2/P3"
;;
;;  (:filename p) =>
;;    "base.ext"
;;  (:filename! p "Base.Ext") =>
;;    "Base.Ext"
;;
;;  (:basename p) =>
;;    "Base"
;;  (:basename! p upper-case) =>
;;    "BASE"
;;
;;  (:extname p) =>
;;    "Ext"
;;  (:extname! p "EXT")  =>
;;    "EXT"
;;
;;  (:path p) =>
;;    "P1/P2/P3/BASE.EXT"
;;
(require "isa")

(context 'Path.parse)

(define (slash arg) ; => ((dirparts) filename)
  (if (nil? arg)
    '((nil) nil)
    (let (
      lst (parse arg "/")
      )
      (if
        (empty? lst) '((nil) nil)
        (= '("" "") lst) '(("" "") nil)
        (= (length lst) 1) (list '(nil) (first lst))
        (list (slice lst 0 -1) (last lst))))))

(define (dot arg) ; => (basename extname)
  (if (nil? arg)
    '(nil nil)
    (let (
      lst (parse arg ".")
      )
      (if
        (empty? lst) '(nil nil)
        (= '("" "") lst) '("" "")
        (= (length lst) 1) (list arg nil)
        (list (join (slice lst 0 -1) ".") (last lst))))))


(context 'Path.join)

(define (slash arg)
  (if (nil? arg)
    ""
    (if
      (= '((nil) nil) arg) ""
      (or (= '(("" "") nil) arg) (= '(("" "") "") arg)) "/"
      (= '(nil) (first arg)) (first arg)
      (append (join (first arg) "/") "/" (last arg)))))

(define (dot arg)
  (if (nil? arg)
    ""
    (if
      (= '(nil nil) arg) ""
      (= '("" "") arg) "."
      (nil? (last arg)) (first arg)
      (append (first arg) "." (last arg)))))


(context 'Path)

(constant
  '.DIRNAME 1
  '.FILENAME 2
  '.BASENAME '(2 0)
  '.EXTNAME '(2 1))

(define (Path:Path arg) (letn (
  r1 (Path.parse:slash (if (nil? arg) (append (real-path) "/") arg))
  r2 (Path.parse:dot (last r1))
  )
  (list (context) (first r1) r2)))

(define (path)
  (Path.join:slash (list
    (self .DIRNAME)
    (Path.join:dot (self .FILENAME)))))

(define (dirname)
  (Path.join:slash (list (self .DIRNAME) "")))

(define (dirname! arg)
  (setf (self .DIRNAME)
        (if (isa arg MAIN:Path)
          (arg .DIRNAME)
          (if (or (primitive? arg) (lambda? arg))
            (arg (self .DIRNAME))
            (first (Path.parse:slash arg)))))
  (dirname))

(define (with-dirname! arg)
  (dirname! arg)
  (self))

(define (filename)
  (Path.join:dot (self .FILENAME)))

(define (filename! arg)
  (setf (self .FILENAME)
        (if (isa arg MAIN:Path)
          (arg .FILENAME)
          (Path.parse:dot
            (if (or (primitive? arg) (lambda? arg))
              (arg (Path.join:dot (self .FILENAME)))
              arg))))
  (filename))

(define (with-filename! arg)
  (filename! arg)
  (self))

(define (basename)
  (self .BASENAME))

(define (basename! arg)
  (setf (self .BASENAME)
        (if (isa arg MAIN:Path)
          (arg .BASENAME)
          (if (or (primitive? arg) (lambda? arg))
            (arg (self .BASENAME))
            arg)))
  (basename))

(define (with-basename! arg)
  (basename! arg)
  (self))

(define (extname)
  (self .EXTNAME))

(define (extname! arg)
  (setf (self .EXTNAME)
        (if (isa arg MAIN:Path)
          (arg .EXTNAME)
          (if (or (primitive? arg) (lambda? arg))
            (arg (self .EXTNAME))
            arg)))
  (extname))

(define (with-extname! arg)
  (extname! arg)
  (self))
