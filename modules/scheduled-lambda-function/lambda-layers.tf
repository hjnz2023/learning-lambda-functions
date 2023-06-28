locals {
  lambda_layer_path      = "${path.module}/dependencies/layer"
  requirements_file_path = "${path.module}/dependencies/requirements.txt"
  python_version         = "python${var.python_version}"
  layer_runtime_path     = "${local.lambda_layer_path}/python/lib/${local.python_version}/site-packages"
}

resource "null_resource" "install_python_packages" {

  provisioner "local-exec" {
    command = "rm -rf ${local.lambda_layer_path} && mkdir -p ${local.layer_runtime_path}"
  }
  provisioner "local-exec" {
    command = "pip install -r ${local.requirements_file_path} -t ${local.layer_runtime_path}"
  }

  triggers = {
    always_run   = var.always_pip_install ? timestamp() : false
    requirements = filemd5(local.requirements_file_path)
  }
}

data "archive_file" "lambda_layer" {
  type        = "zip"
  source_dir  = local.lambda_layer_path
  output_path = "${local.lambda_layer_path}.zip"
  excludes    = ["**/__pycache__/**"]
  depends_on  = [null_resource.install_python_packages]
}

resource "aws_lambda_layer_version" "requests_aws4auth" {
  filename            = data.archive_file.lambda_layer.output_path
  layer_name          = "requests_aws4auth"
  source_code_hash    = data.archive_file.lambda_layer.output_base64sha256
  compatible_runtimes = [local.python_version]
}
