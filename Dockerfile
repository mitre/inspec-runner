FROM registry1.dso.mil/ironbank/redhat/ubi/ubi8-minimal:8.5 AS build
USER root

ARG CA_CERT=files/cert.crt

# copy gemfile
COPY files/Gemfile /apps/Gemfile

WORKDIR /apps

# copy certs
COPY $CA_CERT /etc/pki/ca-trust/source/anchors/

# update dependencies, clone inspec v6 branch from github
ENV CHEF_LICENSE="accept"
RUN update-ca-trust && microdnf update -y && microdnf module enable ruby:2.7 && \
microdnf install make gcc-c++ redhat-rpm-config ruby ruby-devel git yum-utils && \
git clone --branch inspec-6 --single-branch https://github.com/inspec/inspec.git && \
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo && \
microdnf install vault && setcap -r /usr/bin/vault && \
cd inspec && bundle install && \
export PATH=$PATH:/inspec/inspec-bin/bin && rm /etc/pki/ca-trust/source/anchors/*

FROM registry1.dso.mil/ironbank/redhat/ubi/ubi8-minimal:8.5
COPY --from=build /usr/lib64/gems/ /usr/lib64/gems/ 
COPY --from=build /usr/share/gems /usr/share/gems
COPY --from=build /usr/bin /usr/bin
COPY --from=build /apps/inspec /inspec
WORKDIR /inspec
ENV CHEF_LICENSE="accept"
RUN microdnf module enable ruby:2.7 && microdnf install ruby openssh-clients && \
bundle install && export PATH=$PATH:/inspec/inspec-bin/bin && \
useradd runner && chown -R runner /inspec
USER runner
CMD bash
