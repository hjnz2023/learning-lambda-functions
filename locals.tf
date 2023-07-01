locals {
  opensearch_endpoint_url = "https://${module.opensearch_cluster.opensearch.endpoint}"
}
