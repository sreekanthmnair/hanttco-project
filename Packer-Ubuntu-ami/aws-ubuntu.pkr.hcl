


packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.3.2"
    }
  }
}

source "amazon-ebs" "ubuntu-ami" {
  ami_name      = "hantt_custom_image"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami    = "ami-0866a3c8686eaeeba"
  ssh_username  = "ubuntu"
}

build {
  name    = "hantt_co_build"
  sources = ["source.amazon-ebs.ubuntu-ami"]

  # Shell provisioner to update system and install Ansible, create local directory structure
  provisioner "shell" {
    inline = [
      "sudo apt update -y",
      "sudo apt upgrade -y",
      "sudo apt install ansible-core -y",
      "mkdir /tmp/ansible-playbook",
      "mkdir /tmp/ansible-playbook/templates"
    ]
  }

  # File provisioner to copy a Anisble playbook 
  provisioner "file" {
    source      = "./install-nginx-playbook.yml"   
    destination = "/tmp/ansible-playbook/"
  }

  # File provisioner to copy a Anisble templae file 
  provisioner "file" {
    source      = "./nginx_default_ssl.j2" 
    destination = "/tmp/ansible-playbook/templates/"
  }

  # Shell provisioner to execute the ansible playbook
  provisioner "shell" {
    inline = [
      "ansible-playbook /tmp/ansible-playbook/install-nginx-playbook.yml"
    ]
  }
}