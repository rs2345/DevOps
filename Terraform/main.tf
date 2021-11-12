terraform {
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source  = "hashicorp/aws"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}

module "aws_vpc" {
  source = "./modules/vpc"

}

resource "aws_instance" "Pub_Instance" {
  ami             = "ami-0b0ea68c435eb488d"
  instance_type   = "t2.medium"
  key_name        = "Dev_Terra"
  subnet_id       = module.aws_vpc.PubSub_Id
  security_groups = ["${module.aws_vpc.Public_SG}"]

  connection {
    host        = aws_instance.Pub_Instance.public_ip
    type        = "ssh"
    port        = "22"
    user        = "ubuntu"
    private_key = file("./scripts/Dev_Terra.pem")
  }
  
  provisioner "local-exec" {
    command = "sed -i -e 's/ADMIN_IP/${aws_instance.Pub_Instance.public_ip}/g' ./scripts/admin_Pod.sh"
  }

  provisioner "file" {

    source      = "scripts/admin_Pod.sh"
    destination = "/home/ubuntu/admin_Pod.sh"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod 777 admin_Pod.sh",
      "./admin_Pod.sh",
    ]
  }
}

resource "aws_instance" "Priv_Instance" {
  ami             = "ami-01cc34ab2709337aa"
  instance_type   = "t2.micro"
  subnet_id       = module.aws_vpc.PrivSub_Id
  key_name        = "Dev_Terra"
  security_groups = ["${module.aws_vpc.Local_SG}"]
}

output "public_IP" {
  value = aws_instance.Pub_Instance.public_ip
}

output "private_IP" {
  value = ["${aws_instance.Pub_Instance.private_ip}", "${aws_instance.Priv_Instance.private_ip}"]
}