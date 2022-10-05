resource "aws_iam_user" "sa" {
  name = var.aws_sa_name
}

resource "aws_iam_access_key" "sa" {
  user = aws_iam_user.sa.name
}

data "aws_iam_policy_document" "default" {
  statement {
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.media-bucket.arn, "${aws_s3_bucket.media-bucket.arn}/*"]
    effect    = "Allow"
  }
}

resource "aws_iam_user_policy" "storage" {
  name   = aws_iam_user.sa.name
  user   = aws_iam_user.sa.name
  policy = join("", data.aws_iam_policy_document.default.*.json)
}
