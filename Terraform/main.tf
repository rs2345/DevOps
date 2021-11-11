terraform {
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source = "hashicorp/aws"
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
    ami = "ami-01cc34ab2709337aa"
    instance_type = "t2.micro"
    key_name = "Dev_Terra"
    subnet_id = module.aws_vpc.PubSub_Id
    security_groups = ["${module.aws_vpc.Public_SG}"]

    provisioner "local-exec" {
      command = "sed -i -e 's/ADMIN_IP/${aws_instance.Pub_Instance.public_ip}/g' ./scripts/admin_Pod.sh"
    }

    provisioner "file" {

      connection {
        host = "${aws_instance.Pub_Instance.public_ip}"
        type = "ssh"
        port = "22"
        user = "ec2-user"
        private_key = file("./scripts/Dev_Terra.pem")
      }

        source = "./scripts/admin_Pod.sh"
        destination = "./home/ec2-user"      
    }

    provisioner "remote-exec" {
     
      connection {  
        host = "${aws_instance.Pub_Instance.public_ip}"
        type = "ssh"
        port = "22"
        user = "ec2-user"
        private_key = file("./scripts/Dev_Terra.pem")

        inline = [
          "chmod 777 admin_Pod.sh", "./home/ec2-user/admin_Pod.sh"
      ]
     }

}
}

resource "aws_instance" "Priv_Instance" {
    ami = "ami-01cc34ab2709337aa"
    instance_type = "t2.micro"
    subnet_id = module.aws_vpc.PrivSub_Id
    key_name = "Dev_Terra"
    security_groups = ["${module.aws_vpc.Local_SG}"]
}

output "public_IP" {
  value = aws_instance.Pub_Instance.public_ip
}

output "private_IP" {
  value = ["${aws_instance.Pub_Instance.private_ip}", "${aws_instance.Priv_Instance.private_ip}"]
}