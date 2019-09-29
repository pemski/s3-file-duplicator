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
                "${aws_s3_bucket.source-bucket.arn}"
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
                "${aws_s3_bucket.destination-bucket.arn}"
            ]
        }
    ]
}
EOF
}
