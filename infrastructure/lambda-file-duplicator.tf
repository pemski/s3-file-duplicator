resource "aws_lambda_function" "file-duplicator-lambda" {
  filename      = "${local.function-zip-name}"
  function_name = "${var.file-duplicator-lambda-name}"
  role          = "${aws_iam_role.lambda-s3-access-role.arn}"
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
  function_name = "${aws_lambda_function.file-duplicator-lambda.function_name}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.source-bucket.arn}"
}

resource "aws_iam_role" "lambda-s3-access-role" {
  name = "psp-file-duplicator-s3-access-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "log-group-for-lambda" {
  name              = "/aws/lambda/${var.file-duplicator-lambda-name}"
  retention_in_days = 7
}

resource "aws_iam_policy" "lambda-logging" {
  name        = "psp-file-duplicator-lambda-logging"
  path        = "/s3-file-duplicator/lambda/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach-source-s3-access-policy-to-lambda" {
  role       = "${aws_iam_role.lambda-s3-access-role.name}"
  policy_arn = "${aws_iam_policy.source-s3-access-policy.arn}"
}

resource "aws_iam_role_policy_attachment" "attach-destination-s3-access-policy-to-lambda" {
  role       = "${aws_iam_role.lambda-s3-access-role.name}"
  policy_arn = "${aws_iam_policy.destination-s3-access-policy.arn}"
}

resource "aws_iam_role_policy_attachment" "attach-logging-for-lambda" {
  role       = "${aws_iam_role.lambda-s3-access-role.name}"
  policy_arn = "${aws_iam_policy.lambda-logging.arn}"
}

locals {
  function-zip-name = "file-duplicator-lambda.zip"
}

data "aws_region" "current" {}
