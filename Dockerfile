FROM ubuntu:22.04

RUN apt-get -qq update && \
    apt-get install -y \
        ssh \
        default-jdk \
        android-tools-adb \
        openssl

WORKDIR /opt/work
ENTRYPOINT ./package.sh privkey.pem fullchain.pem
