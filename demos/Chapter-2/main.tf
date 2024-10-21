provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform-state" {
  bucket = "terraform-up-and-running-state-learn"

  # prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning so you can see the full revision history of your state files

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption by default

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform-state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Explicitly block all public access to the S3 bucket

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.terraform-state.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

# dynamodb for locking

resource "aws_dynamodb_table" "terraform_locks" {
  name = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LOCKID"

  attribute {
    name = "LOCKID"
    type = "S"
  }
}


# remote backend as S3 configuration

terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-learn"
    key = "global/s3/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt = true
  }
}


# output variables
output "s3_bucket_arn" {
  value = aws_s3_bucket.terraform-state.arn
  description = "The ARN of the S3 Bucket"
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
  description = "The name of the dynamoDB"
}

