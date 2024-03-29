variable "s3-source-bucket-name" {
  type    = "string"
  default = "psp-file-duplicator-source"
}

variable "s3-destination-bucket-name" {
  type    = "string"
  default = "psp-file-duplicator-destination"
}

variable "file-duplicator-lambda-name" {
  type    = "string"
  default = "psp-file-duplicator-lambda"
}
