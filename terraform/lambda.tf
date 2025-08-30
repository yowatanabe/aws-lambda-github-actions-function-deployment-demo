# Create Lambda source zip for initial deployment
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = abspath("${path.module}/../src")
  output_path = abspath("${path.module}/../build/lambda.zip")
}

# Lambda execution role
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${var.function_name}-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

# Basic execution policy for logging
resource "aws_iam_role_policy_attachment" "lambda_basic_logging" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.handler"
  runtime       = var.lambda_runtime
  timeout       = 10

  # Initial deployment code (GitHub Actions will handle subsequent updates)
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # Ignore code changes as GitHub Actions will manage deployments
  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
    ]
  }
}

# CloudWatch log group
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 7
}
