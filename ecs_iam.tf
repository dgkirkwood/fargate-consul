# Create an IAM role for the ECS EC2 instances.
data "aws_iam_policy_document" "ecs_role_definition" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      identifiers = [
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
      type = "Service"
    }
  }
}
resource "aws_iam_role" "ecs_role" {
  name_prefix        = "${var.cluster_name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_role_definition.json

  # Allows the role to be deleted and reacreated (when needed)
  force_detach_policies = true
}

# Create an IAM policy which allows the ECS agent to function inside EC2 instances
data "aws_iam_policy_document" "ecs_instance_role_policy_doc" {
  statement {
    actions = [
      # Requirements for ECS agent
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "ecs:StartTask",
      "ec2:DescribeInstances",

      # Requirements for EC2 instances within the cluster to be able to pull ECR Docker images
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",

      # Allow EC2 instances to write to CloudWatch logs
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*",
    ]
  }
}
resource "aws_iam_policy" "ecs_role_permissions" {
  name_prefix = "${var.cluster_name}-ecs-policy"
  description = "These policies allow the ECS instances to do certain actions like pull images from ECR"
  path        = "/"
  policy      = data.aws_iam_policy_document.ecs_instance_role_policy_doc.json
}

# Attach the ECS agent IAM policy to the service Role that is assinged to each EC2 instance
resource "aws_iam_policy_attachment" "ecs_instance_role_policy_attachment" {
  name = "${var.cluster_name}-iam-policy-attachment"
  roles = [
    aws_iam_role.ecs_role.name
  ]
  policy_arn = aws_iam_policy.ecs_role_permissions.arn
}

# Allow EC2 instances to be launched using this role,
# allowing them to automatically gain the permissions that were present in this role
# (attached through policies to the Role)
resource "aws_iam_instance_profile" "ec2_iam_instance_profile" {
  name_prefix = var.cluster_name
  role        = aws_iam_role.ecs_role.name
}

# ECS task execution role data
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid = ""
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "fargate-demo-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}



# ECS task execution role
resource "aws_iam_role" "ecs_task_role_cloudjoin" {
  name               = "fargate-demo-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_role_definition.json
}


resource "aws_iam_policy_attachment" "ecs_task_role_cloudjoin" {
  name = "dk-ecs-policy-attach"
  roles = [
    aws_iam_role.ecs_task_role_cloudjoin.name
  ]
  policy_arn = aws_iam_policy.ecs_role_permissions.arn
}
