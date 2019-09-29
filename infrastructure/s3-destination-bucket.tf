resource "aws_s3_bucket" "destination-bucket" {
  bucket        = "${var.s3-destination-bucket-name}"
  acl           = "private"
  force_destroy = "true"

  tags = {
    Description = "The destination bucket for the copy-file lambda"
  }
}
