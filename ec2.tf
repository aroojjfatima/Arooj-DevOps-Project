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
    #cd ./ansible
    command = "touch inventory.ini"
  }
}

data "template_file" "inventory" {
  template = <<-EOT
    [example]
    ${aws_instance.example.public_ip} ansible_user=ubuntu ansible_private_key_file=~/.ssh/id_rsa
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
  depends_on = [local_file.inventory]
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory.ini ./ansible/playbook.yml"
    working_dir = path.module
  }
}

#resource "null_resource" "ansible_provision" {
  #provisioner "local-exec" {
   # command = <<EOT
    #  echo "[example]" > ./ansible/inventory.ini
     # echo "${aws_instance.example.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa" >> ./ansible/inventory.ini
      #cat ./ansible/inventory.ini
      #cd ./ansible
      #ansible-playbook -i inventory.ini playbook.yml -vvv
    #EOT
  #}

  #depends_on = [aws_instance.example]
#}




