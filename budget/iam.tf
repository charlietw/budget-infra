# Going to AWS to get JSON back describing permissions
data "aws_iam_policy_document" "certificate-reader" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject"
      ]
    resources = [
      "${aws_s3_bucket.charlietw-certificates.arn}/*"
    ]
  }
}


# A collection of permissions, not assigned to any role yet
resource "aws_iam_policy" "certificate-reader" {
  name   = "certificate-reader"
  policy = data.aws_iam_policy_document.certificate-reader.json
}

# Says who can assume this role
data "aws_iam_policy_document" "allow-ec2-assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# A role with an 'assume_role_policy' i.e. who can assume this role?
# Still does nothing until we do a policy attachment
resource "aws_iam_role" "certificate-reader" {
  name               = "certificate-reader"
  assume_role_policy = data.aws_iam_policy_document.allow-ec2-assume.json
}

# Will now attach to the role
resource "aws_iam_role_policy_attachment" "reader-attach" {
  role       = aws_iam_role.certificate-reader.name
  policy_arn = aws_iam_policy.certificate-reader.arn
}

# And finally need this as a checkbox to say that EC2 instances can assume role
resource "aws_iam_instance_profile" "certificate-reader" {
  name = "certificate-reader"
  role = aws_iam_role.certificate-reader.name
}