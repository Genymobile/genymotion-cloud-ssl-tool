#!/bin/bash
set -x
if [ -n "${package}" ] ; then
    pushd /opt/work/
    privkey=$1
    fullchain=$2
    ssh -oServerAliveInterval=1 -oServerAliveCountMax=2 -oStrictHostKeyChecking=no -N -i genymotion_aws.pem -L 5555:localhost:5555 root@${domain} &

    # Wait for ssh ...
    sleep 5
else
    privkey=/etc/letsencrypt/live/${domain}/privkey.pem
    fullchain=/etc/letsencrypt/live/${domain}/fullchain.pem 

fi
# Generate temporary PKCS12
openssl pkcs12 -export -inkey ${privkey} -in ${fullchain} -out tmp.pkcs12 -name genymotion -password pass:shortlivedpassword

# Generate BouncyCastle keystore from PKCS12
# First fetch the BouncyCastle provider that'll be used by 'keytool'
wget https://www.bouncycastle.org/download/bcprov-jdk15on-156.jar
# Actually generate stuff
keytool -importkeystore -deststorepass ${keystorepassword} -destkeypass ${certpassword} -deststoretype BKS -destkeystore custom.bks -srckeystore tmp.pkcs12 -srcstoretype PKCS12 -srcstorepass shortlivedpassword -alias genymotion -provider org.bouncycastle.jce.provider.BouncyCastleProvider -providerpath bcprov-jdk15on-156.jar

# Clean up a bit
rm tmp.pkcs12
rm bcprov-jdk15on-156.jar

# Hardwork is done, give useful stuff to Android
adb shell setprop persist.tls.pw.ks ${keystorepassword}
adb shell setprop persist.tls.pw.cert ${certpassword}
adb shell mkdir /data/misc/tls/
adb push custom.bks /data/misc/tls/custom.bks
adb shell sync

