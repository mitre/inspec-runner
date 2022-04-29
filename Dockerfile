FROM registry1.dso.mil/ironbank/opensource/ruby/ruby27:latest
USER root

ARG CA_CERT=files/cert.crt
ENV CHEF_LICENSE="accept"

# copy gemfile
COPY ./files/Gemfile /apps/Gemfile

# copy kubeconfig
COPY $KUBECONFIG /apps/kubecfg

WORKDIR /apps

# copy certs
COPY $CA_CERT /etc/pki/ca-trust/source/anchors/
RUN update-ca-trust

# yum updates and dependencies
RUN yum update -y && yum install make gcc-c++ -y

# install inspec, kubectl, and k8s plugin for inspec
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
bundle install && \
inspec plugin install train-kubernetes && \
sed -i 's/= 0.1.6/0.1.6/g' /opt/app-root/src/.inspec/plugins.json

# grab kubecfg file
ENV KUBECONFIG=/apps/kubecfg

CMD /bin/bash