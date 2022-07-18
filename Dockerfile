FROM registry1.dso.mil/ironbank/redhat/ubi/ubi8-minimal:8.5 AS build
USER root

ARG CA_CERT=files/cert.crt

# copy gemfile
COPY ./files/Gemfile /apps/Gemfile

WORKDIR /apps

# copy certs
COPY $CA_CERT /etc/pki/ca-trust/source/anchors/

# update dependencies, install inspec, kubectl, and k8s plugin for inspec
ENV CHEF_LICENSE="accept"
RUN update-ca-trust && microdnf update -y && microdnf module enable ruby:2.7 && \
microdnf install make gcc-c++ redhat-rpm-config ruby ruby-devel git && \
git clone --branch inspec-6 --single-branch https://github.com/inspec/inspec.git && \
cd inspec && bundle install && export PATH=$PATH:inspec/inspec-bin/bin

FROM registry1.dso.mil/ironbank/redhat/ubi/ubi8-minimal:8.5
COPY --from=build /usr/lib64/gems/ /usr/lib64/gems/ 
COPY --from=build /usr/share/gems /usr/share/gems
COPY --from=build /usr/bin /usr/bin
COPY --from=build /apps/inspec /inspec
ENV CHEF_LICENSE="accept"
RUN microdnf module enable ruby:2.7 && microdnf install ruby openssh-clients && \
cd inspec && bundle install && export PATH=$PATH:inspec/inspec-bin/bin 
CMD bash