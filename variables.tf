variable "ami" {
   type        = string
   description = "amazon linux 2023 us-east1"
   default     = "ami-06e46074ae430fba6"
}

variable "instance_type" {
   type        = string
   description = "Instance type"
   default     = "t2.micro"
}

variable "name_tag" {
   type        = string
   description = "Name of the EC2 instance"
   default     = "Basic MDDS EC2 instance"
}

variable "environment" {
  description = "Environment name for deployment"
  type        = string
  default     = "demo"
}

variable "aws_region" {
  description = "AWS region resources are deployed to"
  type        = string
  default     = "us-east-1"
}

# VPC Variables

variable "vpc_cidr" {
  description = "VPC cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "Subnet cidr block"
  type        = string
  default     = "10.0.0.0/24"
}

# IAM Role Variables

variable "ec2-trust-policy" {
  description = "sts assume role policy for EC2"
  type        = string
  default     = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }   
    ]
}
EOF  
}

variable "ec2-s3-permissions" {
  description = "IAM permissions for EC2 to S3"
  type        = string
  default     = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# S3 Variables

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "terraform1demo1s3bucket2023"
}

# EC2 Variables

variable "ssh_key" {
  description = "ssh key name"
  type        = string
  default     = "mdds-ssh-key"
}

variable "alternate_key_name" {
   description = "alternate ssh key name(aws internal)"
  type        = string
  default     = "mdds-key"
}

