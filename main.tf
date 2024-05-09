# Create an S3 bucket
resource "aws_s3_bucket" "files_bucket" {
  bucket = "test-bucket"
}