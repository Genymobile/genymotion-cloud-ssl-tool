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

. ./package.sh

adb reboot
echo "You should be able to use https://${domain}/ now"
echo "Remember to check your EC2 security group(s) if you modified them for this to run"
popd
