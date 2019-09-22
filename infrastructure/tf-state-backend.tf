terraform {
    backend "s3" {
        bucket = "psp-tf-state"
        key = "s3-file-copy-lambda.tfstate"
        region = "eu-west-1"
    }
}