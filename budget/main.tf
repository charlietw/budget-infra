resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

module "charlietw-certificates" {
  source      = "../modules/secure_bucket"
  bucket_name = "charlietw-certificates"
}


