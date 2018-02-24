#!/usr/bin/env bash

displays=""
while read id
do
    displays="$displays $id"
done< <(xvinfo | sed -n 's/^screen #\([0-9]\+\)$/\1/p')

timeout_val=`cat ~/.xscreensaver | grep timeout:`
substring_min=$(echo ${timeout_val} | cut -d':' -f 3)
sleep_time=$((${substring_min}*60-30))

checkFullscreen()
{

    # loop through every display looking for a fullscreen window
    for display in $displays
    do
        #get id of active window and clean output
        activ_win_id=`DISPLAY=:0.${display} xprop -root _NET_ACTIVE_WINDOW`
        activ_win_id=${activ_win_id:40:9}
        
        # Check if Active Window (the foremost window) is in fullscreen state
        isActivWinFullscreen=`DISPLAY=:0.${display} xprop -id $activ_win_id | grep _NET_WM_STATE_FULLSCREEN`
        if [[ "$isActivWinFullscreen" == *NET_WM_STATE_FULLSCREEN* ]];then
        	xscreensaver-command -deactivate
	    fi
    done
    timeout_val=`cat ~/.xscreensaver | grep timeout:`
	substring_min=$(echo ${timeout_val} | cut -d':' -f 3)
	sleep_time=$((${substring_min}*60-30))
}



while sleep $((${sleep_time})); do
    checkFullscreen
done

exit 0
