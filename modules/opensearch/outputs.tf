output "opensearch" {
  value = {
    arn         = aws_opensearch_domain.default.arn
    domain_name = aws_opensearch_domain.default.domain_name
  }
}
