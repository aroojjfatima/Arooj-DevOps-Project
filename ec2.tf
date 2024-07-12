resource "aws_instance" "example" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.key_pair.key_name

  tags = {
    Name = "ExampleInstance"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  provisioner "local-exec" {
    command = "touch inventory.ini"
  }
  provisioner "remote-exec" {
      inline = [
        "echo 'EC2 instance is ready.'"
      ]
      connection {
        type        = "ssh"
        host        = aws_instance.example.public_ip
        user        = "ubuntu"
        private_key = tls_private_key.rsa_4096.private_key_pem
      }
  }
}

data "template_file" "inventory" {
  template = <<-EOT
    [example]
    ${aws_instance.example.public_ip} ansible_user=ubuntu ansible_private_key_file=terraform-key.pem

    EOT
}

resource "local_file" "inventory" {
  depends_on = [aws_instance.example]
  filename = "inventory.ini"
  content = data.template_file.inventory.rendered
  provisioner "local-exec"{
    command = "chmod 400 ${local_file.inventory.filename}"
  }
}

resource "null_resource" "run_ansible" {
  depends_on = [ local_file.inventory ]  
  provisioner "local-exec" {
     command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini ./ansible/playbook.yml -- "  
  }
}


