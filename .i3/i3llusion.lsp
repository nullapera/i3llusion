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

(constant
  'I3SOCK (env "I3SOCK")
  'POLYBARSOCK (replace {/[^/]+\z} (copy I3SOCK) "/i3llusion.ipc" 0))

(let (
  selfpid (sys-info 7)
  pids (find-all
    "i3llusion"
    (exec {ps -C newlisp -o pid,args})
    (int (first (parse $it)))
    find)
  )
  (map destroy (replace selfpid pids))
  (when (file? POLYBARSOCK)
    (unless (delete-file POLYBARSOCK)
      (throw-error (append "Can not be deleted! : '" POLYBARSOCK "'")))))

(require
  "Flag" "Cmd" "Cycle" "Slider" "chunk" "permutations" "i3llusion/i3ipc")

(constant
  'BASEPATH (append (real-path) "/i3llusion")
  'MEMOPATH (append BASEPATH "-memo.dat")
  'CONDPATH (append BASEPATH "-cond.dat")
  'LETTERSFMT (let (p (append BASEPATH "-msg.lsp"))
    (append
      "%%{A1:" p " %s_1:}"
      "%%{A2:" p " %s_2:}"
      "%%{A3:" p " %s_3:}"
      "%%{A4:" p " %s_4:}"
      "%%{A5:" p " %s_5:}"
      "%%{F%s} %s "
      "%%{A}%%{A}%%{A}%%{A}%%{A}"))
  'WARNLIMIT 2
  'BESIX 6
  'TICKLIMIT (/ 3600 10 BESIX))

(setq
  box:box nil
  vbox:vbox nil
  drawer nil
  scratcheds '()
  ipc4cmd (i3ipc I3SOCK)
  ipc4sub (i3ipc I3SOCK)
  colors (letn (
    hxa (explode "abef")
    chr (char (apply max (map char hxa)))
    lst (permutations 3 hxa)
    )
    (seed (time-of-day))
    (setq lst (map (curry push "#") (map join $it))
          lst (filter first (chunk (curry find chr) $it))
          lst (map randomize (randomize (map last $it))))
    (Cycle (flat (apply map (cons list lst)))))
  notify (Cmd {notify-send} "-u" "'** i3llusion **'")
  xprop (Cmd {xprop}
    "-format I3_FLOATING_WINDOW 32c -set I3_FLOATING_WINDOW 1 -id"))

(setq ; M: Mode
  M:flag (Flag 4 '(0 1 1))
  M:cycle (Cycle '((0 0 0 1) (0 0 1 1) (0 1 0 1) (0 1 1 1)))
  M:memo '()
  M:msg ""
  M:texts '(
    "m" "Mode: UnFloating"
    "m+" "Mode: UnFloatingMemo"
    "M" "Mode: Floating"
    "M+" "Mode: FloatingMemo"))

(setq ; P: Position
  P:flag (Flag 4)
  P:cycle (Cycle '("center" "mouse" "upside"))
  P:wrkspc_y 0
  P:wrkspc_height 0
  P:msg "")

(setq ; N: Nightlight
  N:flag (Flag 4 '(0 1))
  N:on (Cmd {redshift} "-v -r -P -o -m randr -l 48.25:20.63 -t 6200:4200 2>&1")
  N:off (Cmd {redshift} "-x -m randr")
  N:manual (Cmd {redshift} "-r -P -m randr -O")
  N:slider (Slider 6400 2400 6400 50)
  N:tick (lambda() (when (and (:on? N:flag 1) (:off? N:flag 0)) (kelvinize)))
  N:tickcounter TICKLIMIT
  N:msg ""
  N:texts '(
    "n" "Nightlight: Off"
    "N" "Nightlight:"
    nil nil
    "!N" "!Nightlight:"))

(setq ; C: Compositor
  C:flag (Flag 4 '(0 1))
  C:on (Cmd {picom} "-b --config" (append BASEPATH "-picom.conf"))
  C:off (Cmd {pkill} "picom")
  C:msg ""
  C:texts '("c" "Compositor: Off" "C" "Compositor: On"))

(setq ; Z: snooZe
  Z:flag (Flag 4 '(0 1))
  Z:on (Cmd {xset} "s 360 360 dpms 480 600 720")
  Z:off (Cmd {xset} "s off -dpms")
  Z:systemctl (Cmd {systemctl})
  Z:cycle (Cycle '("suspend" "hibernate" "poweroff"))
  Z:tick (lambda() (-- Z:timecounter) (checktime))
  Z:tickcounter TICKLIMIT
  Z:fullscreen_mode 0
  Z:timelimit 80
  Z:timecounter Z:timelimit
  Z:msg "")

(setq ; A: Automate
  A:flag (Flag 6 '(0 1 0 0 1 1))
  A:tickcounter TICKLIMIT
  A:tick (lambda() (when (and (:on? A:flag 1) (:on? A:flag 4)) (post-outs)))
  A:msg ""
  A:texts '("a" "a" "a" "a" "Asm" "AsM" "ASm" "ASM"))

(setq ; X: eXtra
  X:tick (lambda()
    (:at! colors (rand (:length colors)))
    (dolist (e LETTERS) (letterfactory e))
    (letters2polybar))
  X:tickcounter TICKLIMIT)

(constant
  'LETTERS (list M P N C Z A) 'TICKS (list N Z A X))

(define polybarpid
  (spawn 'polybarspawn
    (let (conn nil
          data nil
          parentpid (sys-info 6)
          socket (net-listen POLYBARSOCK))
      (while true
        (setq conn (net-accept socket))
        (until(net-select conn "r" 35000))
        (net-receive conn data 256)
        (net-close conn)
        (send parentpid data)))
    true))

(macro(set-shape VAR LTTR TXT)
  (setq VAR
    (format LETTERSFMT LTTR LTTR LTTR LTTR LTTR (:at colors) TXT)))

(macro(add-shape VAR LTTR TXT)
  (extend VAR
    (format LETTERSFMT LTTR LTTR LTTR LTTR LTTR (:at colors) TXT)))

(define(letterfactory lttr)
  (:step colors 1)
  (cond
    ((or (= lttr "M") (= lttr M))
      (set-shape M:msg "M" (M:texts (:to-int M:flag 1 3)))
      true)
    ((or (= lttr "P") (= lttr P))
      (set-shape P:msg "P_a"
        (if (:on? P:flag 3) "Position:" (append "P" (first (:at P:cycle)))))
      (when (:on? P:flag 3) (add-shape P:msg "P_b" (:at P:cycle)))
      true)
    ((or (= lttr "N") (= lttr N))
      (set-shape N:msg "N_a" (N:texts (:to-int N:flag '(0 1 3))))
      (when (and (:on? N:flag 3) (:on? N:flag 1))
        (add-shape N:msg "N_b" (string (:value N:slider) "K")))
      true)
    ((or (= lttr "C") (= lttr C))
      (set-shape C:msg "C" (C:texts (:to-int C:flag '(1 3))))
      true)
    ((or (= lttr "Z") (= lttr Z))
      (if (:on? Z:flag 3)
        (begin
          (set-shape Z:msg "Z_a"
            (if (:on? Z:flag 1) "snooZe: lock" "snooZe: UNlock"))
          (add-shape Z:msg "Z_b" (format {<  %.1fhrs} (div Z:timelimit 10)))
          (add-shape Z:msg "Z_c" (append "<  " (:at Z:cycle))))
        (set-shape Z:msg "Z_d"
          (format (if (:on? Z:flag 1) {Z%.1f} {z%.1f})
                                      (div Z:timecounter 10))))
      true)
    ((or (= lttr "A") (= lttr A))
      (if (:on? A:flag 3)
        (begin
          (set-shape A:msg "A_a" (if (:on? A:flag 1) "Auto:" "Auto: Off"))
          (when (:on? A:flag 1)
            (add-shape A:msg "A_b" (if (:on? A:flag 4) "SavE," "save,"))
            (add-shape A:msg "A_c" (if (:on? A:flag 5) "MemO" "memo"))))
        (set-shape A:msg "A_a" (A:texts (:to-int A:flag '(1 4 5)))))
      true)
    (true nil)))

(define(letters2polybar)
  (write-line 1 (join (map (fn(a) a:msg) LETTERS))))

(define(kelvinize)
  (:value! N:slider (int ((parse ((:run N:on) -2)) -2))))

(define(systemctl cmd)
  (setq Z:timecounter Z:timelimit
        Z:tickcounter TICKLIMIT
        N:tickcounter 0)
  (when (and (:on? A:flag 1) (:on? A:flag 4))
    (post-outs)
    (setq A:tickcounter TICKLIMIT))
  (:run Z:systemctl cmd))

(define(checktime)
  (unless (< WARNLIMIT Z:timecounter)
    (if (< 0 Z:timecounter)
      (:run notify {critical}
        (append "'snooZe: Close to " (:at Z:cycle) "!'"))
      (systemctl (:at Z:cycle)))))

(define(remit , flag)
  (timer 'remit BESIX)
  (dolist (e TICKS)
    (when (<= (-- e:tickcounter) 0)
      (e:tick)
      (setq e:tickcounter TICKLIMIT
            flag (letterfactory e))))
  (when flag (letters2polybar)))

(define(post-outs)
  (let (
    lst (append (map
     (fn(a) (:nums a:flag)) LETTERS)
     (list (:index P:cycle) (:value N:slider)
           Z:timelimit (:index Z:cycle)))
    )
    (apply and (list
      (unless (write-file MEMOPATH (string M:memo))
        (:run notify {critical}
          (append "'post-outs: Can not write to " MEMOPATH "!'"))
        nil)
      (unless (write-file CONDPATH (join (map string lst) "\n"))
        (:run notify {critical}
          (append "'post-outs: Can not write to " CONDPATH "!'"))
        nil)))))

(define(post-ins)
  (when (file? MEMOPATH)
    (if (read-file MEMOPATH)
      (set 'M:memo (read-expr $it))
      (:run notify {critical}
        (append "'post-ins: Can not read from " MEMOPATH "!'"))))
  (when (file? CONDPATH)
    (if (read-file CONDPATH)
      (let (lst (parse $it "\n"))
        (dolist (e LETTERS) (:set-from e:flag (read-expr (pop lst))))
        (:set-to M:cycle (setf (nth 3 (:nums M:flag)) 1))
        (:at! P:cycle (int (pop lst)))
        (if (:on? N:flag 0)
          (:run N:manual (:value! N:slider (int (pop lst))))
          (pop lst))
        (setq Z:timelimit (int (pop lst))
              Z:timecounter Z:timelimit)
        (:at! Z:cycle (int (pop lst))))
      (:run notify {critical}
        (append "'post-ins: Can not read from " CONDPATH "!'")))))

(define(propeller flag , it lst (fcsd '()))
  (:seek-tree ipc4cmd (fn(a)
    (unless (= (lookup "scratchpad_state" a) "none")
      (push (lookup "window" (first (lookup "nodes" a))) lst -1))
    (when (= (lookup "focused" a) true) (setq fcsd a))))
  (when lst
    (let (fwid (lookup "window" fcsd))
      (if fwid
        (let (ffon (ends-with (lookup "floating" fcsd) "on"))
          (setq scratcheds (or (difference $it (difference $it lst)) lst))
          (setq it
            (if flag
              (pop (push fwid scratcheds -1))
              (pop (push fwid scratcheds) -1)))
          (:command-wid ipc4cmd fwid (string "swap container with id " it))
          (:command-wid ipc4cmd it
            (if ffon
              "border pixel 6, floating enable"
              "border none, floating disable"))
          (when ffon (:run xprop it)))
        (:command ipc4cmd "scratchpad show")))))

(define(toggle-memo)
  (when drawer
    (letn (
      wp (lookup "window_properties" drawer)
      rec (list (lookup "class" wp)
                (lookup "instance" wp)
                (:on? M:flag 1))
      idx (find rec M:memo)
      it (list (:on? M:flag 1) (number? idx) (lookup "floating" drawer))
      )
      (if
        (= '(true true "user_on") it) (pop M:memo idx)
        (= '(true nil "user_off") it) (push rec M:memo)
        (= '(nil true "user_off") it) (pop M:memo idx)
        (= '(nil nil "user_on") it) (push rec M:memo)))))

(define(lettershop lttr msg , flag)
  (case lttr
    ; Mode
    ("M" (case (first msg)
      ("4" (when (:on? M:flag 3)
              (:step M:cycle +1)
              (:set-from M:flag (:at M:cycle))))
      ("5" (when (:on? M:flag 3)
              (:step M:cycle -1)
              (:set-from M:flag (:at M:cycle))))
      (true (:toggle M:flag (int (first msg)))
            (:set-to M:cycle (:nums M:flag)))))
    ; Position
    ("P" (if
            (= (last msg) "3") (:toggle P:flag 3)
            (= '("b" "4") msg) (:step P:cycle +1)
            (= '("b" "5") msg) (:step P:cycle -1)))
    ; Nightlight
    ("N" (case (last msg)
      ("1" (:off N:flag 0)
           (if (:toggle N:flag 1)
              (begin
                (setq N:tickcounter TICKLIMIT)
                (kelvinize))
              (:run N:off)))
      ("2" (when (:on? N:flag 0)
              (setq N:tickcounter TICKLIMIT)
              (kelvinize)
              (:off N:flag 0)))
      ("3" (:toggle N:flag 3))
      (true (when (= (first msg) "b")
        (case (last msg)
          ("4" (:on N:flag 0)
               (:run N:manual (:step N:slider +1)))
          ("5" (:on N:flag 0)
               (:run N:manual (:step N:slider -1))))))))
    ; Compositor
    ("C" (case (first msg)
      ("1" (:run (if(:toggle C:flag 1) C:on C:off)))
      ("3" (:toggle C:flag 3))))
    ; snooZe
    ("Z" (case (last msg)
      ("1" (:run (if (:toggle Z:flag 1) Z:on Z:off)))
      ("2" (setq Z:timecounter Z:timelimit
                 Z:tickcounter TICKLIMIT)
           (checktime))
      ("3" (:toggle Z:flag 3))
      (true (case (first msg)
        ("b" (if (= (last msg) "4")
                (++ Z:timelimit)
                (setq Z:timelimit (max (- $it 1) WARNLIMIT))))
        ("c" (if (= (last msg) "4")
                (:step Z:cycle +1)
                (:step Z:cycle -1)))
        ("d" (case (last msg)
          ("4" (++ Z:timecounter)
               (setq Z:tickcounter TICKLIMIT))
          ("5" (-- Z:timecounter)
               (setq Z:tickcounter TICKLIMIT)
               (checktime))))))))
    ; Automate
    ("A" (case (last msg)
      ("1" (:toggle A:flag 1))
      ("2" (when (post-outs)
              (:run notify {normal} "'post-outs: saved by user request!'")
              (setq A:tickcounter TICKLIMIT)))
      ("3" (:toggle A:flag 3))
      (true (case (first msg)
        ("b" (:toggle A:flag 4))
        ("c" (:toggle A:flag 5))))))
    ; eXtra
    ("X" (case (first msg)
      ("automemo" (when (and (:on? A:flag 1) (:on? A:flag 5)) (toggle-memo)))
      ("togglememo" (toggle-memo))
      ("propeller" (propeller))
      ("propellerR" (propeller true))
      ("postouts" (when (post-outs)
                    (:run notify {normal}
                      "'post-outs: saved by user request!'")
                    (setq A:tickcounter TICKLIMIT)))
      ("polytoggle" (on-workspace-focus))
      ("8" (setq flag true))
      (true (systemctl (first msg))))))
  flag)

(define(go2position bx (lt1 0))
  (append "move position "
    (if (= (:at P:cycle) "upside")
      (letn (yo (mul P:wrkspc_height lt1)
             rect (lookup "rect" bx)
             height (lookup "height" rect))
        (format {%d px %d px}
          (lookup "x" rect)
          (if
            (<= height (- P:wrkspc_height yo)) (+ P:wrkspc_y yo)
            (<= P:wrkspc_height height) P:wrkspc_y
            (- (+ P:wrkspc_y P:wrkspc_height) height))))
      (:at P:cycle))))

(define(check-wcwi wp)
  (let (wc (lookup "class" wp)
        wi (lookup "instance" wp))
    (catch (:seek-tree ipc4cmd (fn(a)
      (when (setq wp (lookup "window_properties" a))
        (when (and (= wc (lookup "class" wp))
                   (!= wi (lookup "instance" wp)))))
          (throw true))))))

(define(on-fullscreen bx)
  (setq drawer bx)
  (when (:on? Z:flag 1)
    (let (it (cons (lookup "fullscreen_mode" bx) Z:fullscreen_mode))
      (cond ((= '(1 0) it)
              (:run Z:off)
              (setq Z:fullscreen_mode 1))
            ((= '(0 1) it)
              (:run Z:on)
              (setq Z:fullscreen_mode 0))))))

(define(on-floating bx)
  (let (wt (lookup "window_type" bx))
    (setq drawer bx)
    (if (or (= wt "normal") (= wt "unknown"))
      (:command-wid ipc4cmd (lookup "window" bx)
        (if (ends-with (lookup "floating" bx) "on")
          (append "border pixel 6, " (go2position bx))
          "border none"))
      (when (and (= (:at P:cycle) "upside")
                 (ends-with (lookup "floating" bx) "on"))
        (:command-wid ipc4cmd (lookup "window" bx) (go2position bx 0.1))))))

(define(on-new bx)
  (let (wt (lookup "window_type" bx))
    (when (or (= wt "normal") (= wt "unknown"))
      (letn (
        wp (lookup "window_properties" bx)
        idx (find (list (lookup "class" wp)
                        (lookup "instance" wp)
                        (:on? M:flag 1))
                  M:memo)
        rec (list (:on? M:flag 1) (:on? M:flag 2) (number? idx))
        )
        (if
          (= '(true true true) rec)
          (:command-wid ipc4cmd (lookup "window" bx) "floating disable")
          (= '(nil true true) rec)
          (:command-wid ipc4cmd (lookup "window" bx) "floating enable")
          (first rec)
          (:command-wid ipc4cmd (lookup "window" bx) "floating enable")
          (:command-wid ipc4cmd (lookup "window" bx)
            (if(check-wcwi wp) "floating enable" "floating disable")))))))

(define(on-move bx)
  (unless (= (lookup "scratchpad_state" bx) "none")
    (setq vbox:vbox (first (lookup "nodes" bx)))
    (on-new vbox)
    (on-floating vbox)
    (when (ends-with (lookup "floating" vbox:vbox) "on")
      (:run xprop (lookup "window" vbox:vbox)))))

(define(on-workspace-focus , rect)
  (let (lst (json-parse (:getworkspaces ipc4cmd)))
    (setq drawer nil)
    (dolist (e lst rect)
      (when (= (lookup "focused" e) true)
        (setq rect (lookup "rect" e)
              P:wrkspc_y (lookup "y" rect)
              P:wrkspc_height (lookup "height" rect))))))

; main loop
(local (flag data json lttr)
  (map delete '(chunk include isinPATH permutations require))
  (:subscribe ipc4sub {[ "window", "workspace" ]})
  (:run C:off)
  (:run Z:off)
  (on-workspace-focus)
  (post-ins)
  (X:tick)
  (N:tick)
  (when (:on? C:flag 1) (:run C:on))
  (when (:on? Z:flag 1) (:run Z:on))
  (remit)
  (until flag
    (until (net-select (:socket ipc4sub) "r" 35000)
      (dolist (childpid (receive))
        (receive childpid data)
        (when (= childpid polybarpid)
          (setq data (parse $it "_")
                lttr (pop data)
                flag (lettershop lttr data))
          (when (letterfactory lttr) (letters2polybar)))))
    (setq json (json-parse (:receive ipc4sub)))
    (if (setq box:box (lookup "container" json))
      (case (lookup "change" json)
        ("focus" (on-fullscreen box))
        ("new" (on-new box))
        ("floating" (on-floating box))
        ("move" (on-move box))
        ("fullscreen_mode" (on-fullscreen box)))
      (when (lookup "current" json)
        (case (lookup "change" json)
          ("focus" (on-workspace-focus))))))
  (:close ipc4cmd)
  (:close ipc4sub)
  (when (and (:on? A:flag 1) (:on? A:flag 4)) (post-outs)))

(abort)
(exit)
