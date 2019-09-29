resource "aws_lambda_function" "file-duplicator-lambda" {
  filename      = "${local.function-zip-name}"
  function_name = "psp-file-duplicator-lambda"
  role          = "${aws_iam_role.s3-access-role.arn}"
  handler       = "FileDuplicatorLambda::FileDuplicatorLambda.Function::FunctionHandler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = "${filebase64sha256("${local.function-zip-name}")}"

  runtime = "dotnetcore2.1"

  environment {
    variables = {
      REGION_NAME             = "${data.aws_region.current.name}"
      DESTINATION_BUCKET_NAME = "${var.s3-destination-bucket-name}"
    }
  }
}

resource "aws_lambda_permission" "allow-source-bucket-event" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.file-duplicator-lambda.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.source-bucket.arn}"
}

locals {
  function-zip-name = "file-duplicator-lambda.zip"
}

data "aws_region" "current" {}
