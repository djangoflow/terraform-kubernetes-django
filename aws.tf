module "aws" {
  count         = var.aws_s3_name != null ? 1 : 0
  source        = "./modules/aws"
  aws_s3_name   = var.aws_s3_name
  aws_s3_public = var.public_storage
  aws_sa_name   = var.cloud_sa_name
}
