#!/bin/sh -


srcConfigFile="/tmp/com.rits.PdfDriverInstaller_${USER}.plist"
#dstConfigFile="/Library/Preferences/"
#dstConfigFileHome is the User's Directory.
dstConfigFileHome="$1"

#cp "${srcConfigFile}" "${dstConfigFile}"
cp "${srcConfigFile}" "${dstConfigFileHome}"
#dstConfigFile1="/etc/cups/"
#cp "${srcConfigFile}" "${dstConfigFile1}"
dstConfigFile="/etc/cups/com.rits.PdfDriverInstaller_${USER}.plist"
cp "${srcConfigFile}" "${dstConfigFile}"

chgrp wheel "${dstConfigFile}"
chmod 640 "${dstConfigFile}"
