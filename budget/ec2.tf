data "aws_ami" "amazon_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "terraform_ec2" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = "t2.nano"
  security_groups = [aws_security_group.allow_web.name]
  key_name                    = aws_key_pair.aws_key.key_name
}

# for declaring security group for ec2 instance resource 

resource "aws_security_group" "allow_web" {
  name        = "allow_web.traffic"
  description = "Allow TLS web traffic"

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" //any protocol
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

# at the moment this is required for the aws_key_pair resource
resource "tls_private_key" "key" {
 algorithm = "RSA"
 rsa_bits  = 4096
}
 
resource "aws_key_pair" "aws_key" {
 key_name   = "terraform-budget-key"
 public_key = tls_private_key.key.public_key_openssh
}