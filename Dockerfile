FROM registry1.dso.mil/ironbank/redhat/ubi/ubi8-minimal:8.5 AS build
USER root

ARG CA_CERT=files/cert.crt
ENV CHEF_LICENSE="accept"

# copy gemfile
COPY ./files/Gemfile /apps/Gemfile

WORKDIR /apps

# copy certs
COPY $CA_CERT /etc/pki/ca-trust/source/anchors/

# update dependencies, install inspec, kubectl, and k8s plugin for inspec
RUN update-ca-trust && microdnf update -y && microdnf module enable ruby:2.7 
RUN microdnf install make gcc-c++ redhat-rpm-config ruby ruby-devel

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" 
RUN install -o root -g root -m 0755 kubectl /usr/bin/kubectl
RUN bundle install 
RUN inspec plugin install train-kubernetes

FROM registry1.dso.mil/ironbank/redhat/ubi/ubi8-minimal:8.5
RUN microdnf module enable ruby:2.7 && microdnf install ruby
COPY --from=build /usr/lib64/gems/ /usr/lib64/gems/ 
COPY --from=build /usr/share/gems /usr/share/gems
COPY --from=build /usr/bin /usr/bin
# COPY --from=build /usr/local/bundle/gems /usr/local/lib/ruby/gems/2.7.0/gems
CMD bash