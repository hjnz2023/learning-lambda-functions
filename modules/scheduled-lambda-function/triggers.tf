resource "aws_cloudwatch_event_rule" "poll_opensearch_snapshot_status" {
  name                = "${local.namespace}-poll-opensearch-snapshot-status"
  description         = "Poll OpenSearch snapshot status every ${local.opensearch.snapshot_poll_interval}"
  schedule_expression = "rate(${local.opensearch.snapshot_poll_interval})"
  is_enabled          = !var.disabled_tigger
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.poll_opensearch_snapshot_status.name
  target_id = "${local.namespace}-target-to-layered-lambda"
  arn       = aws_lambda_function.check_opensearch_snapshot.arn
}

resource "aws_lambda_permission" "allow_event_bridge" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.check_opensearch_snapshot.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.poll_opensearch_snapshot_status.arn
}
