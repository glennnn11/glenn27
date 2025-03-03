provider "aws" {
  region = "us-east-1"
}


#  Step 1: Use Your Existing VPC

data "aws_vpc" "existing_vpc" {
  id = "vpc-0c055bf97439d5db1"
}


#  Step 2: Use Your Existing Subnet

data "aws_subnet" "existing_subnet" {
  id = "subnet-0dc81261e589b3d22"
}


# Step 3: Create a Security Group in the Existing VPC

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow SSH access"
  vpc_id      = data.aws_vpc.existing_vpc.id  # Use your existing VPC

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open SSH to all (restrict in production)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#  Step 4: Create an EC2 Instance (glenn2-7
resource "aws_instance" "glenn2_7" {
  ami             = "ami-05b10e08d247fb927"  # Amazon Linux 2 AMI (Change if needed)
  instance_type   = "t2.micro"
  subnet_id       = data.aws_subnet.existing_subnet.id  # Use your existing subnet
  security_groups = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "glenn2-7"
  }
}


#  Step 5: Create a 1GB EBS Volume in Same AZ
resource "aws_ebs_volume" "extra_volume" {
  availability_zone = aws_instance.glenn2_7.availability_zone
  size              = 1  # 1GB
  type              = "gp3"

  tags = {
    Name = "glenn2-7-ebs"
  }
}

#  Step 6: Attach the EBS Volume to EC2
resource "aws_volume_attachment" "ebs_attachment" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.extra_volume.id
  instance_id = aws_instance.glenn2_7.id
}


#  Step 7: Output Values
output "ec2_instance_id" {
  value = aws_instance.glenn2_7.id
}

output "ebs_volume_id" {
  value = aws_ebs_volume.extra_volume.id
}

output "availability_zone" {
  value = aws_instance.glenn2_7.availability_zone
}
