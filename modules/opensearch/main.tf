resource "aws_opensearch_domain" "default" {
  domain_name    = var.domain_name
  engine_version = "OpenSearch_2.5"

  cluster_config {
    instance_type = "t3.small.search"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }
}


