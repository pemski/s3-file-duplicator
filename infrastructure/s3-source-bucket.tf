resource "aws_s3_bucket" "source-bucket" {
  bucket        = "psp-file-duplicator-source"
  acl           = "private"
  force_destroy = "true"

  tags = {
    Description = "The source bucket for the copy-file lambda"
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.source-bucket.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.file-duplicator-lambda.arn}"
    events              = ["s3:ObjectCreated:Put"]
  }
}
