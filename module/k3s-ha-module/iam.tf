resource "aws_iam_policy" "valuead_access_policy" {
  name        = "valuead_access_policy"
  description = "Policy to allow SSM and S3 access for EC2 instance"

  policy = jsonencode({
    Version = "2012-10-17"
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "ssm:*",
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": "s3:*",
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role" "valuead_role" {
  name = "valuead_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "valuead_policy_attachment" {
  role       = aws_iam_role.valuead_role.name
  policy_arn = aws_iam_policy.valuead_access_policy.arn
}

resource "aws_iam_instance_profile" "valuead_instance_profile" {
  name = "valuead_instance_profile"
  role = aws_iam_role.valuead_role.name
}

