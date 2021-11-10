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

}

resource "aws_instance" "Priv_Instance" {
    ami = "ami-01cc34ab2709337aa"
    instance_type = "t2.micro"
    subnet_id = module.aws_vpc.PrivSub_Id
    key_name = "Dev_Terra"
    security_groups = ["${module.aws_vpc.Local_SG}"]

  

}