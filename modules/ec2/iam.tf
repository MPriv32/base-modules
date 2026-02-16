###########################################
# IAM Role for EC2 (least privilege)
###########################################

resource "aws_iam_role" "ec2_role" {
  name = "${var.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = merge(var.tags, { ManagedBy = "Terraform" })
}

###########################################
# IAM Policy to allow pulling from ECR + SSM
###########################################

# Combine ECR + SSM into one inline policy if desired
resource "aws_iam_policy" "ec2_managed" {
  count       = var.attach_ecr_policy ? 1 : 0
  name        = "${var.name}-ec2-policy"
  description = "Allow EC2 to pull from ECR and register with SSM"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ECR pull permissions
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      # SSM permissions
      {
        Effect = "Allow"
        Action = [
          "ssm:UpdateInstanceInformation",
          "ssm:ListInstanceAssociations",
          "ssm:DescribeInstanceProperties",
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations",
          "ssm:GetParameters",
          "ssm:GetParameter"
        ]
        Resource = "*"
      },
      # EC2 Messages for SSM
      {
        Effect = "Allow"
        Action = [
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:SendReply"
        ]
        Resource = "*"
      },
      # CloudWatch for SSM metrics
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the combined policy to the EC2 role
resource "aws_iam_role_policy_attachment" "ec2_attach" {
  count      = var.attach_ecr_policy ? 1 : 0
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_managed[0].arn
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

###########################################
# Instance Profile for EC2
###########################################

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-profile"
  role = aws_iam_role.ec2_role.name
}