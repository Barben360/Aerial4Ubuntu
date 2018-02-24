# Apple TV Aerial Views Screensaver for Ubuntu

This tutorial shows how to install Apple TV Aerial Views Screensaver for Ubuntu. It was only tested on Ubuntu 16.04 but should be compatible with newer versions and probably from Ubuntu 15.04 at least.

## What is Apple TV Aerial Views Screensaver?

Apple TV Aerial Views Screensaver is a collection of high-resolution videos showing splendid point of views of several places in the world such as illustrated below.

<p align="center">
![screencast](https://cloud.githubusercontent.com/assets/499192/10754100/c0e1cc4c-7c95-11e5-9d3b-842d3acc2fd5.gif)
</p>

Ubuntu is a great OS, but not the sexiest ever. Apple TV Aerial Views Screensaver is a great way to improve it.

## 1st step - Retrieving Apple TV Aerial Views video files

Apple TV Aerial Views screensaver need more than 12 GB data to be retrieved.

The following Python script downloads them all:

```python
#!/usr/bin/env python

import json
import os
import requests
import sys

if len(sys.argv) != 2:
  print("Usage: %s <path_to_apple_tv_screensaver_files>" % (sys.argv[0]))
  sys.exit(1)

downloadDir = sys.argv[1]

if downloadDir[-1] != '/':
  downloadDir += '/'

response = requests.get("http://a1.phobos.apple.com/us/r1000/000/" +
     "Features/atv/AutumnResources/videos/entries.json")

screensavers = json.loads(response.text)
for screensaver in screensavers:
  for asset in screensaver['assets']:
    filename = downloadDir + asset['id'] + ".mov"
    if not os.path.isfile(filename):
      print("Downloading %s" % (asset['url'],))
      film = requests.get(asset['url'], stream=True)
      with open (filename, "wb") as filmFile:
        print("Writing %s to %s" % (asset['id'], filename))
        for chunk in film.iter_content(chunk_size=1024):
          if chunk:
            filmFile.write(chunk)
```

where the first and only argument when using the script is the path where to put the video files.

## 2nd step - Removing gnome-screensaver

```bash
sudo apt-get autoremove gnome-screensaver
```

## 3rd step - Installing XScreenSaver
```bash
sudo apt-get install xscreensaver
```

## 4th step - Installing MPV media player
```bash
sudo add-apt-repository ppa:mc3man/mpv-tests
sudo apt-get update
sudo apt-get install mpv
```

## 5th step - Adding Apple TV Aerial Views Screensaver to XScreenSaver

Add this line to programs listed in `~/.xscreensaver` file:

```bash
- Best:         "Apple Aerial"   mpv --really-quiet --shuffle --no-audio       \
                                 --fs --loop=inf --no-stop-screensaver       \
                                 --wid=$XSCREENSAVER_WINDOW --panscan=1      \
                                 <path_to_apple_tv_screensaver_files>/*                      \n\
```

where `<path_to_apple_tv_screensaver_files>` is the folder where are .mov files downloaded in 1st step.

## 6th step - Set XScreenSaver to be run at startup

Go to Settings -> Startup Applications and add new entry:

- __Name:__ XScreenSaver runner
- __Command:__ xscreensaver --nosplash
- __Comment:__ Running XScreenSaver

## 7th step - Preventing XScreenSaver to run when a full-screen application is running

When a full-screen applications is running (Netflix, Youtube, Molotov.tv...), you don't want any screensaver to be run. Using the bash script `xscreensaverstopper.sh` restarts idle timer when a full-screen application in foreground is detected:

```bash
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
```

This script must be run at startup. Like in 6th step, go to Settings -> Startup Applications and add new entry:

- __Name:__ XScreenSaver stopper
- __Command:__ &lt;path_to_xscreensaverstopper&gt;/xscreensaverstopper.sh`
- __Comment:__ Running XScreenSaver

## 8th step - Starting XScreenSaver desktop application

- Run application *Screensaver* in Unity.
- Select mode *Only One Screen Saver*.
- Select *Apple Aerial* in the list.
- Choose the desired time before starting screensaver in field *Blank After*.
- Set *Cycle After* to 0 minutes.

## 9th step - Restart computer

Enjoy!
