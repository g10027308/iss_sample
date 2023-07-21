#!/bin/bash
source ~/.bash_profile

echo ${NotaryServicePrivateKey}
echo ${NotaryServiceUserName}

tar -zcvf uuidcheck.tgz Config.txt
ssh -i ${NotaryServicePrivateKey} ${NotaryServiceUserName}@${CodeSignServer} < uuidcheck.tgz 2>&1 | tee check_notary.log

