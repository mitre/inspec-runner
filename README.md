# inspec-runner-container

Quick and dirty containerized InSpec runner, built from IronBank ubi8-minimal.

## Use Case

This container packages InSpec and all dependencies into a relatively small container that is ultimately sourced from IronBank. There may be further possible size optimizations.

`docker run -it --name inspec-runner inspec-runner:latest inspec shell`

## Building the image

`docker build --build-arg CA_CERT=./files/ca-certificates.crt -t inspec-runner:latest .`

The image will likely require a CA_CERT file to be passed to avoid SSL errors as it tries to install dependencies. Drop off the relevant cert (i.e. the MITRE root certificate if you are behind the MITRE proxy) into `files/ca-certificates.crt`.

You will need to be able to access IronBank to pull the base image.