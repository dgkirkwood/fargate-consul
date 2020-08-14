provider "aws" {
    region = var.aws_region
    version = "~> 2.7"
}



#Find Ubuntu AMI for hosting Consul server
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}


#Create EC2 instance to host consul server
#Default size is T2.micro, fine for demo
resource "aws_instance" "consul-server" {
    ami           = data.aws_ami.ubuntu.id
    instance_type = var.consul_instance_size

    network_interface {
        network_interface_id = aws_network_interface.consul-server.id
        device_index         = 0
    }
    #User data field to grab Consul binary, create necessary directories and start agent with config
    #Relies on the file provisioner in the same resource
    user_data = <<EOF
#!/bin/bash
wget https://releases.hashicorp.com/consul/1.8.0/consul_1.8.0_linux_amd64.zip
sudo apt install unzip
unzip consul_1.8.0_linux_amd64.zip
sudo mv consul /usr/local/bin/
sudo mkdir /opt/consul/
sudo mkdir /opt/consul/config
sudo mkdir /opt/consul/data
sudo mv /home/ubuntu/serverconfig.hcl /opt/consul/config
sudo consul agent -config-file=/opt/consul/config/serverconfig.hcl
EOF
    #Copy the config file to the server
    provisioner "file" {
      source      = "configs/serverconfig.hcl"
      destination = "/home/ubuntu/serverconfig.hcl"
      connection {
        type     = "ssh"
        user     = "ubuntu"
        private_key = var.private_key_path
        host = aws_instance.consul-server.public_ip
  }
    }

    #Must correspond to an existing EC2 key name 
    key_name = var.aws_ec2_key

    tags = {
        Name = "fargateConsulServer"
    }
}


resource "aws_instance" "test-server" {
    ami           = data.aws_ami.ubuntu.id
    instance_type = var.consul_instance_size

    network_interface {
        network_interface_id = aws_network_interface.test-server.id
        device_index         = 0
    }
    #User data field to grab Consul binary, create necessary directories and start agent with config
    #Relies on the file provisioner in the same resource
    user_data = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
EOF
    #Must correspond to an existing EC2 key name 
    key_name = var.aws_ec2_key

    tags = {
        Name = "dk-test-server"
    }
}


