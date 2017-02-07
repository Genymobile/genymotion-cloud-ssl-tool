#/bin/bash
#set -x
pushd /opt/work/

# Make adb work
ssh -oServerAliveInterval=1 -oServerAliveCountMax=2 -oStrictHostKeyChecking=no -N -i genymotion_aws.pem -L 5555:localhost:5555 root@${domain} &

# Wait for ssh ...
sleep 5

# Make /system/ writable
adb remount

# Patch sshd_config to allow tunnel for webserver
adb pull /system/etc/ssh/sshd_config
sed -i -e 's/#GatewayPorts no/GatewayPorts yes/g' sshd_config
adb push sshd_config /system/etc/ssh/
adb shell sync

# ssh reload
adb shell stop sshd
sleep 1
adb shell start sshd

# free up port 80
adb shell stop httpd_redirect
sleep 1

# Setup tunnel for webserver
ssh -oServerAliveInterval=1 -oServerAliveCountMax=2 -oStrictHostKeyChecking=no -N -i genymotion_aws.pem -R 0.0.0.0:80:localhost:8888 root@${domain} &

# Setup webserver
pushd /tmp/
python3 -m http.server 8888 &
popd

# Grab certbot
wget https://dl.eff.org/certbot-auto
chmod a+x ./certbot-auto

# Run certbot
./certbot-auto -v --agree-tos --email ${usermail} -q certonly -d ${domain} --webroot -w /tmp/
rm certbot-auto

# Remove previous sshd_config patch
sed -i -e 's/GatewayPorts yes/#GatewayPorts no/g' sshd_config
adb push sshd_config /system/etc/ssh/
adb shell sync
rm sshd_config

# ssh reload
adb shell stop sshd
adb shell start sshd

# Generate temporary PKCS12
openssl pkcs12 -export -inkey /etc/letsencrypt/live/${domain}/privkey.pem -in /etc/letsencrypt/live/${domain}/fullchain.pem -out tmp.pkcs12 -name genymotion -password pass:shortlivedpassword

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

adb reboot
echo "You should be able to use https://${domain}/ now"
echo "Remember to check your EC2 security group(s) if you modified them for this to run"
popd
