############################################
# IAM Role & Policy for EC2 Instances
############################################

# Iam for EC2
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-role"
  }
}

# Policy to grant Secrets Manager and RDS Describe Access
resource "aws_iam_policy" "ec2_secrets_policy" {
  name        = "${var.project_name}-ec2-secrets-policy"
  description = "Allow EC2 to access Secrets Manager and describe RDS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSecretsManagerAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowRDSDescribe"
        Effect = "Allow"
        Action = [
          "rds:DescibeDBInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attaching the policy to a specific role
resource "aws_iam_role_policy_attachment" "ec2_role_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_secrets_policy.arn
}

# Instance profile 
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}