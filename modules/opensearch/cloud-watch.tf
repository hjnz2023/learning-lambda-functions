resource "aws_cloudwatch_log_group" "log_group" {
  for_each = {
    "ES_APPLICATION_LOGS" = {
      name              = "/aws/opensearch-service/${var.domain_name}/application"
      retention_in_days = 7
    }
  }
  name              = each.value.name
  retention_in_days = each.value.retention_in_days
}

data "aws_iam_policy_document" "allow_es_amazonaws_com_logs" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      for k, v in aws_cloudwatch_log_group.log_group : "${v.arn}:*"
    ]
  }
}

resource "aws_cloudwatch_log_resource_policy" "default" {
  policy_name     = "allow-${var.domain_name}-es-amazonaws-com-logging"
  policy_document = data.aws_iam_policy_document.allow_es_amazonaws_com_logs.json
}
