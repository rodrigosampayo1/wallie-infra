terraform {
  required_version = ">= 0.12.2"

  backend "s3" {
    region         = "us-west-2"
    bucket         = "tf-kc-dev-web-il9xx0"
    key            = "terraform.dev.tfstate"
    dynamodb_table = "kc-dev-octain-state-lock"
    profile        = "terraform_iam_user_octain"
    role_arn       = ""
    encrypt        = "true"
  }
}
