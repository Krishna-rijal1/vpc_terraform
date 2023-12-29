
//creating vpc
resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"
  tags = local.tags
}

//creating public subnet
resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.10.1.0/24"
    availability_zone = "us-east-1a"
    tags = merge(local.tags, { "Type" = "Public" })
  
}


//creating private subnet
resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.10.2.0/24"
    availability_zone = "us-east-1a"
    tags = merge(local.tags, { "Type" = "private" })
  
}


//creating internet gateway
resource "aws_internet_gateway" "my_internet_gwy" {
    vpc_id = aws_vpc.my_vpc.id
      tags = local.tags
}


//creating route table for public
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_internet_gwy.id
  }
  tags = local.tags
}
//subnet association
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id

}

//creating route table for private
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_internet_gwy.id
  }
  tags = local.tags
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id

}

//creating security groups
resource "aws_security_group" "my_security_group" {
  vpc_id      = aws_vpc.my_vpc.id
//Inbound rule for SSH (for instance in the private subnet)
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  //Inbound rule for HTTP traffic (for instance in the public subnet)
  ingress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 80
        to_port = 80
        protocol = "tcp"
    }
    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 443
        to_port = 443
        protocol = "tcp"
    }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
tags = local.tags
  }

//creating nat gateway
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_elasticip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = local.tags

}

//allocate elastic ip for nat gateway
resource "aws_eip" "my_elasticip" {
  tags = local.tags
}


//creating ec2 instance
resource "aws_instance" "krishna_private" {
  
  ami = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private_subnet.id
  key_name = "krishna"
  security_groups = [aws_security_group.my_security_group.id]
  tags = local.tags
  volume_tags = local.tags

}

//ec2 instance for public
resource "aws_instance" "krishna_public" {
  
  ami = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet.id
  key_name = "krishna"
  security_groups = [aws_security_group.my_security_group.id]
  tags = local.tags
  volume_tags = local.tags

  
}