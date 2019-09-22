resource "aws_s3_bucket" "source-bucket" {
    bucket = "psp-copy-lambda-source"
    acl = "private"
    force_destroy = "true"

    tags {
        Description = "The source bucket for the copy-file lambda"
    }
}