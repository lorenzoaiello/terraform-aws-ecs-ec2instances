variable "ecs_cluster_name" {
  type        = "string"
  description = "ECS Cluster Name"
}

variable "vpc_id" {
  type        = "string"
  description = "VPC ID"
}

variable "load_balancer_sg_id" {
  type        = "string"
  description = "The security group ID associated to the load balancer (whitelisted for inbound traffic to ECS)"
}

variable "target_subnet_ids" {
  type        = "list"
  description = "The subnet IDs to launch instances into"
}

variable "asg_min_size" {
  type        = "string"
  default     = "3"
  description = "The minimum size for the autoscaling group"
}

variable "asg_max_size" {
  type        = "string"
  default     = "10"
  description = "The maximum size for the autoscaling group"
}

variable "prefix" {
  type        = "string"
  default     = ""
  description = "Name Prefix"
}

variable "instance_type" {
  type        = "string"
  default     = "m5.large"
  description = "Instance Type for Autoscaling Group"
}

variable "efs_id" {
  type        = "string"
  default     = ""
  description = "Automatically mounts EFS to /mnt/efs if an EFS ID is provided"
}

variable "additional_security_group_ids" {
  type        = "list"
  default     = []
  description = "Any additional security group IDs to associate to the instances"
}
