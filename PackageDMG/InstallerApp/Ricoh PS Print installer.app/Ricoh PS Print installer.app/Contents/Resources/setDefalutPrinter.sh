#!/bin/bash

/usr/bin/defaults write ~/Library/Preferences/org.cups.PrintingPrefs.plist UseLastPrinter -bool FALSE
/usr/bin/lpoptions -d "PS_Driver"
