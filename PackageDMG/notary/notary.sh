#!/bin/bash
source ~/.bash_profile

targetdir=../notarized/
stapledir=../stapled/

echo ${NotaryServicePrivateKey}
echo ${NotaryServiceUserName}

cp ../code_sign/*.dmg .

tar -zcvf notary.tgz Config.txt *.dmg
ssh -i ${NotaryServicePrivateKey} ${NotaryServiceUserName}@${CodeSignServer} < notary.tgz 2>&1 | tee notary.log

grep 'RequestUUID' notary.log > uuid.txt

if [[ $(cat uuid.txt) =~ RequestUUID\ \=\ (.*)$ ]]; then
   uuid=${BASH_REMATCH[1]}
cat <<__EOF__  >${targetdir}/Config.txt
notarization_mode=1
notarized_uuid=${uuid}
__EOF__

  mv *.dmg ${stapledir}
fi
