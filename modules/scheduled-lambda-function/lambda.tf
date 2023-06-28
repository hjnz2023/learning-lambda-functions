locals {
  lambda_src_path = "${path.module}/src"
}

data "archive_file" "lambda_archive" {
  type        = "zip"
  source_file = "${local.lambda_src_path}/app.py"
  output_path = "${local.lambda_src_path}/lambda_function.zip"
}

resource "aws_lambda_function" "check_opensearch_snapshot" {
  filename         = data.archive_file.lambda_archive.output_path
  function_name    = "${local.namespace}-check-opensearch-snapshot"
  role             = aws_iam_role.for-lambda.arn
  handler          = "app.lambda_handler"
  source_code_hash = data.archive_file.lambda_archive.output_base64sha256
  layers           = [aws_lambda_layer_version.requests_aws4auth.arn]

  environment {
    variables = {
      "HOST"                = "https://${var.opensearch.endpoint}/"
      "SNAPSHOT_REPOSITORY" = "cs-automated"
    }
  }

  runtime = local.python_version
}
