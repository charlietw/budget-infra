resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_s3_bucket" "charlietw-certificates" {
  bucket = "charlietw-certificates"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.charlietw-certificates.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "certificates_public_access_block" {
  bucket                  = aws_s3_bucket.charlietw-certificates.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
