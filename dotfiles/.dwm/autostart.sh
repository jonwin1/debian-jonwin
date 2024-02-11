#!/bin/bash
#width=2560
#height=1600
#refresh=120
#modeline=$(cvt $width $height $refresh | sed -n 's/^\Modeline //p')
#/bin/bash -c "sleep 0.1 && xrandr --newmode $modeline && xrandr --addmode Virtual-1 ${width}x${height}_${refresh}.00 && xrandr -s ${width}x${height}_${refresh}.00"
wal -R
#feh --no-fehbg --bg-fill pictures/bg.jpg
picom &
slstatus &
unclutter &
wmname LG3D &
dunst &
kmonad .config/miryoku_kmonad.kbd &

