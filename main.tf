########## CREATE S3 BUCKET ##########

resource "aws_s3_bucket" "files_bucket" {
  bucket = "test-bucket"

  tags = {
    Name        = "Test bucket"
    Environment = "Test"
  }
}

########## CREATE DYNAMODB TABLE ##########

resource "aws_dynamodb_table" "files_table" {
  name           = "Files"
  hash_key       = "FileName"
  read_capacity  = 5
  write_capacity = 5
  attribute {
    name = "FileName"
    type = "S"
  }
}

########## CREATE ROLE for STEP-FUNCTION ##########

resource "aws_iam_role" "step-function_role" {
  name = "step-function_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "states.amazonaws.com"
        }
      },
    ]
  })
}

########## CREATE STEP-FUNCTION ##########

