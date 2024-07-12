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
}
