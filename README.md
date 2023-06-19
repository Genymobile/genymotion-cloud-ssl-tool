# Install a trusted certificate for your Genymotion Cloud instance 

## Prerequisites


1. Your `domain` DNS should already point to your AWS instance IP.
2. You already generated a valid certificate for your `domain`.
3. Adb should be enabled on your instance.
4. Your device must be rooted. (See [here](https://docs.genymotion.com/paas/10_Using_root_access/) for android 10)

## HOWTO
* Clone this repository

```
git clone https://github.com/Genymobile/genymotion-cloud-ssl-tool.git
```

* Go to `genymotion-cloud-ssl-tool` repository

```
cd genymotion-cloud-ssl-tool
```

* Copy your privkey.pem and fullchain.pem to the `genymotion-cloud-ssl-tool` repository

```
cp /path/to/privkey.pem . && cp /path/to/fullchain.pem .
```

* Build this docker

```
docker build -t <name> .
```

`<name>` is how you want to tag your docker

* Run this docker

```
docker run -v <full_path_to_genymotion_cloud_ssl_tool>:/opt/work/ --env package=true --env keystorepassword=<kspassword> --env certpassword=<kppassword> --env domain=<domainName> -t -i <name>
```

`<full_path_to_genymotion_cloud_ssl_tool>` is the complete path to the genymotion-cloud-ssl-tool repository

`<kspassword>` and `<kppassword>`are respectively the keystore and certificate passwords

`<name>` the tag you used to build the docker

Remember to disable adb once you're done.

## I don't want to use Docker

You're free to run and adapt those scripts to your distribution.

Lookup the Dockerfile to install prerequisites and run `package.sh` with your keys in the same directory.
