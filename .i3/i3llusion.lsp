#!/usr/bin/env -S newlisp -c -w ${HOME}/.i3
;; vim:ts=2:sw=2:et:
;;
;; CodeName: Still-Half-Ready.
;; Happy Friendly Hacking!
;;
(silent)
(set-locale "C" 1) ;decimal dot

(require "isinPATH")
(isinPATH true
  "notify-send" "picom" "pkill" "ps" "redshift" "systemctl"
  "xautolock" "xprop" "xset")

(require
  "Flags" "Cmds" "Cycle" "Path+" "Slider" "permutations"
  "case-match" "i3llusion/i3ipc")

(context 'i3llusion)

(setq
  myname (string (context))
  i3sock (Path (env "I3SOCK"))
  i3ipcpath (:with-filename! (copy i3sock) (append myname ".ipc")))

(let (
  selfpid (sys-info 7)
  pids (find-all
    (append myname ".lsp")
    (exec {ps -C newlisp -o pid,args})
    (int (first (parse $it)))
    find)
  )
  (map destroy (clean (curry = selfpid) pids))
  (when (:file? i3ipcpath)
    (unless (:delete-file i3ipcpath)
      (throw-error (append "Can not be deleted! : '"
                           (:path i3ipcpath) "'")))))

(setq
  scratcheds '()
  ipc (i3ipc i3sock)
  ipc4sub (i3ipc i3sock)
  colors (Cycle (map (fn (a) (join (cons "#" a)))
                     (permutations 3 '("8" "a" "c" "f"))))
  i3path (Path (append (real-path) "/"))
  i3memo (:with-filename! (copy i3path) (append myname "-memo.dat"))
  i3cond (:with-filename! (copy i3path) (append myname "-cond.dat"))
  notify (Cmd {notify-send} "-u" myname)
  xprop (Cmd {xprop}
    "-format I3_FLOATING_WINDOW 32c -set I3_FLOATING_WINDOW 1 -id"))

(setq
  ; M: Mode
  M:flx (Flags 4 0 1 1)
  M:memo '()
  M:cycle (Cycle '((0 0 0 1) (0 0 1 1) (0 1 0 1) (0 1 1 1)))
  M:texts '(
    "m" "Mode: UnFloating"
    "m+" "Mode: UnFloatingMemo"
    "M" "Mode: Floating"
    "M+" "Mode: FloatingMemo")
  ; P: Position
  P:flx (Flags 4)
  P:y 0
  P:height 0
  P:cycle (Cycle '("center" "mouse" "upside"))
  ; N: Nightlight
  N:flx (Flags 4 0 1)
  N:on (Cmd {redshift} "-v -r -P -o -m randr -l 48.25:20.63 -t 6400:5400 2>&1")
  N:off (Cmd {redshift} "-x -m randr")
  N:manual (Cmd {redshift} "-r -P -m randr -O")
  N:slider (Slider 6400 2400 6400 50)
  N:texts '(
    "n" "Nightlight: Off"
    "N" "Nightlight:"
    nil nil
    "!N" "!Nightlight")
  ; C: Compositor
  C:flx (Flags 4 0 1)
  C:on (Cmd {picom} "-b --config"
    (:path (:with-filename! (copy i3path) (append myname "-picom.conf"))))
  C:off (Cmd {pkill} "picom")
  C:texts '("c" "Compositor: Off" "C" "Compositor: On")
  ; Z: snooZe
  Z:flx (Flags 4 0 1)
  Z:fullscreen_mode 0
  Z:date-value0 (date-value)
  Z:remtime 0.0
  Z:on (Cmds
    (Cmd {xset} "s 360 360 dpms 480 480 480")
    (Cmd {xautolock} "-enable"))
  Z:off (Cmds
    (Cmd {xset} "s off -dpms")
    (Cmd {xautolock} "-disable"))
  Z:lock (Cmd {xautolock} "-locknow")
  Z:systemctl (Cmd {systemctl})
  Z:slider (Slider 40 2 80 1)
  Z:cycle (Cycle '("suspend" "hibernate" "poweroff")))

(let (
  path (:path (:with-filename! (copy i3path) (append myname "-msg.lsp")))
  )
  (setq letters_fmt (append
    "%%{A1:" path " %s_1:}"
    "%%{A2:" path " %s_2:}"
    "%%{A3:" path " %s_3:}"
    "%%{A4:" path " %s_4:}"
    "%%{A5:" path " %s_5:}"
    "%%{F%s} %s "
    "%%{A}%%{A}%%{A}%%{A}%%{A}")))

(define BoX:BoX)
(define PRoP:PRoP)
(define ReCT:ReCT)

(define polybar_pid
  (spawn 'polybar_spawn
    (let (
      conn nil
      data nil
      parent_pid (sys-info 6)
      socket (net-listen (:path i3ipcpath))
      )
      (while true
        (setq conn (net-accept socket))
        (until (net-select conn "r" 30000))
        (net-receive conn data 256)
        (net-close conn)
        (send parent_pid data)))
    true))

(define (letters2polybar) (let (
  letters '()
  envelope (lambda (letter text)
    (push (format letters_fmt letter letter letter letter letter
                  (:at colors) text)
          letters -1))
  )
  (:step colors -1)
  (envelope "M" (M:texts (:to-int M:flx 1 3)))
  (envelope "P_a"
    (if (:b P:flx 3)
      "Position:"
      (append "P" (first (:at P:cycle)))))
  (when (:b P:flx 3)
    (envelope "P_b" (:at P:cycle)))
  (envelope "N_a" (N:texts (:to-int N:flx '(0 1 3))))
  (when (and (:b N:flx 3) (:b N:flx 1))
    (envelope "N_b" (format {%dK} (:value N:slider))))
  (envelope "C" (C:texts (:to-int C:flx '(1 3))))
  (envelope "Z_a"
    (case (:to-int Z:flx '(1 3))
      (3 "snooZe: lock")
      (2 (format {Z%.1f} Z:remtime))
      (1 "snooZe: unlock")
      (0 (format {z%.1f} Z:remtime))))
  (when (:b Z:flx 3)
    (envelope "Z_b" (format {<  %.1fhrs} (div (:value Z:slider) 10)))
    (envelope "Z_c" (append "<  " (:at Z:cycle))))
  (write-line 1 (join letters))))

(define (kelvinize)
  (:value! N:slider (int (last (parse (nth -2 (:run N:on)))))))

(define (systemctl cmd)
  (:run Z:systemctl cmd)
  (timer (fn () (:run Z:lock) (setq Z:date-value0 (date-value)) (remit)) 10))

(define (remtime)
  (setq Z:remtime
    (div (- (:value Z:slider)
            (/ (- (date-value) Z:date-value0) 360))
         10))
  (if
    (<= Z:remtime)
    (systemctl (:at Z:cycle))
    (<= Z:remtime 0.2)
    (:run notify {critical}
      (append "'snooZe: Close to " (:at Z:cycle) "!'"))))

(define (post-outs) (let (
  flag true
  lst (list
    (:to-nums M:flx) (:to-nums P:flx) (:to-nums N:flx)
    (:to-nums C:flx) (:to-nums Z:flx) (:index P:cycle)
    (:value N:slider) (:value Z:slider) (:index Z:cycle))
  )
  (unless (:write-file i3memo (string M:memo))
    (setq flag nil)
    (:run notify {critical}
      (append "'post-outs: Can not write to " (:path i3memo) "!'")))
  (unless (:write-file i3cond (join (map string lst) "\n"))
    (setq flag nil)
    (:run notify {critical}
      (append "'post-outs: Can not write to " (:path i3cond) "!'")))))

(define (post-ins) (local (
  data
  )
  (when (:file? i3memo)
    (if (setq data (:read-file i3memo))
      (setq M:memo (read-expr data))
      (:run notify {critical}
        (append "'post-ins: Can not read from " (:path i3memo) "!'"))))
  (when (:file? i3cond)
    (if (setq data (:read-file i3cond))
      (let (
        lst (parse data "\n")
        )
        (dolist (e '(M P N C Z))
          (:set* (context e 'flx) (read-expr (lst $idx))))
        (:set-to M:cycle (setf (nth 3 (:to-nums M:flx)) 1))
        (:at P:cycle (int (lst 5)))
        (when (:b N:flx 0)
          (:run N:manual (string (:value! N:slider (int (lst 6))))))
        (when (:b C:flx 1)
          (:run C:on))
        (:value! Z:slider (int (lst 7)))
        (when (:b Z:flx 1)
          (:run Z:on))
        (:at Z:cycle (int (lst 8))))
      (:run notify {critical}
        (append "'post-ins: Can not read from " (:path i3cond) "!'"))))))

(define (remit)
  (when (and (:b N:flx 1) (not (:b N:flx 0)))
    (kelvinize))
  (post-outs)
  (remtime)
  (letters2polybar)
  (timer 'remit 360))

(define (propeller) (let (
  x nil
  lst '()
  json (json-parse (:gettree ipc))
  )
  (dolist (e (ref-all '("scratchpad_state" ?) json match))
    (when (!= (json (append e '(1))) "none")
      (setq x (first (lookup "nodes" (json (slice e 0 -1)))))
      (push (lookup "window" x) lst -1)))
  (when lst (let (
    fcsd (json (slice (ref '("focused" true) json match) 0 -1))
    )
    (if (= (lookup "type" fcsd) "con")
      (let (
        fwid (lookup "window" fcsd)
        ffon (ends-with (lookup "floating" fcsd) "on")
        )
        (setq lst (clean (curry = fwid) lst)
              scratcheds (difference scratcheds (difference scratcheds lst))
              x (difference lst scratcheds))
        (when lst
          (if x
            (setq x (first x))
            (setq x (first lst)
                  scratcheds '()))
          (push fwid scratcheds -1)
          (:command-wid ipc fwid (string "swap container with id " x))
          (:command-wid ipc x
            (if ffon
              "border normal 6, floating enable"
              "border none, floating disable"))
          (when ffon
            (:run xprop (string x)))))
      (:command ipc "scratchpad show"))))))

(define (lettershop stamp) (local (
  flag
  )
  (case-match (r (parse stamp "_") r)
    ('("M" "4")
      (when (:b M:flx 3)
        (:step M:cycle +1)
        (:set* M:flx (:at M:cycle))))
    ('("M" "5")
      (when (:b M:flx 3)
        (:step M:cycle -1)
        (:set* M:flx (:at M:cycle))))
    ('("M" ?)
      (:not! M:flx (int (first r)))
      (:set-to M:cycle (:to-nums M:flx)))
    ('("P" ? "3") (:not! P:flx 3))
    ('("P" "b" "4") (:step P:cycle +1))
    ('("P" "b" "5") (:step P:cycle -1))
    ('("N" ? "1")
      (:flag N:flx 0 nil)
      (if (:not! N:flx 1)
        (kelvinize)
        (:run N:off)))
    ('("N" ? "2")
      (when (:b N:flx 0)
        (kelvinize)
        (:flag N:flx 0 nil)))
    ('("N" ? "3") (:not! N:flx 3))
    ('("N" "b" "4")
      (:flag N:flx 0 true)
      (:run N:manual (string (:step N:slider +1))))
    ('("N" "b" "5")
      (:flag N:flx 0 true)
      (:run N:manual (string (:step N:slider -1))))
    ('("C" "1") (:run (if (:not! C:flx 1) C:on C:off)))
    ('("C" "3") (:not! C:flx 3))
    ('("Z" ? "1") (:run (if (:not! Z:flx 1) Z:on Z:off)))
    ('("Z" ? "2")
      (setq Z:date-value0 (date-value))
      (timer 'remit 360)
      (remtime))
    ('("Z" ? "3") (:not! Z:flx 3))
    ('("Z" "b" "4")
      (:step Z:slider +1)
      (setq Z:date-value0 (date-value))
      (timer 'remit 360)
      (remtime))
    ('("Z" "b" "5")
      (:step Z:slider -1)
      (setq Z:date-value0 (date-value))
      (timer 'remit 360)
      (remtime))
    ('("Z" "c" "4") (:step Z:cycle +1))
    ('("Z" "c" "5") (:step Z:cycle -1))
    ('("X" "8") (setq flag true))
    ('("X" "postouts")
      (when (post-outs)
        (:run notify {normal} "'post-outs: saved by request!'")))
    ('("X" "propeller") (propeller))
    ('("X" "polytoggle") (on-workspace-focus))
    ('("X" ?) (systemctl (first r))))
  flag))

(define (go2position (lt1 0))
  (append "move position "
    (if (= (:at P:cycle) "upside")
      (let (
        yo (mul P:height lt1)
        )
        (ReCT BoX:_rect)
        (format {%d px %d px}
          ReCT:_x
          (if
            (<= ReCT:_height (- P:height yo))
            (+ P:y yo)
            (<= P:height ReCT:_height)
            P:y
            (- (+ P:y P:height) ReCT:_height))))
      (:at P:cycle))))

(define (check-wcwi) (let (
  flag nil
  json (json-parse (:gettree ipc))
  )
  (dolist (e (ref-all '("window_properties" ?) json match true) flag)
    (setq flag (and (= PRoP:_class (lookup "class" (e 1)))
                    (!= PRoP:_instance (lookup "instance" (e 1))))))))

(define (on-close)
  (when (:b M:flx 2)
    (PRoP BoX:_window_properties)
    (letn (
      rec (list PRoP:_class PRoP:_instance (:n M:flx 1))
      idx (find rec M:memo)
      )
      (case-match (r (list (:n M:flx 1) (true? idx) BoX:_floating) r)
        ('(1 true "user_on") (pop M:memo idx))
        ('(1 nil "user_off") (push rec M:memo -1))
        ('(0 true "user_off") (pop M:memo idx))
        ('(0 nil "user_on") (push rec M:memo -1))))))

(define (on-fullscreen)
  (when (:b Z:flx 1)
    (case-match (r (cons BoX:_fullscreen_mode Z:fullscreen_mode) r)
      ('(1 0) (:run Z:off)
              (setq Z:fullscreen_mode 1))
      ('(0 1) (:run Z:on)
              (setq Z:fullscreen_mode 0)))))

(define (on-floating)
  (if (or (= BoX:_window_type "normal")
          (= BoX:_window_type "unknown"))
    (:command-wid ipc BoX:_window
      (if (ends-with BoX:_floating "on")
        (append "border normal 6, " (go2position))
        "border none"))
    (when (and (= (:at P:cycle) "upside")
               (ends-with BoX:_floating "on"))
      (:command-wid ipc BoX:_window (go2position 0.1)))))

(define (on-new)
  (when (or (= BoX:_window_type "normal")
            (= BoX:_window_type "unknown"))
    (PRoP BoX:_window_properties)
    (letn (
      rec (list PRoP:_class PRoP:_instance (:n M:flx 1))
      fnd (true? (find rec M:memo))
      )
      (case-match (r (list (:n M:flx 1) (:n M:flx 2) fnd) r)
        ('(1 1 true)
          (:command-wid ipc BoX:_window "floating disable"))
        ('(0 1 true)
          (:command-wid ipc BoX:_window "floating enable"))
        ('(1 ? ?)
          (:command-wid ipc BoX:_window "floating enable"))
        ('(*)
          (:command-wid ipc BoX:_window
            (if (check-wcwi)
              "floating enable"
              "floating disable")))))))

(define (on-move)
  (when (!= BoX:_scratchpad_state "none") (let (
    lst (first BoX:_nodes)
    )
    (BoX lst)
    (on-new)
    (on-floating)
    (when (ends-with BoX:_floating "on")
      (:run xprop (string BoX:_window))))))

(define (on-workspace-focus) (letn (
  json (json-parse (:getworkspaces ipc))
  fcsd (json (slice (ref '("focused" true) json match) 0 -1))
  )
  (ReCT (lookup "rect" fcsd))
  (setq P:y ReCT:_y
        P:height ReCT:_height)))

; main loop
(local (
  flag data json
  )
  (:run C:off)
  (:run Z:off)
  (:subscribe ipc4sub {[ "window", "workspace" ]})
  (post-ins)
  (remit)
  (on-workspace-focus)
  (until flag
    (until (net-select (:socket ipc4sub) "r" 20000)
      (dolist (child_pid (receive))
        (receive child_pid data)
        (when (= child_pid polybar_pid)
          (setq flag (lettershop data))
          (letters2polybar))))
    (setq data (:receive ipc4sub)
          json (json-parse data))
    (if (setq data (lookup "container" json))
      (begin
        (BoX data)
        (case (lookup "change" json)
          ("focus" (on-fullscreen))
          ("new" (on-new))
          ("floating" (on-floating))
          ("close" (on-close))
          ("move" (on-move))
          ("fullscreen_mode" (on-fullscreen))))
      (when (setq data  (lookup "current" json))
        (case (lookup "change" json)
          ("focus" (on-workspace-focus))))))
  (:close ipc)
  (:close ipc4sub))

(abort)
(exit)
