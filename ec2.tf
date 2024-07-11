resource "aws_instance" "example" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = data.aws_key_pair.existing.key_name

  tags = {
    Name = "ExampleInstance"
  }
}

resource "null_resource" "ansible_provision" {
  #provisioner "local-exec" {
  #  command = "cd ./ansible && ansible-playbook -i inventory.ini playbook.yml"
  #}

  #depends_on = [aws_instance.example]
  provisioner "local-exec" {
    command = <<EOT
      cd ./ansible
      echo "[example]" > inventory
      echo "${aws_instance.example.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/mykeypair" >> inventory
      ansible-playbook -i inventory playbook.yml -vvv
    EOT
  }
  depends_on = [aws_instance.example]
}



