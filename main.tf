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