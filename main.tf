terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

data "aws_key_pair" "existing" {
  key_name = "my-key-pair" 
}

# RSA key of size 4096 bits
#resource "tls_private_key" "rsa-4096" {
 # algorithm = "RSA"
  #rsa_bits  = 4096
#}

#create key pair
#resource "aws_key_pair" "key_pair" {
 # key_name   = var.key_name
  #public_key = tls_private_key.rsa-4096.public_key_openssh
#}

#save in local system
#resource "local_file" "private_key" {
 # content = tls_private_key.rsa-4096.public_key_openssh
  #filename = "${var.key_name}.pem"
#}

resource "local_file" "inventory" {
  content  = <<EOF
[web]
${aws_instance.example.public_ip} ansible_user=ubuntu
EOF
  filename = "${path.module}/inventory"
}

resource "null_resource" "provision" {
  provisioner "local-exec" {
    command = "ansible-playbook -i ${local_file.inventory.filename} ansible/playbook.yml"
  }

  depends_on = [aws_instance.example]
}

