output "base_ami_id" {
  value       = data.aws_ami.amazon_linux_ecs.image_id
  description = "The base AMI used for the launch configurations"
}

output "iam_role" {
  value       = aws_iam_role.ecs
  description = "The IAM Role resource block for the IAM role"
}

output "iam_instance_profile" {
  value       = aws_iam_instance_profile.ecs
  description = "The IAM instance profile resource block for the instance profile attached to the instances"
}

output "security_group" {
  value       = aws_security_group.ecs
  description = "The security group resource block for the security group attached to the instances"
}

output "autoscaling_group_arn" {
  value       = module.ecs_asg.this_autoscaling_group_arn
  description = "The ARN of the auto-scaling group created"
}

output "autoscaling_group_id" {
  value       = module.ecs_asg.this_autoscaling_group_id
  description = "The ID of the auto-scaling group created"
}

output "launch_configuration_id" {
  value       = module.ecs_asg.this_launch_configuration_id
  description = "The ID of the launch configuration created"
}

output "launch_configuration_name" {
  value       = module.ecs_asg.this_launch_configuration_name
  description = "The name of the launch configuration created"
}


