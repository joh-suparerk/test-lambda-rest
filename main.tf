# Define Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.17.0"
    }
  }
}

# Define Current Region
provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_iam_role" "iam_lambda_rest_api" {
  name = "iam-lambda-rest-api"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda_rest_api" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  filename      = "lambda_rest_api.zip"
  function_name = "lambda-rest-api"
  role          = aws_iam_role.iam_lambda_rest_api.arn
  handler       = "python_rest_api.python_rest_api_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("lambda_rest_api.zip")

  runtime = "python3.9"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_lambda_permission" "allow_controlm" {
  statement_id  = "AllowExecutionFromControlM"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_rest_api.function_name
  principal     = "arn:aws:iam::733131556247:user/cdx-np-sys-aws-ctrlmlambda"
}

