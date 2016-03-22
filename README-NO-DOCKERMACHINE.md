# Local non-cloud cluster 

This document describes how to run a Kraken Kubernetes cluster locally using Terraform, Vagrant, and Samsung vagrant and coreos providers.

The difference between running on a cloud environment (AWS) and locally is that instead of building a container and having that container connect to AWS (or other cloud) and running all the steps and possessing all the necessary software (Ansible, AWS client, terraform, terraform drivers, etc) the local host will run all of these steps and use a local hypervisor (Virtualbox by default) and use Samsung's terraform execute provider to run vagrant and provide it the necessary arguments for setting up the machines the cluster will run on. It should be noted that a docker container still runs on every virtual machine for the provisioning of that machine the same way the EC2 AMIs run docker to do the same.

1. OS X Setup amd Requirements
1. Linux Setup amd Requirements
1. Release the Kraken! (aka Configure and Start your cluster)
1. Interact with your kubernetes cluster
1. Destroy Cluster

----

# 1. OS X Setup amd Requirements

On OS X, brew is the means of obtaining Terraform and other components:

## Tools setup all in one shot:
Quick setup on OSX with [homebrew](http://brew.sh/) Ensure that you are in the Kraken file (cd kraken):

    brew update
    brew tap Samsung-AG/homebrew-terraform
    brew bundle

This installs Ansible, Terraform, Vagrant, Virtualbox, kubectl, awscli and custom terraform providers 'terraform-provider-execute', 'terraform-provider-coreosbox'.  
If terraform is having trouble finding the custom providers, try explicitly uninstalling them and re-installing them, eg:

    for formula in $(grep 'brew.*terraform-provider' Brewfile | awk '{print $2}' | tr -d "'"); do
      brew uninstall $formula
    done
    brew bundle
    

 

## Adding terraform drivers if all other packages already installed

In the case where you already have a hypervisor (Virtualbox, Vmware Fusion, etc.), ansible, AWS CLI already installed, simply install Terraform and the Samsung-specific providers.

### Install Terraform:

Access [Terraform download page](https://www.terraform.io/downloads.html) to obtain the download for your OS. Unzip the archive, and copy all terraform* binaries in the uncompressed directory to ```/usr/local/bin```

#### Install terraform-provider-execute:

    brew tap Samsung-AG/terraform-provider-execute
    brew install terraform-provider-execute

#### Install terraform-provider-coreosbox

    brew tap Samsung-AG/terraform-provider-coreosbox
    brew install terraform-provider-coreosbox

#### Install ```kubectl```

    brew install kubectl


You can now jump to **Release the Kraken** to continue.

---
# 2. Linux Setup amd Requirements

With Linux, these components must be installed according to the following steps. The following shows installing on Debian-based Linux. Mileage may vary, and RH-based Linux will be different.

## Debian-based pre-reqs

### Update debian packages

    sudo apt-get update
    sudo apt-get dist-upgrade

* Ensure ```/usr/local/bin``` is in your path.
* ```sudo shutdown -r # force reboot and latest kernel to be run```

### Install prerequisite packages needed for Ansible and Go:
    sudo apt-get install python-pip python-dev build-essential unzip
    sudo pip install ansible

## Install Docker

    sudo apt-get install apt-transport-https ca-certificates
    sudo apt-key adv \
      --keyserver hkp://p80.pool.sks-keyservers.net:80 \
      --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    sudo touch /etc/apt/sources.list.d/docker.list
    sudo sh -c \
      "echo 'deb https://apt.dockerproject.org/repo ubuntu-wily main' >>  /etc/apt/sources.list.d/docker.list"
    sudo apt-get update
    sudo apt-get install docker-engine
      ## the service is not started during install.
    sudo service docker start

## Install [Vagrant](https://www.vagrantup.com/downloads.html) 
    wget https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.deb
    sudo dpkg vagrant_1.8.1_x86_64.deb

## Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads) 
    wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
    sudo echo "deb http://download.virtualbox.org/virtualbox/debian vivid contrib" > /etc/apt/sources.list.d/virtualbox.list
    sudo apt-get update

## Install Go

There are packages for go via ```apt``` on Ubuntu, but the most recent release of go from the [official go site](https://golang.org/doc/install) is preferable

### Obtain and un-archive the go package
    wget https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.6.linux-amd64.tar.gz

### Create a user-level go directory:
    export GOROOT=/usr/local/go

### Set paths for go 
(add to ```.bashrc``` or ```.bash_profile```)

    mkdir -p $HOME/go/bin 
    export GOPATH=$HOME/go
    export GOBIN=$GOPATH/bin


## Install awscli
    wget https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
    unzip awscli-bundle.zip
    sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

## Install [Terraform ](https://www.terraform.io/downloads.html)
    wget  https://releases.hashicorp.com/terraform/0.6.13/terraform_0.6.13_linux_amd64.zip
    unzip terraform_0.6.13_linux_amd64.zip
    sudo mv terraform-pro* /usr/local/bin/


## Install Terraform and Samsung Terraform providers

### Obtain terraform-provider-execute 

binary:

    wget https://github.com/Samsung-AG/terraform-provider-execute/releases/download/v0.0.2/terraform-provider-execute_linux_amd64.tar.gz
    tar xvzf terraform-provider-execute_linux_amd64.tar.gz
    sudo mv terraform-provider-execute /usr/local/bin
    
or build it:

    go get github.com/Samsung-AG/terraform-provider-execute

### Obtain [terraform-provider-coreos](https://github.com/Samsung-AG/homebrew-terraform-provider-coreos/releases) 

build it:

    go get github.com/Samsung-AG/terraform-provider-coreosbox
    sudo mv $GOBIN /usr/local/bin

### Obtain [terraform-provider-coreos](https://github.com/Samsung-AG/homebrew-terraform-provider-coreos/releases) 
binary:

    wget https://github.com/Samsung-AG/homebrew-terraform-provider-coreos/releases/download/v0.0.1/terraform-provider-coreos_linux_amd64.tar.gz
    tar xvzf terraform-provider-coreos_linux_amd64.tar.gz
    sudo mv terraform-provider-coreos /usr/local/bin

### Obtain [terraform-provider-coreosver](https://github.com/Samsung-AG/terraform-provider-coreosver/releases) 
binary:

    wget https://github.com/Samsung-AG/terraform-provider-coreosver/releases/download/v0.0.1/terraform-provider-coreosver_linux_amd64.tar.gz
    tar xvzf terraform-provider-coreosver_linux_amd64.tar.gz
    sudo mv terraform-provider-coreosver /usr/local/bin
or build it:

    go get github.com/Samsung-AG/terraform-provider-coreos

## Install latest [kubectl](https://github.com/GoogleCloudPlatform/kubernetes/releases/latest). Make sure ```kubectl``` is in your PATH

    wget https://github.com/kubernetes/kubernetes/releases/download/v1.2.0/kubernetes.tar.gz
    tar xvzf kubernetes.tar.gz
    sudo cp ./kubernetes/platforms/linux/amd64/kubectl /usr/local/bin/

You can now jump to **Release the Kraken!** to continue.

---
# 3. Release the Kraken!
Now that you have the required programs and packages installed its time to configure your the cluster.


## Set up the cluster directory

In your ```kraken``` git clone, create a terraform cluster directory. In the example below, the name of the cluster is ```test-cluster```

    mkdir terraform/local/test-cluster

### Edit the terraform variables file

Create the terraform variables file for the cluster. It will reside in ```terraform/local/test-cluster``` as ```terraform.tfvars```. In this example, the user wants to use 192.168.1.0 network for the cluster, with 1 API server, and 3 minions:


    apiserver_count = "1"
    node_count = "3"
    cluster_name = "test-cluster"
    apiserver_ip_address = "192.168.1.3"
    ip_base = "192.168.1"



## Create the cluster!

Once you are done with tools setup and variable settings you should be able to create a cluster:

    terraform apply -input=false -state=terraform/<cluster type>/terraform.tfstate terraform/<cluster type>

Or (overriding node_count variable)

    terraform apply -input=false -state=terraform/aws/terraform.tfstate -var 'node_count=10' terraform/aws
    
Or using the ```test-cluster``` local cluster example above, you would run: 

    terraform apply -input=false -state=terraform/local/test-cluster/terraform.tfstate -var-file=terraform/local/test-cluster/terraform.tfvars terraform/local


If you don't specify the -state switch, terraform will write the current 'state' to pwd - which could be a problem if you are using multiple cluster types.


# Interact with your kubernetes cluster
Terraform will write a kubectl config file for you. To issue cluster commands just use

    kubectl <command>

for example

    kubectl get pods

To reach specific clusters, issue the follow command

    kubectl --cluster=<cluster_name> <command>

for example
    
    kubectl --cluster=aws_kubernetes get nodes

Example output:

    $ kubectl get nodes
    NAME            STATUS    AGE
    192.168.1.104   Ready     14h
    192.168.1.105   Ready     14h
    192.168.1.106   Ready     14h
    $ kubectl get pods,rc,services
    NAME               READY            STATUS             RESTARTS   AGE
    prometheus-a1zwz   2/4              CrashLoopBackOff   326        14h
    NAME               DESIRED          CURRENT            AGE
    prometheus         1                1                  14h
    NAME               CLUSTER-IP       EXTERNAL-IP        PORT(S)                      AGE
    kubernetes         10.100.0.1       <none>             443/TCP                      14h
    prometheus         10.100.249.101   nodes              9090/TCP,3000/TCP,9091/TCP   14h
  
---  
# Destroy Cluster
Destroy a running cluster by running:

    terraform destroy -input=false -state=terraform/<cluster type>/terraform.tfstate terraform/<cluster type>

## Optional remote setup for Terraform
You could setup [remote state](https://www.terraform.io/intro/getting-started/remote.html) for Terraform, if you want to be able to control your cluster lifecycle from multiple machines (only applies to non-local clusters)

## SSH to cluster nodes
Ansible provisioning creates a ssh config file for each cluster type in you .ssh folder. You can ssh to node names using this file:

    ssh -F ~/.ssh/config_<cluster_name> node-001
    ssh -F ~/.ssh/config_<cluster_name> master
    ssh -F ~/.ssh/config_<cluster_name> etcd

And so on...
