# SSL Certificate generation with let's encrypt

# Before running this, your <domain> DNS should already point to your
# AWS instance IP and your AWS security group should allow let's encrypt servers

# HOWTO
# git clone https://github.com/genymobile/aws-ssl/
# cd aws-ssl
# put your own genymotion_aws.pem file there (or symlink it)
# build this docker:
    # docker build -t <usr>/<name> .

# To use existing certificate
# docker run --net=host -P -v <path_to_aws_ssl>:/opt/work/ --env domain=<domain> --env package=true --env keystorepassword=<kspassword> --env certpassword=<kppassword> -t -i <usr>/<name> /opt/work/package.sh <relpath_to_privkey.pem> <relpath_to_fullchain.pem>

# Alternatively, you could install those dependencies on your own distro, set environnment variables
# according to the 'docker run' line and run generate.sh

FROM ubuntu:16.04

RUN echo "deb http://archive.ubuntu.com/ubuntu/ trusty-security multiverse" >> /etc/apt/sources.list && apt update

RUN apt install -y \
        ssh \
        default-jdk \
        android-tools-adb \
        python python-dev \
        gcc \
        libssl-dev \
        openssl \
        libffi-dev \
        ca-certificates \
        virtualenv

EXPOSE 8888

ENTRYPOINT ["/bin/bash"]
