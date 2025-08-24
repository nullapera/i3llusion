;; vim:ts=2:sw=2:et:
;;
;;  (require "Cmd")
;;
;;  (:run (Cmd "/path/cmd" a1 a2 a3 a4) b1 b2 b3 b4) =>
;;    (exec "/path/cmd a1 b1 a2 b2 a3 b3 a4 b4")
;;
;;  (:run (Cmd "/path/cmd" (a1 a2) (a3 a4)) (b1 b2) (b3 b4)) =>
;;    (exec "/path/cmd a1 a2 b1 b2 a3 a4 b3 b4")
;;
(require "isa" "splat")

(context 'Cmd)

(constant
  '.CMD 1
  '.ARGS 2
  '.LENGTH 3)

(define (Cmd:Cmd apath)
  (list (context)
        (if (isa apath MAIN:Path) (:path apath) apath)
        (args)
        (length (args))))

(define (dry-run) (let (
  lngth (length (args))
  )
  (join (cons (self .CMD) (map string (flat
    (map list
      (if (< (self .LENGTH) lngth)
        (append (self .ARGS) (dup '() (- lngth (self .LENGTH))))
        (self .ARGS))
      (args)))))
    " ")))

(define (run)
  (exec (splat dry-run (args))))
