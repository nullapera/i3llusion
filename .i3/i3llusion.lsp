#!/usr/bin/env -S newlisp -c -w ${HOME}/.i3
;; vim:ts=2:sw=2:et:
;;
;; CodeName: Still-Half-Ready.
;; Happy Friendly Hacking!
;;
(silent)
(set-locale "C" 1) ; decimal dot

(require "isinPATH")
(isinPATH true
  "notify-send" "picom" "pkill" "ps" "redshift" "systemctl" "xprop" "xset")

(context 'i3llusion)

(require "dirname")

(setq
  myname (string (context))
  i3sock (env "I3SOCK")
  i3ipcpath (append (dirname i3sock) "/" myname ".ipc"))

(let (
  selfpid (sys-info 7)
  pids (find-all
    (append myname ".lsp")
    (exec {ps -C newlisp -o pid,args})
    (int (first (parse $it)))
    find)
  )
  (map destroy (replace selfpid pids))
  (when (file? i3ipcpath)
    (unless (delete-file i3ipcpath)
      (throw-error (append "Can not be deleted! : '" i3ipcpath "'")))))

(require
  "Flags" "Cmd" "Cycle" "Slider" "permutations" "case-match" "i3llusion/i3ipc")

(setq
  scratcheds '()
  ipc (i3ipc i3sock)
  ipc4sub (i3ipc i3sock)
  colors (Cycle (map
    (fn (a) (join (cons "#" a)))
    (permutations 3 '("8" "a" "c" "f"))))
  i3path (append (real-path) "/")
  i3memo (append i3path myname "-memo.dat")
  i3cond (append i3path myname "-cond.dat")
  notify (Cmd {notify-send} "-u" myname)
  xprop (Cmd {xprop}
    "-format I3_FLOATING_WINDOW 32c -set I3_FLOATING_WINDOW 1 -id"))

(setq ; M: Mode
  M:flx (Flags 4 0 1 1)
  M:memo '()
  M:cycle (Cycle '((0 0 0 1) (0 0 1 1) (0 1 0 1) (0 1 1 1)))
  M:texts '(
    "m" "Mode: UnFloating"
    "m+" "Mode: UnFloatingMemo"
    "M" "Mode: Floating"
    "M+" "Mode: FloatingMemo"))
(setq ; P: Position
  P:flx (Flags 4)
  P:y 0
  P:height 0
  P:cycle (Cycle '("center" "mouse" "upside")))
(setq ; N: Nightlight
  N:flx (Flags 4 0 1)
  N:on (Cmd {redshift} "-v -r -P -o -m randr -l 48.25:20.63 -t 6200:4200 2>&1")
  N:off (Cmd {redshift} "-x -m randr")
  N:manual (Cmd {redshift} "-r -P -m randr -O")
  N:slider (Slider 6400 2400 6400 50)
  N:tickcounter 0
  N:tickfunc (lambda ()
    (when (and (:b N:flx 1) (not (:b N:flx 0))) (make-kelvin)))
  N:texts '(
    "n" "Nightlight: Off"
    "N" "Nightlight:"
    nil nil
    "!N" "!Nightlight:"))
(setq ; C: Compositor
  C:flx (Flags 4 0 1)
  C:on (Cmd {picom} "-b --config" (append i3path myname "-picom.conf"))
  C:off (Cmd {pkill} "picom")
  C:texts '("c" "Compositor: Off" "C" "Compositor: On"))
(setq ; Z: snooZe
  Z:flx (Flags 4 0 1)
  Z:fullscreen_mode 0
  Z:timelimit 80
  Z:timecounter Z:timelimit
  Z:on (Cmd {xset} "s 360 360 dpms 480 600 720")
  Z:off (Cmd {xset} "s off -dpms")
  Z:tickcounter 60
  Z:tickfunc (lambda () (-- Z:timecounter) (checktime))
  Z:systemctl (Cmd {systemctl})
  Z:cycle (Cycle '("suspend" "hibernate" "poweroff")))
(setq ; A: Auto{save,memo}
  A:flx (Flags 6 0 1 0 0 1 1)
  A:tickcounter 0
  A:tickfunc (lambda () (when (and (:b A:flx 1) (:b A:flx 4)) (post-outs)))
  A:texts '("a" "a" "a" "a" "Asm" "AsM" "ASm" "ASM"))

(constant
  'BESIX 6 'TICKLIMIT (/ 3600 10 BESIX)
  'LETTERS (list M P N C Z A) 'TIX (list N Z A))

(let (path (append i3path myname "-msg.lsp"))
  (setq lettersfmt (append
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

(define polybarpid
  (spawn 'polybarspawn
    (let (
      conn nil
      data nil
      parentpid (sys-info 6)
      socket (net-listen i3ipcpath)
      )
      (while true
        (setq conn (net-accept socket))
        (until (net-select conn "r" 35000))
        (net-receive conn data 256)
        (net-close conn)
        (send parentpid data)))
    true))

(define (letters2polybar) (let (
  letters '()
  envelope (lambda (letter text) (push
    (format lettersfmt letter letter letter letter letter (:at colors) text)
    letters -1))
  )
  (:step colors -1)
  (envelope "M" (M:texts (:to-int M:flx 1 3)))
  (envelope "P_a"
    (if (:b P:flx 3)
      "Position:"
      (append "P" (first (:at P:cycle)))))
  (when (:b P:flx 3) (envelope "P_b" (:at P:cycle)))
  (envelope "N_a" (N:texts (:to-int N:flx '(0 1 3))))
  (when (and (:b N:flx 3) (:b N:flx 1))
    (envelope "N_b" (format {%dK} (:value N:slider))))
  (envelope "C" (C:texts (:to-int C:flx '(1 3))))
  (if (:b Z:flx 3)
    (begin
      (envelope "Z_a" (if (:b Z:flx 1) "snooZe: lock" "snooZe: UNlock"))
      (envelope "Z_b" (format {<  %.1fhrs} (div Z:timelimit 10)))
      (envelope "Z_c" (append "<  " (:at Z:cycle))))
    (envelope "Z_d"
      (format (if (:b Z:flx 1) {Z%.1f} {z%.1f}) (div Z:timecounter 10))))
  (if (:b A:flx 3)
    (begin
      (envelope "A_a" (if (:b A:flx 1) "Auto:" "Auto: Off"))
      (when (:b A:flx 1)
        (envelope "A_b" (if (:b A:flx 4) "SavE," "save,"))
        (envelope "A_c" (if (:b A:flx 5) "MemO" "memo"))))
    (envelope "A_a" (A:texts (:to-int A:flx '(1 4 5)))))
  (write-line 1 (join letters))))

(define (make-kelvin)
  (:value! N:slider (int ((parse ((:run N:on) -2)) -2))))

(define (systemctl cmd)
  (timer (fn ()
    (setq Z:timecounter Z:timelimit
          Z:tickcounter TICKLIMIT
          N:tickcounter 0)
    (remit)) BESIX)
  (when (and (:b A:flx 1) (:b A:flx 4))
    (post-outs)
    (setq A:tickcounter TICKLIMIT))
  (:run Z:systemctl cmd))

(define (checktime)
  (if
    (<= Z:timecounter 0)
    (systemctl (:at Z:cycle))
    (<= Z:timecounter 2)
    (:run notify {critical}
      (append "'snooZe: Close to " (:at Z:cycle) "!'"))))

(define (remit) (local (flag)
  (timer 'remit BESIX)
  (dolist (e TIX)
    (when (<= (-- e:tickcounter) 0)
      (setq e:tickcounter TICKLIMIT
            flag true)
      (e:tickfunc)))
  (when flag (letters2polybar))))

(define (post-outs) (let (
  flag true
  lst (append
    (map (fn (a) (:to-nums a:flx)) LETTERS)
    (list (:index P:cycle) (:value N:slider) Z:timelimit (:index Z:cycle)))
  )
  (unless (write-file i3memo (string M:memo))
    (setq flag nil)
    (:run notify {critical}
      (append "'post-outs: Can not write to " i3memo "!'")))
  (unless (write-file i3cond (join (map string lst) "\n"))
    (setq flag nil)
    (:run notify {critical}
      (append "'post-outs: Can not write to " i3cond "!'")))
  flag))

(define (post-ins)
  (when (file? i3memo)
    (if (read-file i3memo)
      (set 'M:memo (read-expr $it))
      (:run notify {critical}
        (append "'post-ins: Can not read from " i3memo "!'"))))
  (when (file? i3cond)
    (if (read-file i3cond)
      (let (lst (parse $it "\n"))
        (dolist (e LETTERS)
          (:set-from e:flx (read-expr (pop lst))))
        (:set-to M:cycle (setf (nth 3 (:to-nums M:flx)) 1))
        (:at! P:cycle (int (pop lst)))
        (if (:b N:flx 0)
          (:run N:manual (string (:value! N:slider (int (pop lst)))))
          (pop lst))
        (when (:b C:flx 1) (:run C:on))
        (setq Z:timelimit (int (pop lst))
              Z:timecounter Z:timelimit)
        (when (:b Z:flx 1) (:run Z:on))
        (:at! Z:cycle (int (pop lst))))
      (:run notify {critical}
        (append "'post-ins: Can not read from " i3cond "!'")))))

(define (propeller) (let (
  x nil
  lst '()
  json (json-parse (:gettree ipc))
  )
  (dolist (e (ref-all '("scratchpad_state" ?) json match))
    (unless (= (json (append e '(1))) "none")
      (setq x (first (lookup "nodes" (json (0 -1 e)))))
      (push (lookup "window" x) lst -1)))
  (when lst (letn (
    rf (ref '("focused" true) json match)
    fcsd (when rf (json (0 -1 rf)))
    )
    (if (and fcsd (= (lookup "type" fcsd) "con"))
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
              "border pixel 6, floating enable"
              "border none, floating disable"))
          (when ffon (:run xprop (string x)))))
      (:command ipc "scratchpad show"))))))

(define (toggle-memo) (letn (
  json (json-parse (:gettree ipc))
  rf (ref '("focused" true) json match)
  fcsd (when rf (json (0 -1 rf)))
  )
  (when (and fcsd (= (lookup "type" fcsd) "con"))
    (BoX fcsd)
    (PRoP BoX:_window_properties)
    (letn (
      rec (list PRoP:_class PRoP:_instance (:b M:flx 1))
      idx (find rec M:memo)
      r (list (:b M:flx 1) (true? idx) BoX:_floating)
      )
      (if
        (= '(true true "user_on") r) (pop M:memo idx)
        (= '(true nil "user_off") r) (push rec M:memo)
        (= '(nil true "user_off") r) (pop M:memo idx)
        (= '(nil nil "user_on") r) (push rec M:memo))))))

(define (lettershop stamp) (letn (
  flag nil
  tail (parse stamp "_")
  head (pop tail)
  )
  (case head
    ("M" (case (first tail)
      ("4" (when (:b M:flx 3)
        (:step M:cycle +1)
        (:set-from M:flx (:at M:cycle))))
      ("5" (when (:b M:flx 3)
        (:step M:cycle -1)
        (:set-from M:flx (:at M:cycle))))
      (true
        (:not! M:flx (int (first tail)))
        (:set-to M:cycle (:to-nums M:flx)))))
    ("P" (case-match (r tail)
      ('(? "3") (:not! P:flx 3))
      ('("b" "4") (:step P:cycle +1))
      ('("b" "5") (:step P:cycle -1))))
    ("N" (case-match (r tail)
      ('(? "1")
        (:flag N:flx 0 nil)
        (if (:not! N:flx 1)
          (begin
            (setq N:tickcounter TICKLIMIT)
            (make-kelvin))
          (:run N:off)))
      ('(? "2") (when (:b N:flx 0)
        (setq N:tickcounter TICKLIMIT)
        (make-kelvin)
        (:flag N:flx 0 nil)))
      ('(? "3") (:not! N:flx 3))
      ('("b" "4")
        (:flag N:flx 0 true)
        (:run N:manual (string (:step N:slider +1))))
      ('("b" "5")
        (:flag N:flx 0 true)
        (:run N:manual (string (:step N:slider -1))))))
    ("C" (case (first tail)
      ("1" (:run (if (:not! C:flx 1) C:on C:off)))
      ("3" (:not! C:flx 3))))
    ("Z" (case-match (r tail)
      ('(? "1") (:run (if (:not! Z:flx 1) Z:on Z:off)))
      ('(? "2")
        (setq Z:timecounter Z:timelimit
              Z:tickcounter TICKLIMIT)
        (checktime))
      ('(? "3") (:not! Z:flx 3))
      ('("b" "4") (++ Z:timelimit))
      ('("b" "5") (setq Z:timelimit (max (-- Z:timelimit) 2)))
      ('("c" "4") (:step Z:cycle +1))
      ('("c" "5") (:step Z:cycle -1))
      ('("d" "4")
        (++ Z:timecounter)
        (setq Z:tickcounter TICKLIMIT))
      ('("d" "5")
        (-- Z:timecounter)
        (setq Z:tickcounter TICKLIMIT)
        (checktime))))
    ("A" (case-match (r tail)
      ('(? "1") (:not! A:flx 1))
      ('(? "2") (when (post-outs)
        (:run notify {normal} "'post-outs: saved by user request!'")
        (setq A:tickcounter TICKLIMIT)))
      ('(? "3") (:not! A:flx 3))
      ('("b" ?) (:not! A:flx 4))
      ('("c" ?) (:not! A:flx 5))))
    ("X" (case (first tail)
      ("8" (setq flag true))
      ("postouts" (when (post-outs)
        (:run notify {normal} "'post-outs: saved by user request!'")
        (setq A:tickcounter TICKLIMIT)))
      ("propeller" (propeller))
      ("polytoggle" (on-workspace-focus))
      ("automemo" (when (and (:b A:flx 1) (:b A:flx 5)) (toggle-memo)))
      ("togglememo" (toggle-memo))
      (true (systemctl (first tail))))))
  flag))

(define (go2position (lt1 0))
  (append "move position "
    (if (= (:at P:cycle) "upside")
      (let (yo (mul P:height lt1))
        (ReCT BoX:_rect)
        (format {%d px %d px} ReCT:_x
          (if
            (<= ReCT:_height (- P:height yo)) (+ P:y yo)
            (<= P:height ReCT:_height) P:y
            (- (+ P:y P:height) ReCT:_height))))
      (:at P:cycle))))

(define (check-wcwi) (let (
  flag nil
  json (json-parse (:gettree ipc))
  )
  (dolist (e (ref-all '("window_properties" ?) json match true) flag)
    (setq flag (and (= PRoP:_class (lookup "class" (last e)))
                    (!= PRoP:_instance (lookup "instance" (last e))))))))

(define (on-fullscreen)
  (when (:b Z:flx 1) (let (
    r (cons BoX:_fullscreen_mode Z:fullscreen_mode)
    )
    (cond ((= '(1 0) r) (:run Z:off)
                        (setq Z:fullscreen_mode 1))
          ((= '(0 1) r) (:run Z:on)
                        (setq Z:fullscreen_mode 0))))))

(define (on-floating)
  (if (or (= BoX:_window_type "normal") (= BoX:_window_type "unknown"))
    (:command-wid ipc BoX:_window
      (if (ends-with BoX:_floating "on")
        (append "border pixel 6, " (go2position))
        "border none"))
    (when (and (= (:at P:cycle) "upside") (ends-with BoX:_floating "on"))
      (:command-wid ipc BoX:_window (go2position 0.1)))))

(define (on-new)
  (when (or (= BoX:_window_type "normal") (= BoX:_window_type "unknown"))
    (PRoP BoX:_window_properties)
    (let (
      idx (find (list PRoP:_class PRoP:_instance (:b M:flx 1)) M:memo)
      )
      (case-match (r (list (:b M:flx 1) (:b M:flx 2) (true? idx)))
        ('(true true true)
          (:command-wid ipc BoX:_window "floating disable"))
        ('(nil true true)
          (:command-wid ipc BoX:_window "floating enable"))
        ('(true ? ?)
          (:command-wid ipc BoX:_window "floating enable"))
        ('(*)
          (:command-wid ipc BoX:_window
            (if (check-wcwi) "floating enable" "floating disable")))))))

(define (on-move)
  (unless (= BoX:_scratchpad_state "none") (let (
    lst (first BoX:_nodes)
    )
    (BoX lst)
    (on-new)
    (on-floating)
    (when (ends-with BoX:_floating "on")
      (:run xprop (string BoX:_window))))))

(define (on-workspace-focus) (letn (
  json (json-parse (:getworkspaces ipc))
  fcsd (json (0 -1 (ref '("focused" true) json match)))
  )
  (ReCT (lookup "rect" fcsd))
  (setq P:y ReCT:_y
        P:height ReCT:_height)))

; main loop
(local (flag data json)
  (map delete '(dirname include isinPATH permutations require))
  (:run C:off)
  (:run Z:off)
  (:subscribe ipc4sub {[ "window", "workspace" ]})
  (on-workspace-focus)
  (post-ins)
  (remit)
  (until flag
    (until (net-select (:socket ipc4sub) "r" 25000)
      (dolist (child_pid (receive))
        (receive child_pid data)
        (when (= child_pid polybarpid)
          (setq flag (lettershop data))
          (letters2polybar))))
    (setq data (:receive ipc4sub)
          json (json-parse data))
    (if (lookup "container" json)
      (case (lookup "change" json)
        ("focus" (BoX $it) (on-fullscreen))
        ("new" (BoX $it) (on-new))
        ("floating" (BoX $it) (on-floating))
        ("move" (BoX $it) (on-move))
        ("fullscreen_mode" (BoX $it) (on-fullscreen)))
      (when (lookup "current" json)
        (case (lookup "change" json)
          ("focus" (on-workspace-focus))))))
  (:close ipc)
  (:close ipc4sub)
  (when (and (:b A:flx 1) (:b A:flx 4)) (post-outs)))

(abort)
(exit)
