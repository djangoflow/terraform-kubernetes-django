# TODO: support aws_s3_public
resource "aws_s3_bucket" "media-bucket" {
  bucket = var.aws_s3_name
}

resource "aws_s3_bucket_cors_configuration" "media-bucket" {
  bucket = aws_s3_bucket.media-bucket.bucket

  cors_rule {
    allowed_headers = []
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = ["Content-Type"]
  }
}

resource "aws_s3_bucket_website_configuration" "media-bucket" {
  bucket = aws_s3_bucket.media-bucket.bucket

  index_document {
    suffix = "index.html"
  }
}

