locals {
  lambda_layer_path = "${path.module}/dependencies/layer"
}

data "archive_file" "lambda_layer" {
  type        = "zip"
  source_dir  = local.lambda_layer_path
  output_path = "${local.lambda_layer_path}.zip"
  excludes    = ["__pycache__", "tests"]
}

resource "aws_lambda_layer_version" "requests_aws4auth" {
  filename            = data.archive_file.lambda_layer.output_path
  layer_name          = "requests_aws4auth"
  source_code_hash    = data.archive_file.lambda_layer.output_base64sha256
  compatible_runtimes = ["python${var.python_version}"]
}
