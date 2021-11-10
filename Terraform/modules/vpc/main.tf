resource "aws_vpc" "App_Dev" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"

    tags = {
        Name = "Developer VPC"
    }
}

resource "aws_subnet" "PubSub1" {
    vpc_id = aws_vpc.App_Dev.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "Public Subnet 1"
    }
}

resource "aws_subnet" "PubSub2" {
    vpc_id = aws_vpc.App_Dev.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"

    tags = {
        Name = "Public Subnet 2"
    }
}

resource "aws_subnet" "PrivSub1" {
    vpc_id = aws_vpc.App_Dev.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1c"

    tags = {
        Name = "Private Subnet 1"
    }
}

resource "aws_subnet" "PrivSub2" {
    vpc_id = aws_vpc.App_Dev.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1d"

    tags = {
        Name = "Private Subnet 1"
    }
}