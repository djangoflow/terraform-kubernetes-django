output "aws_iam_access_key" {
  value = aws_iam_access_key.sa
}

output "aws_s3_endpoint_url" {
  value = "https://s3.${aws_s3_bucket.media-bucket.region}.amazonaws.com"
}
