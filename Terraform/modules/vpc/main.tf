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
    map_public_ip_on_launch = "true"

    tags = {
        Name = "Public Subnet 1"
    }
}

resource "aws_subnet" "PubSub2" {
    vpc_id = aws_vpc.App_Dev.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = "true"

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

resource "aws_internet_gateway" "Dev_IGW" {
    vpc_id = aws_vpc.App_Dev.id

    tags = {
        Name = "Internet Gateway for Dev"
    }
}

resource "aws_route_table" "Dev_RT" {
    vpc_id = aws_vpc.App_Dev.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.Dev_IGW.id
    }

    tags = {
        Name = "Dev Route Table"
    }
}


resource "aws_route_table_association" "Pub1_Route" {
    
    subnet_id = aws_subnet.PubSub1.id
    route_table_id = aws_route_table.Dev_RT.id

}

resource "aws_route_table_association" "Pub2_Route" {
    
    subnet_id = aws_subnet.PubSub2.id
    route_table_id = aws_route_table.Dev_RT.id

}