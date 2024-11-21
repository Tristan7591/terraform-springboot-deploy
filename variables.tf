variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
}


variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t2.micro"
}

variable "db_instance_class" {
  description = "Type d'instance RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Taille allouée pour la base de données (GB)"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Taille maximum allouée pour la base de données (GB)"
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Nom de la base de données"
  type        = string
  default     = "mydb"
}

variable "db_username" {
  description = "Nom d'utilisateur de la base de données"
  type        = string
  default     = "dbadmin"
}

