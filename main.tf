locals {
  namespace = "experiment-01"
}

module "opensearch_cluster" {
  source      = "./modules/opensearch"
  domain_name = local.namespace
}

module "check_opensearch_snapshot_lambda" {
  source             = "./modules/scheduled-lambda-function"
  namespace          = local.namespace
  opensearch         = module.opensearch_cluster.opensearch
  always_pip_install = var.is_remote
  disabled_tigger    = true
}
