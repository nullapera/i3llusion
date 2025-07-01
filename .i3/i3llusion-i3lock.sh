#!/bin/sh
exec scrot --silent --quality 33 --format jpg - |
  magick jpg:- -scale 10% -scale 1000% -edge 1 -blur 2 rgb:- |
  i3lock \
    --raw $(xdpyinfo | sed -n 's/dimensions:[ ]*\([0-9]*x[0-9]*\).*/\1/p;TL;q;:L'):rgb \
    --image /dev/stdin \
    --radius 128 \
    --ring-width 24 \
    --clock \
    --time-str "%H : %M" \
    --date-str "" \
    --time-pos "w/2:18" \
    --time-color "44ffaadd" \
    --time-font "Roboto:Bold" \
    --time-size 16 \
    --greeter-text "#i3llusion" \
    --greeter-color "44ffaadd" \
    --greeter-font "JetBrains Mono:Bold" \
    --greeter-size 16 \
    --greeter-pos "w/2:h-4" \
    --inside-color "#00000088" \
    --ring-color "#88ffcc88" \
    --keyhl-color "#88ffccdd" \
    --bshl-color "#ffcc88dd" \
    --insidever-color "#88aaffdd" \
    --ringver-color "#88aaffdd" \
    --insidewrong-color "#ff88aadd" \
    --ringwrong-color "#ff88aadd"
