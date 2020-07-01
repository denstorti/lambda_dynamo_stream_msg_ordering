variable "default_tags" {
  type = "map"
  default = {
    "env" = "test"
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  
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
  tags = "${merge(var.default_tags)}"
}

resource "aws_iam_policy" "lambda_dynamo" {
  name        = "lambda_ddb_stream"
  path        = "/"
  description = "IAM policy for DDB stream access from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:DescribeStream",
        "dynamodb:GetRecords",
        "dynamodb:GetShardIterator",
        "dynamodb:ListStreams"
      ],
      "Resource": "arn:aws:dynamodb:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for DDB stream access from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_dynamo" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_dynamo.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}

resource "aws_lambda_function" "example" {
  filename      = "lambda_function_payload.zip"
  function_name = "test_ddb_lambda"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "main.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = "${filebase64sha256("lambda_function_payload.zip")}"

  runtime = "python3.7"

  environment {
    variables = {
      foo = "bar"
    }
  }

  tags = "${merge(var.default_tags)}"

}

resource "aws_dynamodb_table" "example" {
  name           = "GameScores"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  hash_key       = "UserId"
  range_key      = "GameTitle"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "GameTitle"
    type = "S"
  }

  tags = "${merge(var.default_tags)}"
}

resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn  = "${aws_dynamodb_table.example.stream_arn}"
  function_name     = "${aws_lambda_function.example.arn}"
  starting_position = "LATEST"
  depends_on = [
    aws_dynamodb_table.example
  ]
}