resource "aws_s3_bucket" "files_bucket" {
  bucket = "test-bucket"

  tags = {
    Name        = "Test bucket"
    Environment = "Test"
  }
}