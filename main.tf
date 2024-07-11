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

#resource "aws_instance" "example" {
 # ami           = "ami-04a81a99f5ec58529" # Update with your preferred AMI ID
  #instance_type = "t2.micro"

  #tags = {
   # Name = "Ansible-Configured-Instance"
  #}
#}

# data "aws_key_pair" "existing" {
#   key_name = "id_rsa" 
#   public_key = "~ssh/id_rsa.pub"
# }

resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "private_key" {
  content  = tls_private_key.rsa_4096.private_key_pem
  filename = "terraform-key.pem"
  provisioner "local-exec" {
    command = "chmod 400 terraform-key.pem"  # Secure the private key file
  }
}
resource "aws_key_pair" "key_pair" {
  key_name   = "terraform-key"
  public_key = tls_private_key.rsa_4096.public_key_openssh
}# resource "aws_key_pair" "Proj_Shahmir_deployer_key" {
#   key_name   = "id_rsa"
#   public_key = file(var.public_key_path)
# }

#save in local system
#resource "local_file" "private_key" {
 # content = tls_private_key.rsa-4096.public_key_openssh
  #filename = "${var.key_name}.pem"
#}

#resource "local_file" "inventory" {
 # content  = <<EOF
#[web]
#${aws_instance.example.public_ip} ansible_user=ubuntu
#EOF
 # filename = "${path.module}/inventory"
#}

#resource "null_resource" "provision" {
 # provisioner "local-exec" {
  #  command = "ansible-playbook -i ${local_file.inventory.filename} ansible/playbook.yml"
  #}

  #depends_on = [aws_instance.example]
#}

