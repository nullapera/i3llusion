#!/usr/bin/env -S newlisp -n -c
;; vim:ts=2:sw=2:et:
;;
(silent)
(setq socket
      (net-connect (replace {/[^/]+\z} (env "I3SOCK") "/i3llusion.ipc" 0)))
(when socket
  (net-send socket (main-args -1))
  (net-close socket))
(exit)
