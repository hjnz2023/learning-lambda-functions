resource "aws_opensearch_domain" "default" {
  domain_name    = var.domain_name
  engine_version = "OpenSearch_2.5"

  cluster_config {
    instance_type  = "t3.small.search"
    instance_count = 2
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  dynamic "log_publishing_options" {
    for_each = aws_cloudwatch_log_group.log_group
    content {
      log_type                 = log_publishing_options.key
      cloudwatch_log_group_arn = log_publishing_options.value.arn
    }
  }
}


