FROM registry1.dso.mil/ironbank/redhat/ubi/ubi8-minimal:8.5 AS build
USER root

ARG CA_CERT=files/cert.crt

# copy gemfile
COPY ./files/Gemfile /apps/Gemfile
# copy certs
COPY $CA_CERT /etc/pki/ca-trust/source/anchors/

WORKDIR /apps
ENV CHEF_LICENSE="accept"

# update dependencies, install inspec, kubectl (needs root)
RUN update-ca-trust && microdnf update -y && microdnf module enable ruby:3.0 && \
microdnf install make gcc-c++ redhat-rpm-config ruby ruby-devel git yum-utils wget tar vi && \
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
install -o root -g root -m 0755 kubectl /usr/bin/kubectl

# install inspec-6 branch from GitHub (for Parallel), install psql
RUN git clone --branch inspec-6 --single-branch https://github.com/inspec/inspec.git && \
cd inspec && bundle install && cd .. && \
wget https://ftp.postgresql.org/pub/source/v13.10/postgresql-13.10.tar.gz && tar -xvzf postgresql-13.10.tar.gz && \
cd postgresql-13.10 && ./configure --without-readline --without-zlib && make install && cd ..

# RUN inspec plugin install train-kubernetes && \
# sed -i 's/= 0.1.6/0.1.6/g' ~/.inspec/plugins.json

RUN useradd runner 
USER runner

CMD bash