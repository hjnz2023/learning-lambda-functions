provider "opensearch" {
  url                = local.opensearch_endpoint_url
  aws_profile        = "default"
  opensearch_version = "OpenSearch_2.5"
}
