#!/bin/bash
set -x

BCPROV_JAR=bcprov-jdk15-139b01.jar
BCPROV_URL=https://www.bouncycastle.org/betas/

print_usage_and_exit () {
        echo "usage: $0 <privkey> <fullchain>"
        exit 1
}

if [ -z "$1" ]; then
	print_usage_and_exit
fi

if [ -z "$2" ]; then
	print_usage_and_exit
fi

privkey=$1
fullchain=$2

if [ ! -s ${privkey} ]; then
	echo "${privkey} is empty or not found"
	exit 1
fi

if [ ! -s ${fullchain} ]; then
	echo "${fullchain} is empty or not found"
	exit 2
fi

# Generate temporary PKCS12
openssl pkcs12 -export -inkey ${privkey} -in ${fullchain} -out tmp.pkcs12 -name genymotion -password pass:shortlivedpassword -passin pass:${keystorepassword}

# Generate BouncyCastle keystore from PKCS12
# First fetch the BouncyCastle provider that'll be used by 'keytool'
wget ${BCPROV_URL}/${BCPROV_JAR}

# Generate a BKS keystore from the pkcs12 that contains the certificat
keytool -importkeystore -deststorepass ${keystorepassword} -destkeypass ${certpassword} -deststoretype BKS -destkeystore custom.bks -srckeystore tmp.pkcs12 -srcstoretype PKCS12 -srcstorepass shortlivedpassword -alias genymotion -provider org.bouncycastle.jce.provider.BouncyCastleProvider -providerpath ${BCPROV_JAR}

# Clean up a bit
rm tmp.pkcs12
rm ${BCPROV_JAR}

# Hardwork is done, give useful stuff to Android
adb connect ${domain}:5555
sleep 1
adb root
adb shell mkdir -p /data/misc/tls/
adb push custom.bks /data/misc/tls/custom.bks
adb shell sync
adb shell setprop persist.tls.pw.ks ${keystorepassword}
adb shell setprop persist.tls.pw.cert ${certpassword}

# A last clean up
rm custom.bks
