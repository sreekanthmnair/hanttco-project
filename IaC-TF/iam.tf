
# Create an IAM Role for EC2
resource "aws_iam_role" "ec2_s3_read_only_role" {
  name               = "ec2-s3-read-only-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

# IAM Role Trust Policy
data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
# Create an Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_s3_read_only_role.name
}

# Create S3 Bucket
resource "aws_s3_bucket" "S3_bucket" {
  
  bucket = "s3-${var.project_name}-971422713356"  # Ensure this bucket name is globally unique

}

# Define the Read-Only Policy Document
data "aws_iam_policy_document" "s3_read_only_policy" {
  statement {
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.S3_bucket.arn,
      "${aws_s3_bucket.S3_bucket.arn}/*"
    ]
    effect = "Allow"
  }
}

# Create a custom IAM policy for S3 read-only access
resource "aws_iam_policy" "s3_readonly_policy" {
  name        = "S3ReadOnlyPolicy"
  description = "Policy granting read-only access to a specific S3 bucket"
  policy = data.aws_iam_policy_document.s3_read_only_policy.json
}

# Attach the AmazonS3ReadOnlyAccess policy to the IAM Role
resource "aws_iam_policy_attachment" "ec2_s3_readonly_policy_attachment" {
  name       = "EC2-S3-ReadOnly-Policy-Attachment"
policy_arn = aws_iam_policy.s3_readonly_policy.arn
  roles      = [aws_iam_role.ec2_s3_read_only_role.name]
}

#Test