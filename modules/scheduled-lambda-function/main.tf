resource "random_string" "rand" {
  length  = 24
  special = false
  upper   = false
}

locals {
  namespace = substr(join("-", [var.namespace, random_string.rand.result]), 0, 24)
  opensearch = {
    snapshot_poll_interval = "240 minutes"
  }
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



# resource "random_uuid" "lambda_src_hash" {
#   keepers = {
#     for filename in setunion(
#       fileset(local.lambda_src_path, "hello_world.py"),
#       fileset(local.lambda_src_path, "requirements.txt")
#     ) :
#     filename => filemd5("${local.lambda_src_path}/${filename}")
#   }
# }

# resource "aws_lambda_function" "hello_world" {
#   function_name    = "${local.namespace}-hello-world"
#   filename         = data.archive_file.lambda_source_package.output_path
#   source_code_hash = data.archive_file.lambda_source_package.output_base64sha256
#   role             = aws_iam_role.for-lambda.arn
#   handler          = "hello_world.lambda_handler"

#   environment {
#     variables = {
#       "HOST" = "https://${var.opensearch.endpoint}/"
#     }
#   }

#   runtime = "python3.10"
# }



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
