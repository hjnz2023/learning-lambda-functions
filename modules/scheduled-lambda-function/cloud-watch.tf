data "aws_iam_policy_document" "allow_create_logs" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

resource "aws_iam_policy" "logging" {
  name   = "logging"
  policy = data.aws_iam_policy_document.allow_create_logs.json
}

resource "aws_iam_role_policy_attachment" "logging" {
  role       = aws_iam_role.for-lambda.name
  policy_arn = aws_iam_policy.logging.arn
}
