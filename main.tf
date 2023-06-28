module "opensearch_cluster" {
  source      = "./modules/opensearch"
  domain_name = "experiment-01"
}

module "check_opensearch_snapshot_lambda" {
  source     = "./modules/scheduled-lambda-function"
  namespace  = "experiment-01"
  opensearch = module.opensearch_cluster.opensearch
}
