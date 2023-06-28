resource "random_string" "rand" {
  length  = 24
  special = false
  upper   = false
}

locals {
  namespace       = substr(join("-", [var.namespace, random_string.rand.result]), 0, 24)
  lambda_src_path = "${path.module}/src"
}

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

resource "aws_iam_role" "for-lambda" {
  name               = "${local.namespace}-for-lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "null_resource" "install_python_packages" {
  provisioner "local-exec" {
    command = "pip3 install -r ${path.module}/src/requirements.txt -t ${path.module}/src"
  }

  triggers = {
    dependencies = filemd5("${path.module}/src/requirements.txt")
    source       = filemd5("${path.module}/src/hello_world.py")
  }
}

resource "random_uuid" "lambda_src_hash" {
  keepers = {
    for filename in setunion(
      fileset(local.lambda_src_path, "hello_world.py"),
      fileset(local.lambda_src_path, "requirements.txt")
    ) :
    filename => filemd5("${local.lambda_src_path}/${filename}")
  }
}

data "archive_file" "lambda_source_package" {
  depends_on       = [null_resource.install_python_packages]
  type             = "zip"
  source_dir       = "${path.module}/src"
  output_file_mode = "0666"
  output_path      = "${path.module}/bin/${random_uuid.lambda_src_hash.result}.zip"

  excludes = ["__pycache__", "tests"]
}

resource "aws_lambda_function" "hello_world" {
  function_name    = "${local.namespace}-hello-world"
  filename         = data.archive_file.lambda_source_package.output_path
  source_code_hash = data.archive_file.lambda_source_package.output_base64sha256
  role             = aws_iam_role.for-lambda.arn
  handler          = "hello_world.lambda_handler"

  environment {
    variables = {
      "HOST" = "https://${var.opensearch.endpoint}/"
    }
  }

  runtime = "python3.10"
}

resource "aws_cloudwatch_event_rule" "every_5_minutes" {
  name                = "${local.namespace}-every-5-minute"
  description         = "Trigger lambda every 5 minutes"
  schedule_expression = "rate(5 minutes)"
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_5_minutes.name
  target_id = "${local.namespace}-target-to-hello-world-lambda"
  arn       = aws_lambda_function.hello_world.arn
}

resource "aws_lambda_permission" "allow_event_bridge" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_5_minutes.arn
}

data "aws_iam_policy_document" "allow_lambda_to_access_opensearch" {
  statement {
    effect = "Allow"

    actions = [
      "es:ESHttp*",
    ]

    resources = [
      "${var.opensearch.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "access_opensearch" {
  name   = "access-opensearch-${var.opensearch.domain_name}"
  policy = data.aws_iam_policy_document.allow_lambda_to_access_opensearch.json
}

resource "aws_iam_role_policy_attachment" "terraform_state_access_role_full_access" {
  role       = aws_iam_role.for-lambda.name
  policy_arn = aws_iam_policy.access_opensearch.arn
}
