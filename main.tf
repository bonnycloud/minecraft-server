provider "aws" {
  region = "eu-west-3"
}

# ------------------------------------------------------------------------------
# Network
# ------------------------------------------------------------------------------
resource "aws_vpc" "minecraft" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.application_name}-vpc"
  }
}

resource "aws_subnet" "minecraft" {
  vpc_id            = aws_vpc.minecraft.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "${var.application_name}-subnet"
  }
}

resource "aws_network_interface" "minecraft" {
  subnet_id   = aws_subnet.minecraft.id
  private_ips = ["10.0.10.100"]
  tags = {
    Name = "${var.application_name}-eni"
  }
}

# ------------------------------------------------------------------------------
# Security Groups
# ------------------------------------------------------------------------------
resource "aws_security_group" "ec2" {
  name        = "${var.application_name}-efs-sg"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "ingress_ssh" {
  security_group_id = aws_security_group.ec2.id
  description       = "Allow SSH connections to the EC2"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_minecraft" {
  security_group_id = aws_security_group.ec2.id
  description       = "Allow connections to the Minecraft server"
  type              = "ingress"
  from_port         = 25565
  to_port           = 25565
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress_all" {
  security_group_id = aws_security_group.ec2.id
  description       = "Allow outbound traffic to AWS services"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ------------------------------------------------------------------------------
# EBS
# ------------------------------------------------------------------------------
resource "aws_ebs_volume" "minecraft" {
  availability_zone = "${var.region}a"
  size = 5
}

resource "aws_volume_attachment" "minecraft" {
  device_name = "/srv/minecraft/world"
  volume_id   = aws_ebs_volume.minecraft.id
  instance_id = aws_instance.minecraft.id
}

# ------------------------------------------------------------------------------
# EC2
# ------------------------------------------------------------------------------
resource "aws_instance" "minecraft" {
  availability_zone = "${var.region}a"
  ami               = "ami-0111c5910da90c2a7"
  instance_type     = "t2.small"
  network_interface {
    network_interface_id = aws_network_interface.minecraft.id
    device_index         = 0
  }
  security_groups   = [aws_security_group.ec2.name]
  key_name          = "zoomkey"
  tags = {
    Name     = var.application_name
    Stage    = "production"
    Location = "Europe/Paris"
  }

}
