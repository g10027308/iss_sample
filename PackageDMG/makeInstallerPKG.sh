#!/bin/bash
#created  by YangGuangJing   @ 2019/03/07

source ~/.bash_profile

if [ ${CodeSignUserName} ]; then
        echo "CodeSignUserName : ${CodeSignUserName}"
else
        echo "Input CodeSignUserName :"
        read KeyInput
        echo "\nexport CodeSignUserName=$KeyInput" >> ~/.bash_profile
fi

if [ ${CodeSignPrivateKey} ]; then
        echo "CodeSignPrivateKey : ${CodeSignPrivateKey}"
else
        echo "Input CodeSignPrivateKeyPath :"
        read KeyInput
        echo "\nexport CodeSignPrivateKey=$KeyInput" >> ~/.bash_profile
fi

echo "Start."
echo "=================================================="
echo ""
DMGName=Ricoh\ PS\ Driver\ for\ mac_na_O365_V1.5.0.0
SignServer=${CodeSignServer}

function createInstallerPkg(){
	echo "createInstallerPkg"
	SettingApp=`ls  "./SettingsApp/" | grep ".app"`
	if [ -n "${SettingApp}" ]
    then
		echo ""
    	echo "Sign *Setting.app."
		echo ""
		echo "${SettingApp}"
		rm -R -rf ./code_sign/*
		mv "./SettingsApp/${SettingApp}" "./code_sign/${SettingApp}"
		cd ./code_sign/

		tar -zcf app.tgz "./${SettingApp}"
		ssh -T -i ${CodeSignPrivateKey} ${CodeSignUserName}@${SignServer} < app.tgz > signed_app.tgz
		rm -R -rf "./${SettingApp}"
		tar -zxf signed_app.tgz

		echo "Check Signed ${SettingApp}."
		echo ""
		codesign -dvvv "${SettingApp}"

		rm -R -rf ../driver_root/Applications/*
		mv "${SettingApp}" "../driver_root/Applications/${SettingApp}"
		cd ../
	fi

	rm ./Ricoh_Cloud_PS_Printer_LIO_Driver.pkg
	rm ./Ricoh_PS_Basic_Driver_Installer.pkg

	pkgbuild --root driver_root/ --component-plist driver.plist Ricoh_Cloud_PS_Printer_LIO_Driver.pkg

	rm -R -rf ./code_sign/*


	echo ""
	echo "Create Ricoh_Cloud_PS_Printer_LIO_Driver.pkg."
	echo ""
	mv ./Ricoh_Cloud_PS_Printer_LIO_Driver.pkg ./code_sign/Ricoh_Cloud_PS_Printer_LIO_Driver.pkg

	cd ./code_sign/
 
	echo ""
	echo "Sign Ricoh_Cloud_PS_Printer_LIO_Driver.pkg."
	echo ""
	tar -zcf pkg.tgz ./Ricoh_Cloud_PS_Printer_LIO_Driver.pkg
	ssh -T -i ${CodeSignPrivateKey} ${CodeSignUserName}@${SignServer} < pkg.tgz > signed_pkg.tgz
	rm ./Ricoh_Cloud_PS_Printer_LIO_Driver.pkg
	tar -zxf signed_pkg.tgz

	echo ""
	echo "Check Signed Ricoh_Cloud_PS_Printer_LIO_Driver.pkg."
	echo ""
	pkgutil --check-signature ./Ricoh_Cloud_PS_Printer_LIO_Driver.pkg
	echo ""

	mv ./Ricoh_Cloud_PS_Printer_LIO_Driver.pkg ../contents/Ricoh_Cloud_PS_Printer_LIO_Driver.pkg

	cd ../

	echo ""
	echo "Create Ricoh_PS_Basic_Driver_Installer.pkg."
	echo ""
	rm ./Ricoh_PS_Basic_Driver_Installer.pkg
	productbuild --distribution ./Distribution --package-path ./contents/ Ricoh_PS_Basic_Driver_Installer.pkg

	rm -R -rf ./code_sign/*
	mv ./Ricoh_PS_Basic_Driver_Installer.pkg ./code_sign/Ricoh_PS_Basic_Driver_Installer.pkg

	cd ./code_sign/

	echo ""
	echo "Sign Ricoh_PS_Basic_Driver_Installer.pkg."

	tar -zcf pkg.tgz ./Ricoh_PS_Basic_Driver_Installer.pkg
	ssh -T -i ${CodeSignPrivateKey} ${CodeSignUserName}@${SignServer} < pkg.tgz > signed_pkg.tgz
	rm ./Ricoh_PS_Basic_Driver_Installer.pkg
	tar -zxf signed_pkg.tgz

	echo "Check Signed Ricoh_PS_Basic_Driver_Installer.pkg."
	echo ""
	pkgutil --check-signature ./Ricoh_PS_Basic_Driver_Installer.pkg
	echo ""

	mv ./Ricoh_PS_Basic_Driver_Installer.pkg ../Ricoh_PS_Basic_Driver_Installer.pkg
}

function createDrvDMG(){
	InstallerApp=`ls  "./InstallerApp/" | grep ".app"`
	if [ -n "${InstallerApp}" ]
    then
    	echo ""
    	echo "Sign *Installer.app."
		echo ""
		echo "${InstallerApp}"
		rm -R -rf ./code_sign/*
		mv "./InstallerApp/${InstallerApp}" "./code_sign/${InstallerApp}"
		cd ./code_sign/

		tar -zcf app.tgz "./${InstallerApp}"
		ssh -T -i ${CodeSignPrivateKey} ${CodeSignUserName}@${SignServer} < app.tgz > signed_app.tgz
		rm -R -rf "./${InstallerApp}"
		tar -zxf signed_app.tgz

		echo "Check Signed ${InstallerApp}."
		echo ""
		codesign -dvvv "${InstallerApp}"

		mkdir "${DMGName}"
    	#rm -R -rf /${DMGName}/*
		mv "${InstallerApp}" "${DMGName}"
		hdiutil create -srcfolder "${DMGName}" "${DMGName}.dmg"
		cp "${DMGName}.dmg" ./

		cd ../
	fi
}

function signBackend(){
	
		cd ./code_sign/

		tar -zcf app.tgz "./print2server"
		ssh -T -i ${CodeSignPrivateKey} ${CodeSignUserName}@${SignServer} < app.tgz > signed_app.tgz
		rm -R -rf "./print2server"
		tar -zxf signed_app.tgz


		cp -rf "print2server" ../driver_root/usr/libexec/cups/backend/

		echo "Check Signed print2server."
		echo ""
		codesign -dvvv "../driver_root/usr/libexec/cups/backend/print2server"
		echo ""
		echo "End."
		cd ../
	
}

	PRAM="$1"
	if [ "dmg" = "${PRAM}" ]
	then
		createDrvDMG
	elif [ "pkg" = "${PRAM}" ]
	then
		createInstallerPkg
	elif [ "bkd" = "${PRAM}" ]
	then
		signBackend
	else
			echo "Nothing to do."
			echo "Create Installer PKG by Enter:bash makeInstallerPKG.sh pkg"
			echo "Create Installer DMG by Enter:bash makeInstallerPKG.sh dmg"
	fi

echo "Done."
echo "=================================================="
echo ""
