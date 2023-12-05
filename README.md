# inspec-runner-container

## TODO

### Image Updates

- [ ] Update to UBI9 with Ruby
- [ ] Build an 'inspec' and 'CINC' version
  - [ ] CINC version can pull gems from https://packagecloud.io/cinc-project/stable
- [ ] Perhaps add a matrix of 5.x and 6.x
- [ ] Add a Volume mount for local CA certs for the user
  - [ ] Add an 'update-ca-certs' on start of the container to pull in the volume mounted ones
- [ ] Add AWS CLI
  - [ ] Expose AWS_SECRET, AWS_PROFILE, AWS_CA_BUNDLE, AWS_ACCESS_KEY, AWS_TOKEN...
- [ ] Add psql for postgres profile ( and plugin )
- [ ] Add psql-plus for oracle profile ( and plugin )
- [ ] Add kurbctl for kubernetes profile ( and plugin )
- [ ] Add mssql-client? ( v2 perhaps? )
- [ ] train-winrm standard??

### Plugins

- [ ] inspec-aws and inspec-kurbernetes are now defaults in cinc/inspec 5x and 6x

Containerized InSpec runner, built from IronBank ubi8-minimal.

## Use Case

This container packages InSpec and all dependencies into a relatively small container that is ultimately sourced from IronBank. There may be further possible size optimizations.

`docker run -it --name inspec-runner inspec-runner:latest inspec shell`

## Features

- InSpec installation includes the [train-kubernetes](https://github.com/bgeesaman/train-kubernetes) plugin to allow testing against a K8S cluster (see the [K8S Cluster STIG profile](https://github.com/mitre/k8s-cluster-stig-baseline)).

## Building the image

`docker build --build-arg CA_CERT=./files/ca-certificates.crt -t inspec-runner:latest .`

The image will likely require a CA_CERT file to be passed to avoid SSL errors as it tries to install dependencies. Drop off the relevant cert (i.e. the MITRE root certificate if you are behind the MITRE proxy) into `files/ca-certificates.crt`.

You will need to be able to access IronBank to pull the base image.

## Using the image

`docker exec inspec-runner -- inspec exec <profile url> -t <target variables> --reporter cli json:test-results.json`

Note that when launching the runner, you should mount a volume to serve as the destination for the test results JSON file to allow the container host access to it.

```shell
docker run -it -v $PWD/path-to-volume:/data --name inspec-runner inspec-runner:latest inspec shell
```

The container image
