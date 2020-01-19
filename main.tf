data "aws_region" "current" {}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_iam_role" "ecs" {
  name = "${var.prefix}ecs-iam-${var.ecs_cluster_name}"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs" {
  name = "${var.prefix}ecs-iam-${var.ecs_cluster_name}"
  role = aws_iam_role.ecs.name
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = aws_iam_role.ecs.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = aws_iam_role.ecs.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_ssm_role" {
  role       = aws_iam_role.ecs.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_security_group" "ecs" {
  name        = "${var.prefix}ecs-sg-${var.ecs_cluster_name}"
  description = "Allow inbound traffic from load balancers"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.load_balancer_sg_id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.load_balancer_sg_id]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // NFS
  egress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }
}

module "ecs_asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  name = "${var.prefix}ecs-${var.ecs_cluster_name}"

  # Launch configuration
  lc_name = "${var.prefix}ecs-lc-${var.ecs_cluster_name}"

  image_id             = data.aws_ami.amazon_linux_ecs.id
  instance_type        = var.instance_type
  security_groups      = merge(aws_security_group.ecs.id, var.additional_security_group_ids)
  iam_instance_profile = aws_iam_instance_profile.ecs.id
  user_data = templatefile("templates/ecs-node-userdata.tmpl", {
    CLUSTER_NAME : var.ecs_cluster_name
    FILESYSTEM_ID : var.efs_id
    REGION : data.aws_region.current.name
  })

  # Auto scaling group
  asg_name                  = "${var.prefix}ecs-asg-${var.ecs_cluster_name}"
  vpc_zone_identifier       = var.target_subnet_ids
  health_check_type         = "EC2"
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_min_size
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "ecs-cluster"
      value               = var.ecs_cluster_name
      propagate_at_launch = true
    }
  ]
}
