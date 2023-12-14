#!/bin/bash
source ~/.bash_profile

targetdir=../notarized/
stapledir=../stapled/

echo ${NotaryServicePrivateKey}
echo ${NotaryServiceUserName}

cp ../code_sign/*.dmg .

tar -zcvf notary.tgz Config.txt *.dmg
ssh -i ${NotaryServicePrivateKey} ${NotaryServiceUserName}@${CodeSignServer} < notary.tgz 2>&1 | tee notary.log

#
# 20231027 changed 公証サーバ変更対応
#                  uuidの出力形式変更対応
#grep 'RequestUUID' notary.log > uuid.txt
#
#if [[ $(cat uuid.txt) =~ RequestUUID\ \=\ (.*)$ ]]; then

grep -A1 'Submission ID received' notary.log | tail -1 > uuid.txt

if [[ $(cat uuid.txt) =~ id:\ (.*)$ ]]; then
   uuid=${BASH_REMATCH[1]}
cat <<__EOF__  >${targetdir}/Config.txt
notarization_mode=1
notarized_uuid=${uuid}
__EOF__

  mv *.dmg ${stapledir}
fi
