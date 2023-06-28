module "opensearch_cluster" {
  source      = "./modules/opensearch"
  domain_name = "experiment-01"
}

module "hello_world_lambda" {
  source     = "./modules/scheduled-lambda-function"
  namespace  = "experiment-01"
  opensearch = module.opensearch_cluster.opensearch

}
