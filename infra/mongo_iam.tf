resource "aws_iam_role" "mongo_ec2_role" {
  name = "wiz-mongo-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "mongo_ec2_overpermissive" {
  name = "wiz-mongo-ec2-overpermissive"
  role = aws_iam_role.mongo_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowEC2FullAccess"
        Effect   = "Allow"
        Action   = ["ec2:*"]
        Resource = "*"
      },
      {
        Sid      = "AllowS3FullAccess"
        Effect   = "Allow"
        Action   = ["s3:*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "mongo_ec2_instance_profile" {
  name = "wiz-mongo-ec2-instance-profile"
  role = aws_iam_role.mongo_ec2_role.name
}
