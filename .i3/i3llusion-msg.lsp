#!/usr/bin/env -S newlisp -n -c
;; vim:ts=2:sw=2:et:
;;
(silent)
(setq socket (net-connect (join
  (push "i3llusion.ipc" (slice (parse (env "I3SOCK") "/") 0 -1) -1)
  "/" )))
(net-send socket (main-args -1))
(net-close socket)
(exit)
