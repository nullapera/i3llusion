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

(setq
  i3sock (env "I3SOCK")
  polybarsock (replace {/[^/]+\z} (copy i3sock) "/i3llusion.ipc" 0))

(let(
  selfpid (sys-info 7)
  pids (find-all
    "i3llusion"
    (exec {ps -C newlisp -o pid,args})
    (int (first (parse $it)))
    find)
  )
  (map destroy (replace selfpid pids))
  (when(file? polybarsock)
    (unless(delete-file polybarsock)
      (throw-error (append "Can not be deleted! : '" polybarsock "'")))))

(require
  "Flag" "Cmd" "Cycle" "Slider" "permutations" "i3llusion/i3ipc")

(setq
  box:box nil
  vbox:vbox nil
  drawer nil
  scratcheds '()
  ipc4cmd (i3ipc i3sock)
  ipc4sub (i3ipc i3sock)
  colors (Cycle (map
    (fn(a) (join (cons "#" a)))
    (permutations 3 '("8" "a" "c" "f"))))
  basepath (append (real-path) "/i3llusion")
  memodat (append basepath "-memo.dat")
  conddat (append basepath "-cond.dat")
  notify (Cmd {notify-send} "-u" "'** i3llusion **'")
  xprop (Cmd {xprop}
    "-format I3_FLOATING_WINDOW 32c -set I3_FLOATING_WINDOW 1 -id"))

(let(p (append basepath "-msg.lsp"))
  (setq lettersfmt (append
    "%%{A1:" p " %s1:}"
    "%%{A2:" p " %s2:}"
    "%%{A3:" p " %s3:}"
    "%%{A4:" p " %s4:}"
    "%%{A5:" p " %s5:}"
    "%%{F%s} %s "
    "%%{A}%%{A}%%{A}%%{A}%%{A}")))

(constant
  'WARNLIMIT 2 'BESIX 6 'TICKLIMIT (/ 3600 10 BESIX))

(setq ; M: Mode
  M:flag (Flag 4 '(0 1 1))
  M:memo '()
  M:cycle (Cycle '((0 0 0 1) (0 0 1 1) (0 1 0 1) (0 1 1 1)))
  M:texts '(
    "m" "Mode: UnFloating"
    "m+" "Mode: UnFloatingMemo"
    "M" "Mode: Floating"
    "M+" "Mode: FloatingMemo"))

(setq ; P: Position
  P:flag (Flag 4)
  P:y 0
  P:height 0
  P:cycle (Cycle '("center" "mouse" "upside")))

(setq ; N: Nightlight
  N:flag (Flag 4 '(0 1))
  N:on (Cmd {redshift} "-v -r -P -o -m randr -l 48.25:20.63 -t 6200:4200 2>&1")
  N:off (Cmd {redshift} "-x -m randr")
  N:manual (Cmd {redshift} "-r -P -m randr -O")
  N:slider (Slider 6400 2400 6400 50)
  N:tick (lambda() (when(and (:?? N:flag 1) (not(:?? N:flag 0))) (kelvinize)))
  N:tickcounter 0
  N:texts '(
    "n" "Nightlight: Off"
    "N" "Nightlight:"
    nil nil
    "!N" "!Nightlight:"))

(setq ; C: Compositor
  C:flag (Flag 4 '(0 1))
  C:on (Cmd {picom} "-b --config" (append basepath "-picom.conf"))
  C:off (Cmd {pkill} "picom")
  C:texts '("c" "Compositor: Off" "C" "Compositor: On"))

(setq ; Z: snooZe
  Z:flag (Flag 4 '(0 1))
  Z:fullscreen_mode 0
  Z:timelimit 80
  Z:timecounter Z:timelimit
  Z:on (Cmd {xset} "s 360 360 dpms 480 600 720")
  Z:off (Cmd {xset} "s off -dpms")
  Z:tick (lambda() (-- Z:timecounter) (checktime))
  Z:tickcounter TICKLIMIT
  Z:systemctl (Cmd {systemctl})
  Z:cycle (Cycle '("suspend" "hibernate" "poweroff")))

(setq ; A: Automate
  A:flag (Flag 6 '(0 1 0 0 1 1))
  A:tickcounter 0
  A:tick (lambda() (when(and (:?? A:flag 1) (:?? A:flag 4)) (post-outs)))
  A:texts '("a" "a" "a" "a" "Asm" "AsM" "ASm" "ASM"))

(constant
  'LETTERS (list M P N C Z A) 'TICKS (list N Z A))

(define polybarpid
  (spawn 'polybarspawn
    (let(conn nil
         data nil
         parentpid (sys-info 6)
         socket (net-listen polybarsock))
      (while true
        (setq conn (net-accept socket))
        (until(net-select conn "r" 35000))
        (net-receive conn data 256)
        (net-close conn)
        (send parentpid data)))
    true))

(define(letters2polybar) (let(
  letters '()
  color (:step colors -1)
  make (lambda(l txt)
    (push (format lettersfmt l l l l l color txt) letters -1))
  )
  ; Mode
  (make "M" (M:texts (:to-int M:flag 1 3)))
  ; Position
  (make "Pa"
    (if(:?? P:flag 3)
      "Position:"
      (append "P" (first (:at P:cycle)))))
  (when(:?? P:flag 3) (make "Pb" (:at P:cycle)))
  ; Nightlight
  (make "Na" (N:texts (:to-int N:flag '(0 1 3))))
  (when(and (:?? N:flag 3) (:?? N:flag 1))
    (make "Nb" (string (:value N:slider) "K")))
  ; Compositor
  (make "C" (C:texts (:to-int C:flag '(1 3))))
  ; snooZe
  (if(:?? Z:flag 3)
    (begin
      (make "Za" (if(:?? Z:flag 1) "snooZe: lock" "snooZe: UNlock"))
      (make "Zb" (format {<  %.1fhrs} (div Z:timelimit 10)))
      (make "Zc" (append "<  " (:at Z:cycle))))
    (make "Zd"
      (format (if(:?? Z:flag 1) {Z%.1f} {z%.1f}) (div Z:timecounter 10))))
  ; Automate
  (if(:?? A:flag 3)
    (begin
      (make "Aa" (if(:?? A:flag 1) "Auto:" "Auto: Off"))
      (when(:?? A:flag 1)
        (make "Ab" (if(:?? A:flag 4) "SavE," "save,"))
        (make "Ac" (if(:?? A:flag 5) "MemO" "memo"))))
    (make "Aa" (A:texts (:to-int A:flag '(1 4 5)))))
  (write-line 1 (join letters))))

(define(kelvinize)
  (:value! N:slider (int ((parse ((:run N:on) -2)) -2))))

(define(systemctl cmd)
  (setq Z:timecounter Z:timelimit
        Z:tickcounter TICKLIMIT
        N:tickcounter 0)
  (when(and (:?? A:flag 1) (:?? A:flag 4))
    (post-outs)
    (setq A:tickcounter TICKLIMIT))
  (:run Z:systemctl cmd))

(define(checktime)
  (unless(< WARNLIMIT Z:timecounter)
    (if(< 0 Z:timecounter)
      (:run notify {critical}
        (append "'snooZe: Close to " (:at Z:cycle) "!'"))
      (systemctl (:at Z:cycle)))))

(define(remit , flag)
  (timer 'remit BESIX)
  (dolist(e TICKS)
    (when(<= (-- e:tickcounter) 0)
      (setq e:tickcounter TICKLIMIT
            flag true)
      (e:tick)))
  (when flag (letters2polybar)))

(define(post-outs) (let(
  flag true
  lst (append
    (map (fn(a) (:nums a:flag)) LETTERS)
    (list (:index P:cycle) (:value N:slider) Z:timelimit (:index Z:cycle)))
  )
  (unless(write-file memodat (string M:memo))
    (setq flag nil)
    (:run notify {critical}
      (append "'post-outs: Can not write to " memodat "!'")))
  (unless(write-file conddat (join (map string lst) "\n"))
    (setq flag nil)
    (:run notify {critical}
      (append "'post-outs: Can not write to " conddat "!'")))
  flag))

(define(post-ins)
  (when(file? memodat)
    (if(read-file memodat)
      (set 'M:memo (read-expr $it))
      (:run notify {critical}
        (append "'post-ins: Can not read from " memodat "!'"))))
  (when(file? conddat)
    (if(read-file conddat)
      (let(lst (parse $it "\n"))
        (dolist(e LETTERS) (:set-from e:flag (read-expr (pop lst))))
        (:set-to M:cycle (setf (nth 3 (:nums M:flag)) 1))
        (:at! P:cycle (int (pop lst)))
        (if(:?? N:flag 0)
          (:run N:manual (:value! N:slider (int (pop lst))))
          (pop lst))
        (setq Z:timelimit (int (pop lst))
              Z:timecounter Z:timelimit)
        (:at! Z:cycle (int (pop lst))))
      (:run notify {critical}
        (append "'post-ins: Can not read from " conddat "!'")))))

(define(propeller) (let(
  lst '()
  fcsd nil
  )
  (:seek-tree ipc4cmd (fn(e)
    (unless(= (lookup "scratchpad_state" e) "none")
      (push (lookup "window" (first (lookup "nodes" e))) lst -1))
    (when(= (lookup "focused" e) true) (setq fcsd e))))
  (when lst (let(
    fwid (when fcsd (lookup "window" fcsd))
    )
    (if(number? fwid)
      (let(ffon (ends-with (lookup "floating" fcsd) "on")
           it nil)
        (setq lst (replace fwid lst))
        (when lst
          (setq scratcheds (difference scratcheds (difference scratcheds lst))
                it (difference lst scratcheds))
          (if it
            (setq it (first it))
            (setq it (first lst)
                  scratcheds '()))
          (push fwid scratcheds -1)
          (:command-wid ipc4cmd fwid (string "swap container with id " it))
          (:command-wid ipc4cmd it
            (if ffon
              "border pixel 6, floating enable"
              "border none, floating disable"))
          (when ffon (:run xprop it))))
      (:command ipc4cmd "scratchpad show"))))))

(define(toggle-memo)
  (when drawer (letn(
    prop (lookup "window_properties" drawer)
    rec (list (lookup "class" prop) (lookup "instance" prop) (:?? M:flag 1))
    idx (find rec M:memo)
    it (list (:?? M:flag 1) (number? idx) (lookup "floating" drawer))
    )
    (if(= '(true true "user_on") it) (pop M:memo idx)
       (= '(true nil "user_off") it) (push rec M:memo)
       (= '(nil true "user_off") it) (pop M:memo idx)
       (= '(nil nil "user_on") it) (push rec M:memo)))))

(define(lettershop stamp , flag)
  (case(pop stamp)
    ; Mode
    ("M" (case stamp
      ("4" (when(:?? M:flag 3)
        (:step M:cycle +1)
        (:set-from M:flag (:at M:cycle))))
      ("5" (when(:?? M:flag 3)
        (:step M:cycle -1)
        (:set-from M:flag (:at M:cycle))))
      (true
        (:toggle M:flag (int stamp))
        (:set-to M:cycle (:nums M:flag)))))
    ; Position
    ("P" (if
      (= (last stamp) "3") (:toggle P:flag 3)
      (= stamp "b4") (:step P:cycle +1)
      (= stamp "b5") (:step P:cycle -1)))
    ; Nightlight
    ("N" (case(last stamp)
      ("1"
        (:no N:flag 0)
        (if(:toggle N:flag 1)
          (begin
            (setq N:tickcounter TICKLIMIT)
            (kelvinize))
          (:run N:off)))
      ("2" (when(:?? N:flag 0)
        (setq N:tickcounter TICKLIMIT)
        (kelvinize)
        (:no N:flag 0)))
      ("3" (:toggle N:flag 3))
      (true (case stamp
        ("b4"
          (:yes N:flag 0)
          (:run N:manual (:step N:slider +1)))
        ("b5"
          (:yes N:flag 0)
          (:run N:manual (:step N:slider -1)))))))
    ; Compositor
    ("C" (case stamp
      ("1" (:run (if(:toggle C:flag 1) C:on C:off)))
      ("3" (:toggle C:flag 3))))
    ; snooZe
    ("Z" (case(last stamp)
      ("1" (:run (if(:toggle Z:flag 1) Z:on Z:off)))
      ("2"
        (setq Z:timecounter Z:timelimit
              Z:tickcounter TICKLIMIT)
        (checktime))
      ("3" (:toggle Z:flag 3))
      (true (case stamp
        ("b4" (++ Z:timelimit))
        ("b5" (setq Z:timelimit (max (-- Z:timelimit) WARNLIMIT)))
        ("c4" (:step Z:cycle +1))
        ("c5" (:step Z:cycle -1))
        ("d4"
          (++ Z:timecounter)
          (setq Z:tickcounter TICKLIMIT))
        ("d5"
          (-- Z:timecounter)
          (setq Z:tickcounter TICKLIMIT)
          (checktime))))))
    ; Automate
    ("A" (case(last stamp)
      ("1" (:toggle A:flag 1))
      ("2" (when(post-outs)
        (:run notify {normal} "'post-outs: saved by user request!'")
        (setq A:tickcounter TICKLIMIT)))
      ("3" (:toggle A:flag 3))
      (true (case(first stamp)
        ("b" (:toggle A:flag 4))
        ("c" (:toggle A:flag 5))))))
    ; eXtra
    ("X" (case stamp
      ("8" (setq flag true))
      ("postouts" (when(post-outs)
        (:run notify {normal} "'post-outs: saved by user request!'")
        (setq A:tickcounter TICKLIMIT)))
      ("propeller" (propeller))
      ("polytoggle" (on-workspace-focus))
      ("automemo" (when(and (:?? A:flag 1) (:?? A:flag 5)) (toggle-memo)))
      ("togglememo" (toggle-memo))
      (true (systemctl stamp)))))
  flag)

(define(go2position bx (lt1 0))
  (append "move position "
    (if(= (:at P:cycle) "upside")
      (letn(yo (mul P:height lt1)
            rect (lookup "rect" bx)
            height (lookup "height" rect))
        (format {%d px %d px}
          (lookup "x" rect)
          (if(<= height (- P:height yo)) (+ P:y yo)
             (<= P:height height) P:y
             (- (+ P:y P:height) height))))
      (:at P:cycle))))

(define(check-wcwi prop) (let(
  class (lookup "class" prop)
  instance (lookup "instance" prop)
  )
  (catch (:seek-tree ipc4cmd (fn(e , wp)
    (when(setq wp (lookup "window_properties" e))
      (when(and (= class (lookup "class" wp))
                (!= instance (lookup "instance" wp)))))
        (throw true))))))

(define(on-fullscreen bx)
  (setq drawer bx)
  (when(:?? Z:flag 1) (let(
    it (cons (lookup "fullscreen_mode" bx) Z:fullscreen_mode)
    )
    (cond
      ((= '(1 0) it)
        (:run Z:off)
        (setq Z:fullscreen_mode 1))
      ((= '(0 1) it)
        (:run Z:on)
        (setq Z:fullscreen_mode 0))))))

(define(on-floating bx) (let (
  wtype (lookup "window_type" bx)
  )
  (setq drawer bx)
  (if(or (= wtype "normal") (= wtype "unknown"))
    (:command-wid ipc4cmd (lookup "window" bx)
      (if(ends-with (lookup "floating" bx) "on")
        (append "border pixel 6, " (go2position bx))
        "border none"))
    (when(and (= (:at P:cycle) "upside")
              (ends-with (lookup "floating" bx) "on"))
      (:command-wid ipc4cmd (lookup "window" bx) (go2position bx 0.1))))))

(define(on-new bx) (let(
  wtype (lookup "window_type" bx)
  )
  (when(or (= wtype "normal") (= wtype "unknown")) (letn(
    prop (lookup "window_properties" bx)
    idx (find
      (list (lookup "class" prop) (lookup "instance" prop) (:?? M:flag 1))
      M:memo)
    rec (list (:?? M:flag 1) (:?? M:flag 2) (number? idx))
    )
    (if(= '(true true true) rec)
       (:command-wid ipc4cmd (lookup "window" bx) "floating disable")
       (= '(nil true true) rec)
       (:command-wid ipc4cmd (lookup "window" bx) "floating enable")
       (first rec)
       (:command-wid ipc4cmd (lookup "window" bx) "floating enable")
       (:command-wid ipc4cmd (lookup "window" bx)
          (if(check-wcwi prop) "floating enable" "floating disable")))))))

(define(on-move bx)
  (unless(= (lookup "scratchpad_state" bx) "none")
    (setq vbox:vbox (first (lookup "nodes" bx)))
    (on-new vbox)
    (on-floating vbox)
    (when(ends-with (lookup "floating" vbox) "on")
      (:run xprop (lookup "window" vbox)))))

(define(on-workspace-focus) (let(
  lst (json-parse (:getworkspaces ipc4cmd))
  rect nil
  )
  (setq drawer nil)
  (dolist (e lst rect)
    (when(= (lookup "focused" e) true)
      (setq rect (lookup "rect" e)
            P:y (lookup "y" rect)
            P:height (lookup "height" rect))))))

; main loop
(local(flag data json)
  (map delete '(include isinPATH permutations require))
  (:run C:off)
  (:run Z:off)
  (:subscribe ipc4sub {[ "window", "workspace" ]})
  (on-workspace-focus)
  (post-ins)
  (remit)
  (when(:?? C:flag 1) (:run C:on))
  (when(:?? Z:flag 1) (:run Z:on))
  (until flag
    (until(net-select (:socket ipc4sub) "r" 25000)
      (dolist(childpid (receive))
        (receive childpid data)
        (when(= childpid polybarpid)
          (setq flag (lettershop data))
          (letters2polybar))))
    (setq json (json-parse (:receive ipc4sub)))
    (if(setq box:box (lookup "container" json))
      (case(lookup "change" json)
        ("focus" (on-fullscreen box))
        ("new" (on-new box))
        ("floating" (on-floating box))
        ("move" (on-move box))
        ("fullscreen_mode" (on-fullscreen box)))
      (when(lookup "current" json)
        (case(lookup "change" json)
          ("focus" (on-workspace-focus))))))
  (:close ipc4cmd)
  (:close ipc4sub)
  (when(and (:?? A:flag 1) (:?? A:flag 4)) (post-outs)))

(abort)
(exit)
