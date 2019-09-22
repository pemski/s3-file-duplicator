resource "aws_s3_bucket" "target-bucket" {
    bucket = "psp-file-duplicator-target"
    acl = "private"
    force_destroy = "true"

    tags {
        Description = "The target bucket for the copy-file lambda"
    }
}