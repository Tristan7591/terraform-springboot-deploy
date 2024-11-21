output "ec2_instance_id" {
  description = "ID de l'instance EC2"
  value       = module.ec2_instance.id
}

output "ec2_instance_public_ip" {
  description = "IP publique de l'instance EC2"
  value       = module.ec2_instance.public_ip
}

output "s3_bucket_id" {
  description = "ID du bucket S3"
  value       = module.s3_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "ARN du bucket S3"
  value       = module.s3_bucket.s3_bucket_arn
}

output "rds_endpoint" {
  description = "Endpoint RDS"
  value       = module.rds.db_instance_endpoint
}

output "rds_port" {
  description = "Port RDS"
  value       = module.rds.db_instance_port
}