FROM buildpack-deps:jessie-scm
MAINTAINER Marat Garafutdinov <marat.g@samsung.com>

# versions
ENV TERRAFORM_VERSION 0.6.8
ENV TERRAFORM_EXECUTE_VERSION v0.0.2
ENV TERRAFORM_COREOSBOX_VERSION v0.0.1
ENV KUBERNETES_VERSION v1.1.3

# python and ansible
RUN apt-get update \
    && apt-get install -y --force-yes \
      curl \
      unzip \
      jq \
      build-essential \
      python-yaml \
      python-jinja2 \
      python-httplib2 \
      python-keyczar \
      python-paramiko \
      python-setuptools \
      python-pkg-resources \
      python-pip \
      openssh-client \
      vim \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /etc/ansible/
RUN pip install ansible
COPY ansible/build/other/ansible.cfg /etc/ansible/ansible.cfg

# get terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# get custom providers
RUN wget https://github.com/Samsung-AG/terraform-provider-execute/releases/download/${TERRAFORM_EXECUTE_VERSION}/terraform-provider-execute_linux_amd64.tar.gz
RUN wget https://github.com/Samsung-AG/terraform-provider-coreosbox/releases/download/${TERRAFORM_COREOSBOX_VERSION}/terraform-provider-coreosbox_linux_amd64.tar.gz

# decompress everything
RUN unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
    && tar -xvf terraform-provider-coreosbox_linux_amd64.tar.gz \
    && tar -xvf terraform-provider-execute_linux_amd64.tar.gz

# install all binaries
RUN cp terraform* /usr/local/bin

# cleanup
RUN rm terraform*

# install kubectl
RUN wget https://github.com/GoogleCloudPlatform/kubernetes/releases/download/${KUBERNETES_VERSION}/kubernetes.tar.gz
RUN tar -xvf kubernetes.tar.gz
RUN cp kubernetes/platforms/linux/amd64/kubectl /usr/bin && rm kubernetes.tar.gz

# install awscli
RUN pip install awscli

# generate a keypair
RUN ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa

COPY ansible /opt/kraken/ansible/
COPY terraform /opt/kraken/terraform
COPY hack /opt/kraken/hack
COPY bin/build/terraform-up.sh /opt/kraken/terraform-up.sh
COPY bin/build/terraform-down.sh /opt/kraken/terraform-down.sh
COPY bin/build/docker-utils.sh /opt/kraken/docker-utils.sh