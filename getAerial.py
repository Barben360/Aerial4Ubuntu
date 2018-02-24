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
