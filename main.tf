terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
module "ec2_sg" {
  source = "./modules/sg"

  sg_name        = "ec2-instance-sg"
  sg_description = "Security group for EC2 instance"
  vpc_id         = data.aws_vpc.default.id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    
  ]

  additional_tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

module "rds_sg" {
  source = "./modules/sg"

  sg_name        = "rds-sg"
  sg_description = "Security group for RDS instance"
  vpc_id         = data.aws_vpc.default.id

  ingress_rules = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      self        = true
    }
  ]

  additional_tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "${var.project_name}-ec2-instance"

  instance_type          = var.instance_type
  ami                    = data.aws_ami.ubuntu_ami.id
  monitoring             = false                    #§§§§a changer avec cloudwatch
  vpc_security_group_ids = [module.ec2_sg.sg_id]
  subnet_id              = data.aws_subnets.default.ids[0]
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_instance_profile.name
  user_data = file("deploy.sh")
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "${var.project_name}-${var.environment}-bucket1"

  versioning = {
    enabled = true
  }
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "${var.project_name}-${var.environment}-db"

  engine               = "postgres"
  engine_version       = "14"
  family              = "postgres14"
  major_engine_version = "14"
  instance_class       = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage

  db_name  = var.db_name
  username = var.db_username
  port     = 5432

  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [module.rds_sg.sg_id]

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}