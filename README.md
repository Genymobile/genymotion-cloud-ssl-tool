# Install a trusted certificate for your Genymotion AWS instance 

## Prerequisites

Adb should be enabled on your instance.

## In case you already have your certificate

* Clone this repository

`git clone https://github.com/Genymobile/aws-ssl.git`

* Go to `aws-ssl` repository

`cd aws-ssl`

* Copy your privkey.pem and fullchain.pem to the `aws-ssl` repository

`cp /path/to/privkey.pem . && cp /path/to/fullchain.pem .`

* Build this docker

`docker build -t <name> .`

`<name>` is how you want to tag your docker

* Run this docker

`docker run --net=host -P -v <path_to_aws_ssl>:/opt/work/ --env package=true --env keystorepassword=<kspassword> --env certpassword=<kppassword> -t -i <name> /opt/work/package.sh <relpath_to_privkey.pem> <relpath_to_fullchain.pem>`

`<relpath_to_privkey.pem>` and `<relpath_to_fullchain.pem>` are relative paths from the `aws-ssl` directory

`<path_to_aws_ssl>` is the complete path to the aws-ssl repository

`<kspassword>` and `<kppassword>`are respectively the keystore and certificate passwords

`<name>` the tag you used to build the docker

Remember to disable adb once you're done.

## I don't want to use Docker

You're free to run and adapt those scripts to your distribution.

Lookup the Dockerfile to install prerequisites and run `package.sh` with your keys in the same directory.
