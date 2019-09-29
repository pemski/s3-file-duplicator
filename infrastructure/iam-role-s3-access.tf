resource "aws_iam_role" "s3-access-role" {
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

resource "aws_iam_policy" "source-s3-access-policy" {
  name        = "psp-file-duplicator-source-s3-access-policy"
  path        = "/s3-file-duplicator/"
  description = "A policy giving access to source S3 bucket for the file duplicator"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "${aws_s3_bucket.source-bucket.arn}",
            ]
        }
    ]
}
EOF
}

resource "aws_iam_policy" "destination-s3-access-policy" {
  name        = "psp-file-duplicator-destination-s3-access-policy"
  path        = "/s3-file-duplicator/"
  description = "A policy giving access to destination S3 bucket for the file duplicator"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "${aws_s3_bucket.destination-bucket.arn}",
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach-source-s3-access-policy-to-role" {
  role       = "${aws_iam_role.s3-access-role.name}"
  policy_arn = "${aws_iam_policy.source-s3-access-policy.arn}"
}

resource "aws_iam_role_policy_attachment" "attach-destination-s3-access-policy-to-role" {
  role       = "${aws_iam_role.s3-access-role.name}"
  policy_arn = "${aws_iam_policy.destination-s3-access-policy.arn}"
}