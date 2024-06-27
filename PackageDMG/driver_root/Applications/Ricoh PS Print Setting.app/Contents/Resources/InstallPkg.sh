#!/bin/bash

execPath="$1"
printerName="$2"
urlProtocol="$3"
newUserId="$4"

#printerDespName=`echo "${printerName}" | sed "s/ /_/g"`
printerDespName="PS_Driver"
echo ${printerDespName}

/usr/sbin/installer -pkg "${execPath}"/Ricoh_PS_Basic_Driver_Installer.pkg -target / -allowUntrusted
/usr/sbin/lpadmin -p "${printerDespName}" -D "${printerName}" -E -v "${urlProtocol}" -P /Library/Printers/PPDs/Contents/Resources/Cloud\ PS\ Printer
echo /usr/sbin/lpadmin -p "${printerDespName}" -D "${printerName}" -E -v "${urlProtocol}" -P /Library/Printers/PPDs/Contents/Resources/Cloud\ PS\ Printer


srcConfigFile="/tmp/com.rits.PdfDriverInstaller_${USER}.plist"
dstConfigFile="/etc/cups/com.rits.PdfDriverInstaller_${USER}.plist"
dstConfigFileHome="$5"

cp "${srcConfigFile}" "${dstConfigFile}"
cp "${srcConfigFile}" "${dstConfigFileHome}"
