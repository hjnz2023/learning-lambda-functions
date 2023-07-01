resource "opensearch_index_template" "single_listings" {
  name = "single_listings"
  body = <<EOF
{
    "template": "single-listings*",
    "settings": {
        "number_of_shards": 2,
        "number_of_replicas": 1
    }
}
EOF
}
