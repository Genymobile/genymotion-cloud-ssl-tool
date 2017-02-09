# Install a trusted certificate for your Genymotion AWS instance 

## Prerequisites

You need to point a DNS to your AWS instance IP. You can’t use the DNS provided by AWS since let’s encrypt servers won’t accept those.
Your AWS security group should allow let’s encrypt servers

Your AWS instance private key should be renamed or symlinked as `genymotion_aws.pem`

Adb should be enabled on your instance.

## Generate your certificate with Let's Encrypt

* Clone this repository

`git clone https://github.com/Genymobile/aws-ssl.git`

* Go to `aws-ssl` repository

`cd aws-ssl`

* Copy your genymotion_aws.pem key in this repository

* Build this docker

`docker build -t <name> .`

`<name>` is how you want to tag your docker

* Run this docker

`docker run --net=host -P -v <path_to_aws_ssl>:/opt/work/ --env domain=<domain> --env usermail=<mail> --env keystorepassword=<kspassword> --env certpassword=<kppassword> -t -i <name>  /opt/work/generate.sh`

`<path_to_aws_ssl>` is the complete path to the aws-ssl repository

`<domain>` is the DNS of your AWS instance (cf prerequisites)

`<mail>`is your email

`<kspassword>` and `<kppassword>`are respectively the keystore and certificate passwords

`<name>` the tag you used to build the docker

Remember to disable adb once you're done.

## In case you already have your certificate

* Follow previous steps but don't `docker run` just yet

* Copy your privkey.pem and fullchain.pem to the `aws-ssl` repository

* Run this docker

`docker run --net=host -P -v <path_to_aws_ssl>:/opt/work/ --env domain=<domain> --env package=true --env keystorepassword=<kspassword> --env certpassword=<kppassword> -t -i <name> /opt/work/package.sh <relpath_to_privkey.pem> <relpath_to_fullchain.pem>`

`<relpath_to_privkey.pem>` and `<relpath_to_fullchain.pem>` are relative paths from the `aws-ssl` directory

Remember to disable adb once you're done.

## I don't want to use Docker

You're free to run and adapt those scripts to your distribution.

Lookup the Dockerfile to install prerequisites and run `generate.sh` with your `genymotion_aws.pem` key in the same directory.
