

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = module.mdds_vpc.vpc_id

  tags = {
    Name = "${var.environment}-internet-gateway"
  }
}

resource "aws_default_route_table" "default_route" {
  default_route_table_id = module.mdds_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

# Create S3 Bucket and IAM Policies

resource "aws_iam_role" "ec2_iam_role" {
  name               = "${var.environment}-ec2-iam-role"
  assume_role_policy = var.ec2-trust-policy
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.environment}-ec2-instance-profile"
  role = aws_iam_role.ec2_iam_role.id
}

resource "aws_iam_role_policy" "ec2_role_policy" {
  name   = "${var.environment}-ec2-role-policy"
  role   = aws_iam_role.ec2_iam_role.id
  policy = var.ec2-s3-permissions
}

resource "aws_s3_bucket" "s3" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name = "${var.environment}-s3-bucket"
  }
}

module "mdds_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "mdds-vpc"
  cidr = var.vpc_cidr

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true

  tags = {
    Name = "${var.environment}-mdds-vpc"
    Terraform = "true"
    Environment = "${var.environment}"
  }
}

# Create EC2 Security Group and Security Rules

resource "aws_security_group" "mdds_security_group" {
  name        = "${var.environment}-mdds-security-group"
  description = "Apply to Jenkins EC2 instance"
  vpc_id      = module.mdds_vpc.public_subnets[0]

  ingress {
    description = "Allow SSH from MY Public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow access to MDDS from My IP"
    from_port   = 9191
    to_port     = 9191
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow All Outbound"
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-mdds-security-group"
  }
}


# Create SSH Keys for EC2 Remote Access
resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.generated.private_key_pem
  filename        = "${var.ssh_key}.pem"
  file_permission = "0400"
}

resource "aws_key_pair" "generated" {
  key_name   = var.ssh_key
  public_key = tls_private_key.generated.public_key_openssh
}

# Create EC2 Instance
resource "aws_instance" "mdds_server" {
  ami                  = var.ami
  instance_type        = var.instance_type
  key_name             = aws_key_pair.generated.key_name
  subnet_id            = aws_subnet.subnet.id
  
  security_groups      = [aws_security_group.jenkins_security_group.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  #user_data            = var.ec2_user_data
  connection {
    user        = "ec2-user"
    private_key = tls_private_key.generated.private_key_pem
    host        = self.public_ip
  }

  tags = {
    Name = "${var.environment}-mdds-server"
  }
}
