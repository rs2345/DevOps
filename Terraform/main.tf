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

resource "aws_instance" "Master_Node" {
  ami             = "ami-0b0ea68c435eb488d"
  instance_type   = "t2.medium"
  key_name        = "Dev_Terra"
  subnet_id       = module.aws_vpc.PubSub1_ID
  security_groups = ["${module.aws_vpc.Public_SG}"]

}

resource "aws_instance" "Node_One" {
  ami             = "ami-0b0ea68c435eb488d"
  instance_type   = "t2.medium"
  subnet_id       = module.aws_vpc.PubSub2_ID
  key_name        = "Dev_Terra"
  security_groups = ["${module.aws_vpc.Public_SG}"]
}

resource "aws_instance" "Node_Two" {
  ami             = "ami-0b0ea68c435eb488d"
  instance_type   = "t2.medium"
  subnet_id       = module.aws_vpc.PubSub1_ID
  key_name        = "Dev_Terra"
  security_groups = ["${module.aws_vpc.Public_SG}"]

}

resource "null_resource" "Configure_Provisioners" {

  provisioner "local-exec" {
    command = <<-EOT
   
    cp scripts/Node_Templates/Admin_Node.sh scripts/Admin_Node.sh
    cp scripts/Node_Templates/Node_One.sh scripts/Node_One.sh
    cp scripts/Node_Templates/Node_Two.sh scripts/Node_Two.sh
    sed -i -e 's/ADMIN_IP/${aws_instance.Master_Node.public_ip}/g' ./scripts/Admin_Node.sh
    sed -i -e 's/NODE_ONE/${aws_instance.Node_One.public_ip}/g' ./scripts/Admin_Node.sh
    sed -i -e 's/NODE_TWO/${aws_instance.Node_Two.public_ip}/g' ./scripts/Admin_Node.sh
    sed -i -e 's/ADMIN_IP/${aws_instance.Master_Node.public_ip}/g' ./scripts/Node_One.sh
    sed -i -e 's/NODE_ONE/${aws_instance.Node_One.public_ip}/g' ./scripts/Node_One.sh
    sed -i -e 's/NODE_TWO/${aws_instance.Node_Two.public_ip}/g' ./scripts/Node_One.sh
    sed -i -e 's/ADMIN_IP/${aws_instance.Master_Node.public_ip}/g' ./scripts/Node_Two.sh
    sed -i -e 's/NODE_ONE/${aws_instance.Node_One.public_ip}/g' ./scripts/Node_Two.sh
    sed -i -e 's/NODE_TWO/${aws_instance.Node_Two.public_ip}/g' ./scripts/Node_Two.sh
  EOT

  }

  triggers = {
    order = aws_instance.Master_Node.public_ip
  }
}

resource "null_resource" "Master_Provisioner" {

  connection {
    host        = aws_instance.Master_Node.public_ip
    type        = "ssh"
    port        = "22"
    user        = "ubuntu"
    private_key = file("./scripts/Dev_Terra.pem")
  }
  provisioner "file" {

    source      = "scripts/Admin_Node.sh"
    destination = "/home/ubuntu/Admin_Node.sh"
  }

  provisioner "file" {

    source      = "scripts/Dev_Terra.pem"
    destination = "/home/ubuntu/Dev_Terra.pem"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod 777 Admin_Node.sh",
      "./Admin_Node.sh",
    ]
  }
  triggers = {
    order = null_resource.Configure_Provisioners.id
  }
}

resource "null_resource" "Node_One_Provisioner" {

  connection {
    host        = aws_instance.Node_One.public_ip
    type        = "ssh"
    port        = "22"
    user        = "ubuntu"
    private_key = file("./scripts/Dev_Terra.pem")
  }
  provisioner "file" {

    source      = "scripts/Node_One.sh"
    destination = "/home/ubuntu/Node_One.sh"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod 777 Node_One.sh",
      "./Node_One.sh",
    ]
  }
  triggers = {
    order = null_resource.Configure_Provisioners.id
  }

}

resource "null_resource" "Node_Two_Provisioner" {

  connection {
    host        = aws_instance.Node_Two.public_ip
    type        = "ssh"
    port        = "22"
    user        = "ubuntu"
    private_key = file("./scripts/Dev_Terra.pem")
  }
  provisioner "file" {

    source      = "scripts/Node_Two.sh"
    destination = "/home/ubuntu/Node_Two.sh"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod 777 Node_Two.sh",
      "./Node_Two.sh",
    ]
  }
  triggers = {
    order = null_resource.Configure_Provisioners.id
  }
}

# data "aws_route53_zone" "selected" {
#   name         = "rickyspringer.com"
#   private_zone = false
# }

resource "aws_route53_record" "www" {
  zone_id = "Z0084761L6YMKCYG41CL"
  name    = "www.jenkins.rickyspringer.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.Node_One.public_ip]
}

output "public_IP" {
  value = aws_instance.Master_Node.public_ip
}

output "private_IP_One" {
  value = ["${aws_instance.Node_One.private_ip}"]
}
output "private_IP_Two" {
  value = ["${aws_instance.Node_Two.private_ip}"]
}