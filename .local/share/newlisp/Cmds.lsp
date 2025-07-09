;; vim:ts=2:sw=2:et:
;;
;;  (require "Cmds")
;;
;;  (:run (Cmds
;;    (Cmd "/path/cmd" a1 a2 a3 a4)
;;    (Cmd "/path/cmd" c1 c2 c3 c4))
;;    (b1 b2 b3 b4) (d1 d2 d3 d4)) =>
;;      (exec "/path/cmd a1 b1 a2 b2 a3 b3 a4 b4")
;;      (exec "/path/cmd c1 d1 c2 d2 c3 d3 c4 d4")
;;
;;  (:run (Cmds
;;    (Cmd "/path/cmd" (a1 a2) (a3 a4))
;;    (Cmd "/path/cmd" (c1 c2) (c3 c4))
;;    ((b1 b2) (b3 b4)) ((d1 d2) (d3 d4))) =>
;;      (exec "/path/cmd a1 a2 b1 b2 a3 a4 b3 b4")
;;      (exec "/path/cmd c1 c2 d1 d2 c3 c4 d3 d4")
;;
(require "Cmd")

(context 'Cmds)

(constant
  '.CMDS 1)

(define (Cmds:Cmds)
  (list (context)
        (args)))

(define (dry-run)
  (map (fn (cmd lst)
          (eval (append '(: Cmd:dry-run cmd) (if lst (quote lst) '()))))
       (self .CMDS)
       (args)))

(define (run)
  (map exec (splat dry-run (args))))
