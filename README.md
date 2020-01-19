# Terraform Module for AWS EC2 Instances for ECS

This Terraform module manages EC2 Instances and corresponding auto-scaling group for an existing ECS Cluster. 

Includes least-privilege security group, dedicated IAM role, and SSM Session Manager. Optionally mounts a shared file system.

**Requires**:
- AWS Provider
- Terraform 0.12

## Resources Created

- IAM Role
- IAM Instance Profile
- Security Group for EC2 Instances
  - Allows 80/443 inbound from `load_balancer_sg_id`
  - Allows 80/443 outbound to `0.0.0.0/0`
  - Allows 2049 (NFS) outbound to the VPC's CIDR block
- EC2 Launch Configuration
- EC2 Autoscaling Group (Does NOT create scaling policies) 

## Variables

 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| additional\_security\_group\_ids | Any additional security group IDs to associate to the instances | `list` | `[]` | no |
| asg\_max\_size | The maximum size for the autoscaling group | `string` | `"10"` | no |
| asg\_min\_size | The minimum size for the autoscaling group | `string` | `"3"` | no |
| ecs\_cluster\_name | ECS Cluster Name | `string` | n/a | yes |
| efs\_id | Automatically mounts EFS to /mnt/efs if an EFS ID is provided | `string` | `""` | no |
| instance\_type | Instance Type for Autoscaling Group | `string` | `"m5.large"` | no |
| load\_balancer\_sg\_id | The security group ID associated to the load balancer (whitelisted for inbound traffic to ECS) | `string` | n/a | yes |
| prefix | Name Prefix | `string` | `""` | no |
| target\_subnet\_ids | The subnet IDs to launch instances into | `list` | n/a | yes |
| vpc\_id | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| autoscaling\_group\_arn | The ARN of the auto-scaling group created |
| autoscaling\_group\_id | The ID of the auto-scaling group created |
| base\_ami\_id | The base AMI used for the launch configurations |
| iam\_instance\_profile | The IAM instance profile resource block for the instance profile attached to the instances |
| iam\_role | The IAM Role resource block for the IAM role |
| launch\_configuration\_id | The ID of the launch configuration created |
| launch\_configuration\_name | The name of the launch configuration created |
| security\_group | The security group resource block for the security group attached to the instances |
