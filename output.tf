output "s3_bucket_name" {
  value = aws_s3_bucket.files_bucket.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.files_table.name
}

output "lambda_function_name" {
  value = aws_lambda_function.my_lambda.function_name
}

output "sfn_state_machine_name" {
  value = aws_sfn_state_machine.stepfunction_state_machine.name
}