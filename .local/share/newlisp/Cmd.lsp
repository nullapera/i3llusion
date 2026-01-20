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
(require "splat" "mesh")

(context 'Cmd)

(constant '.CMD 1 '.ARGS 2)

(define (Cmd:Cmd cmd) (list (context) cmd (args)))

(define (dry-run)
  (join (cons (self .CMD)
              (map string (flat (mesh (self .ARGS) (args)))))
        " "))

(define (run) (exec (splat dry-run (args))))
