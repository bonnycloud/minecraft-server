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

resource "aws_subnet" "public" {
    vpc_id            = aws_vpc.minecraft.id
    cidr_block        = "10.0.10.0/24"
    availability_zone = "${var.region}a"
    tags = {
        Name = "${var.application_name}-subnet"
    }
}

resource "aws_route_table" "minecraft" {
    vpc_id = aws_vpc.minecraft.id
    tags = {
        Name = "${var.application_name}-rt"
    }
}

resource "aws_route" "internet" {
    destination_cidr_block = "0.0.0.0/0"
    route_table_id         = aws_route_table.minecraft.id
    gateway_id             = aws_internet_gateway.minecraft.id
}

resource "aws_route_table_association" "minecraft" {
    subnet_id      = aws_subnet.public.id
    route_table_id = aws_route_table.minecraft.id
}

resource "aws_internet_gateway" "minecraft" {
    vpc_id = aws_vpc.minecraft.id
    tags = {
        Name = "${var.application_name}-igw"
    }
}

# ------------------------------------------------------------------------------
# Security Groups
# ------------------------------------------------------------------------------
resource "aws_security_group" "ec2" {
    name        = "${var.application_name}-sg"
    vpc_id      = aws_vpc.minecraft.id
}

resource "aws_security_group_rule" "ingress_ssh" {
    security_group_id = aws_security_group.ec2.id
    description       = "Allow SSH connections to the EC2"
    type              = "ingress"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["35.180.112.80/29"]
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
    device_name  = "/dev/xvdb"
    volume_id    = aws_ebs_volume.minecraft.id
    instance_id  = aws_instance.minecraft.id
    skip_destroy = true
}

# ------------------------------------------------------------------------------
# EC2
# ------------------------------------------------------------------------------
resource "aws_instance" "minecraft" {
    instance_type               = "t2.small"
    ami                         = "ami-0111c5910da90c2a7"
    vpc_security_group_ids      = [aws_security_group.ec2.id]
    subnet_id                   = aws_subnet.public.id
    associate_public_ip_address = true
    key_name                    = "${var.application_name}-key"
    user_data                   = "${file("start.sh")}"
    tags = {
        Name     = var.application_name
        Stage    = "production"
        Location = "Europe/Paris"
    }
}
