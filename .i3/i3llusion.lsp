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

(require "Path+")

(context 'i3llusion)

(setq
  myname (string (context))
  i3sock (Path (env "I3SOCK"))
  i3ipcpath (:this-filename! (copy i3sock) (append myname ".ipc")))

(let (
  selfpid (sys-info 7)
  pids (find-all
    (append myname ".lsp")
    (exec {ps -C newlisp -o pid,args})
    (int (first (parse $it)))
    find)
  )
  (map destroy (replace selfpid pids))
  (when (:file? i3ipcpath)
    (unless (:delete-file i3ipcpath)
      (throw-error (append "Can not be deleted! : '"
                           (:path i3ipcpath) "'")))))

(require
  "Flags" "Cmds" "Cycle" "Slider" "permutations"
  "case-match" "rebox" "mutuple" "i3llusion/i3ipc")

(setq
  scratcheds '()
  ipc (i3ipc i3sock)
  ipc4sub (i3ipc i3sock)
  colors (Cycle (map
    (fn (a) (join (cons "#" a)))
    (permutations 3 '("8" "a" "c" "f"))))
  i3path (Path (append (real-path) "/"))
  i3memo (:this-filename! (copy i3path) (append myname "-memo.dat"))
  i3cond (:this-filename! (copy i3path) (append myname "-cond.dat"))
  notify (Cmd {notify-send} "-u" myname)
  xprop (Cmd {xprop}
    "-format I3_FLOATING_WINDOW 32c -set I3_FLOATING_WINDOW 1 -id")
  tix (begin
    (mutuple {TX} "counter limit func")
    (rebox {TX} '(
      ([] "kelvin" MAIN:TX 0 60
          (when (and (:b N:flx 1) (not (:b N:flx 0)))
            (kelvinize)))
      ([] "pouts" MAIN:TX 0 60 (post-outs))
      ([] "snooze" MAIN:TX 60 60 (begin (-- Z:timecounter) (checktime)))))))

(macro (@kelvin) (tix TX:_kelvin))
(macro (@snooze) (tix TX:_snooze))

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
    (:path (:this-filename! (copy i3path) (append myname "-picom.conf"))))
  C:off (Cmd {pkill} "picom")
  C:texts '("c" "Compositor: Off" "C" "Compositor: On")
  ; Z: snooZe
  Z:flx (Flags 4 0 1)
  Z:fullscreen_mode 0
  Z:timelimit 80
  Z:timecounter 80
  Z:on (Cmds
    (Cmd {xset} "s 360 360 dpms 480 480 480")
    (Cmd {xautolock} "-enable"))
  Z:off (Cmds
    (Cmd {xset} "s off -dpms")
    (Cmd {xautolock} "-disable"))
  Z:lock (Cmd {xautolock} "-locknow")
  Z:systemctl (Cmd {systemctl})
  Z:cycle (Cycle '("suspend" "hibernate" "poweroff")))

(let (path (:path (:this-filename! (copy i3path) (append myname "-msg.lsp"))))
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
  (if (:b Z:flx 3)
    (begin
      (envelope "Z_a" (if (:b Z:flx 1) "snooZe: lock" "snooZe: unlock"))
      (envelope "Z_b" (format {<  %.1fhrs} (div Z:timelimit 10)))
      (envelope "Z_c" (append "<  " (:at Z:cycle))))
    (envelope "Z_d"
      (format (if (:b Z:flx 1) {Z%.1f} {z%.1f}) (div Z:timecounter 10))))
  (write-line 1 (join letters))))

(define (kelvinize)
  (:value! N:slider (int ((parse ((:run N:on) -2)) -2))))

(define (systemctl cmd)
  (:run Z:systemctl cmd)
  (timer (fn ()
    (:run Z:lock)
    (setq Z:timecounter Z:timelimit)
    (:counter! (@snooze) (:limit (@snooze)))
    (:counter! (@kelvin) 0)
    (remit)) 6))

(define (checktime)
  (if
    (<= Z:timecounter)
    (systemctl (:at Z:cycle))
    (<= Z:timecounter 2)
    (:run notify {critical}
      (append "'snooZe: Close to " (:at Z:cycle) "!'"))))

(define (post-outs) (let (
  flag true
  lst (list
    (:to-nums M:flx) (:to-nums P:flx) (:to-nums N:flx)
    (:to-nums C:flx) (:to-nums Z:flx) (:index P:cycle)
    (:value N:slider) Z:timelimit (:index Z:cycle))
  )
  (unless (:write-file i3memo (string M:memo))
    (setq flag nil)
    (:run notify {critical}
      (append "'post-outs: Can not write to " (:path i3memo) "!'")))
  (unless (:write-file i3cond (join (map string lst) "\n"))
    (setq flag nil)
    (:run notify {critical}
      (append "'post-outs: Can not write to " (:path i3cond) "!'")))
  flag))

(define (post-ins) (local (data)
  (when (:file? i3memo)
    (if (setq data (:read-file i3memo))
      (setq M:memo (read-expr data))
      (:run notify {critical}
        (append "'post-ins: Can not read from " (:path i3memo) "!'"))))
  (when (:file? i3cond)
    (if (setq data (:read-file i3cond))
      (let (lst (parse data "\n"))
        (dolist (e '(M P N C Z))
          (:set* (context e 'flx) (read-expr (lst $idx))))
        (:set-to M:cycle (setf (nth 3 (:to-nums M:flx)) 1))
        (:at P:cycle (int (lst 5)))
        (when (:b N:flx 0)
          (:run N:manual (string (:value! N:slider (int (lst 6))))))
        (when (:b C:flx 1)
          (:run C:on))
        (setq Z:timelimit (int (lst 7))
              Z:timecounter Z:timelimit)
        (when (:b Z:flx 1)
          (:run Z:on))
        (:at Z:cycle (int (lst 8))))
      (:run notify {critical}
        (append "'post-ins: Can not read from " (:path i3cond) "!'"))))))

(define (remit) (local (
  i flag
  )
  (dotree (e TX true)
    (setq i (eval e))
    (when (<= (:counter! (tix i) --))
      (:counter! (tix i) (:limit (tix i)))
      (eval (:func (tix i)))
      (setq flag true)))
  (when flag
    (letters2polybar))
  (timer 'remit 6)))

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
        (setq lst (replace fwid lst)
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

(define (toggle-memo) (letn (
  json (json-parse (:gettree ipc))
  fcsd (json (slice (ref '("focused"  true) json match) 0 -1))
  )
  (when (= (lookup "type" fcsd) "con")
    (BoX fcsd)
    (PRoP BoX:_window_properties)
    (letn (
      rec (list PRoP:_class PRoP:_instance (:n M:flx 1))
      idx (find rec M:memo)
      )
      (case-match (r (list (:n M:flx 1) (true? idx) BoX:_floating) r)
        ('(1 true "user_on") (pop M:memo idx))
        ('(1 nil "user_off") (push rec M:memo))
        ('(0 true "user_off") (pop M:memo idx))
        ('(0 nil "user_on") (push rec M:memo)))))))

(define (lettershop stamp) (letn (
  flag nil
  tail (parse stamp "_")
  head (pop tail)
  )
  (case head
    ("M" (case (tail 0)
      ("4" (when (:b M:flx 3)
        (:step M:cycle +1)
        (:set* M:flx (:at M:cycle))))
      ("5" (when (:b M:flx 3)
        (:step M:cycle -1)
        (:set* M:flx (:at M:cycle))))
      (true
        (:not! M:flx (int (tail 0)))
        (:set-to M:cycle (:to-nums M:flx)))))
    ("P" (case-match (r tail r)
      ('(? "3") (:not! P:flx 3))
      ('("b" "4") (:step P:cycle +1))
      ('("b" "5") (:step P:cycle -1))))
    ("N" (case-match (r tail r)
      ('(? "1")
        (:flag N:flx 0 nil)
        (if (:not! N:flx 1)
          (begin
            (:counter! (@kelvin) (:limit (@kelvin)))
            (kelvinize))
          (:run N:off)))
      ('(? "2") (when (:b N:flx 0)
        (:counter! (@kelvin) (:limit (@kelvin)))
        (kelvinize)
        (:flag N:flx 0 nil)))
      ('(? "3") (:not! N:flx 3))
      ('("b" "4")
        (:flag N:flx 0 true)
        (:run N:manual (string (:step N:slider +1))))
      ('("b" "5")
        (:flag N:flx 0 true)
        (:run N:manual (string (:step N:slider -1))))))
    ("C" (case (tail 0)
      ("1" (:run (if (:not! C:flx 1) C:on C:off)))
      ("3" (:not! C:flx 3))))
    ("Z" (case-match (r tail r)
      ('(? "1") (:run (if (:not! Z:flx 1) Z:on Z:off)))
      ('(? "2")
        (setq Z:timecounter Z:timelimit)
        (:counter! (@snooze) (:limit (@snooze)))
        (checktime))
      ('(? "3") (:not! Z:flx 3))
      ('("b" "4") (++ Z:timelimit))
      ('("b" "5") (setq Z:timelimit (max (-- Z:timelimit) 2)))
      ('("c" "4") (:step Z:cycle +1))
      ('("c" "5") (:step Z:cycle -1))
      ('("d" "4")
        (++ Z:timecounter)
        (:counter! (@snooze) (:limit (@snooze))))
      ('("d" "5")
        (-- Z:timecounter)
        (:counter! (@snooze) (:limit (@snooze)))
        (checktime))))
    ("X" (case (tail 0)
      ("8" (setq flag true))
      ("postouts" (when (post-outs)
        (:run notify {normal} "'post-outs: saved by request!'")))
      ("propeller" (propeller))
      ("polytoggle" (on-workspace-focus))
      ("togglememo" (toggle-memo))
      (true (systemctl (tail 0))))))
  flag))

(define (go2position (lt1 0))
  (append "move position "
    (if (= (:at P:cycle) "upside")
      (let (yo (mul P:height lt1))
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
(local (flag data json)
  (map delete '(isinPATH permutations mutuple rebox))
  (:run C:off)
  (:run Z:off)
  (:subscribe ipc4sub {[ "window", "workspace" ]})
  (post-ins)
  (remit)
  (on-workspace-focus)
  (until flag
    (until (net-select (:socket ipc4sub) "r" 10000)
      (dolist (child_pid (receive))
        (receive child_pid data)
        (when (= child_pid polybar_pid)
          (setq flag (lettershop data))
          (letters2polybar))))
    (setq data (:receive ipc4sub)
          json (json-parse data))
    (if (setq data (lookup "container" json))
      (case (lookup "change" json)
        ("focus" (BoX data) (on-fullscreen))
        ("new" (BoX data) (on-new))
        ("floating" (BoX data) (on-floating))
        ("move" (BoX data) (on-move))
        ("fullscreen_mode" (BoX data) (on-fullscreen)))
      (when (setq data  (lookup "current" json))
        (case (lookup "change" json)
          ("focus" (on-workspace-focus))))))
  (:close ipc)
  (:close ipc4sub))

(abort)
(exit)
