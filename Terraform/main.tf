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