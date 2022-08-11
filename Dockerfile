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
microdnf install make gcc-c++ redhat-rpm-config ruby ruby-devel && \
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
install -o root -g root -m 0755 kubectl /usr/bin/kubectl && \
bundle install && \
inspec plugin install train-kubernetes

FROM registry1.dso.mil/ironbank/redhat/ubi/ubi8-minimal:8.5
RUN microdnf module enable ruby:2.7 && microdnf install ruby openssh-clients && \
useradd runner
USER runner
COPY --from=build /usr/lib64/gems/ /usr/lib64/gems/ 
COPY --from=build /usr/share/gems /usr/share/gems
COPY --from=build /usr/bin /usr/bin
ENV CHEF_LICENSE="accept"
CMD bash