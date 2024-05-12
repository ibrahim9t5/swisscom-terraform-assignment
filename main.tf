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

########## DYNAMODB POLICY for STEP-FUNCTION ##########

resource "aws_iam_policy" "dynamodb_policy" {
  name        = "dynamodb-policy"
  description = "DynamoDB policy"


  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem"
      ],
      "Resource": [
        "arn:aws:dynamodb:*:*:table/Files"
      ]
    }
  ]
}
EOF
}

########## ATTACH POLICY to STEP-FUNCTION ROLE ##########

resource "aws_iam_policy_attachment" "policy-attach" {
  name       = "policy-attachment"
  policy_arn = aws_iam_policy.dynamodb_policy.arn
  roles      = [aws_iam_role.step-function_role.name]
}

########## CREATE STEP-FUNCTION with ROLE ##########

resource "aws_sfn_state_machine" "stepfunction_state_machine" {
  name     = "stepfuntion-state-machine"
  role_arn = aws_iam_role.step-function_role.arn

  definition = <<EOF
{
  "Comment": "A description of my stepfuntion state machine",
  "StartAt": "DynamoDB PutItem",
  "States": {
    "DynamoDB PutItem": {
      "Type": "Task",
      "Resource": "arn:aws:states:::dynamodb:putItem",
      "Parameters": {
        "TableName": "Files",
        "Item": {
          "FileName": {
            "S": "README.md"
          }
        }
      },
      "End": true
    }
  }
}
EOF
}

########## CREATE LAMBDA FUNCTION ##########

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "my_lambda" {
  filename      = "lambda.zip"
  function_name = "lambda-stepfunction"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda.lambda_handler"

  runtime = "python3.8"
}

########## CREATE LAMBDA POLICY to EXE STEP-FUNCTION ##########

resource "aws_iam_role_policy" "step_function_policy" {
  name   = "StepFunctionPolicy"
  role   = aws_iam_role.iam_for_lambda.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "states:StartExecution"
        ],
        Resource = "*"
      }
    ]
  })
}

########## CREATE S3 EVENT NOTIFICATION with POLICY TO INVOKE LAMBDA ##########

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.files_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.files_bucket.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.my_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

}