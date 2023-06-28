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
