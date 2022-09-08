terraform {
  required_version = ">= 0.12.6"
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the bucket to create"
}

variable "bucket_acl" {
  description = "ACL for S3 bucket: private, public-read, public-read-write, etc"
  default     = "private"
}

variable "kms_key_arn" {
  description = "ARN of the KMS key that encrypts the bucket"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_kms_key" "s3" {
  deletion_window_in_days = 7
  description             = "AWS KMS Customer-managed key"
  enable_key_rotation     = false
  is_enabled              = true
  key_usage               = "ENCRYPT_DECRYPT"

  tags = {
    name             = "Roger-Test-Bucket"
    Owner            = "rchao@hashicorp.com"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = var.bucket_acl

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = data.aws_kms_key.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    name             = "Roger-Test-Bucket"
    Owner            = "rchao@hashicorp.com"
  }
}

output "sse_algorithm" {
  value = aws_s3_bucket.bucket.server_side_encryption_configuration[0].rule[0].apply_server_side_encryption_by_default[0].sse_algorithm
}
