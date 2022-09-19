resource "aws_s3_bucket" "scripts" {
  bucket = "charlietw-scripts"
}

resource "aws_s3_bucket_public_access_block" "scripts_public_access_block" {
  bucket                  = aws_s3_bucket.scripts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "setup" {
  key    = "setup.sh"
  bucket = aws_s3_bucket.scripts.id
  content = templatefile(
    "setup.sh.tpl",
    {
      networkName  = "budget-net"
      allowedEmail = var.allowed_email,
      bucketName   = aws_s3_bucket.charlietw-certificates.bucket,
      domainName   = var.domain_name
    }
  )
  server_side_encryption = "AES256"
}
