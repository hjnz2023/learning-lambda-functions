variable "namespace" {
  type = string
}

variable "opensearch" {
  type = object({
    arn         = string
    domain_id   = string
    domain_name = string
    endpoint    = string
  })
}

variable "python_version" {
  type    = string
  default = "3.8"
}

variable "always_pip_install" {
  type    = bool
  default = false
}

variable "disabled_tigger" {
  type    = bool
  default = false
}
