resource "aws_iam_policy" "s3-access-policy" {
  name        = "psp-s3-file-duplicator-s3-access-policy"
  path        = "/s3-file-duplicator/"
  description = "A policy giving access to source and target S3 buckets for file duplicator"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Resource": [
                "${aws_s3_bucket.source-bucket.arn}",
                "${aws_s3_bucket.destination-bucket.arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "s3-access-role" {
  name = "psp-file-duplicator-s3-access-role"

  assume_role_policy = {}
}

resource "aws_iam_role_policy_attachment" "attach-s3-access-policy-to-role" {
  role       = "${aws_iam_role.s3-access-role.name}"
  policy_arn = "${aws_iam_policy.s3-access-policy.arn}"
}
