
# We may not reuse bucket names
resource "random_string" "s3_bucket_suffix" {
  length           = 6
  special          = false
  lower            = true
  upper            = false
}

# You cannot create a new backend by simply defining this and then
# immediately proceeding to "terraform apply". The S3 backend must
# be bootstrapped according to the simple yet essential procedure in
# https://github.com/cloudposse/terraform-aws-tfstate-backend#usage
module "terraform_state_backend" {

  source = "cloudposse/tfstate-backend/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version     = "0.38.1"

  namespace = var.namespace
  stage     = var.env
  name      = var.type
  profile   = var.aws_profile_name

  attributes = ["state"]
  dynamodb_enabled = true
  terraform_state_file = "terraform.${var.env}.tfstate"

  s3_bucket_name = "tf-${var.namespace}-${var.env}-web-${resource.random_string.s3_bucket_suffix.result}"

  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "terraform.${var.namespace}-${var.env}-web.tf"
  s3_replication_enabled = false
  force_destroy                      = false

}

module "vpc" {

  source = "cloudposse/vpc/aws"
  version = "v1.1.0"

  namespace = var.namespace
  stage     = var.env
  name      = var.type

  # Development environment
  ipv4_primary_cidr_block           = var.internal_network_cidr

}

module "dynamic_subnets" {

  source = "cloudposse/dynamic-subnets/aws"
  version           = "v2.0.2"

  namespace          = var.namespace
  stage              = var.env
  name               = var.type
  availability_zones = var.availability_zones
  vpc_id             = module.vpc.vpc_id
  igw_id             = [module.vpc.igw_id]

  nat_gateway_enabled    = true
  public_subnets_enabled = true
  nat_instance_enabled = true
  private_subnets_enabled = false

}

# We may not reuse bucket names
resource "random_string" "ec2_suffix" {

  length           = 6
  special          = false
  lower            = true
  upper            = false

}

module "octain" {

  source                = "../../modules/octain-aws-services"

  account_id            = local.account_id
  namespace             = var.namespace
  env                   = var.env
  region                = var.region
  vpc_id                = module.vpc.vpc_id
  subnets               = module.dynamic_subnets.public_subnet_ids

  cors_domain           = local.app_domain
  sendgrid_api_key      = var.SENDGRID

  sns_topic_arn         = module.monitor_sns_topic.sns_topic_arn
  monitoring_email      = var.monitoring_email

  
  # [ ] Allow RDS Access from these subnets

  # All the variables are known in this module, so we create the object and pass one variable for all
  lambda_variables = {
      ECS_CLUSTER_NAME      = "${module.octain.ecs_cluster_name}"
      ECS_TASK_DEFINITION	  = "${module.octain.task_definition_name}"
      ECS_TASK_VPC_SUBNET_1	= module.dynamic_subnets.public_subnet_ids[0]
      ECS_TASK_VPC_SUBNET_2	= module.dynamic_subnets.public_subnet_ids[1]
      BUCKET_NAME           = "${module.octain.s3_bucket_name}"
      SQL_DATABASE          = "${module.octain.db_name}"
      SQL_HOST              = "${module.octain.db_host}"
      SQL_PASSWORD          = "${module.octain.db_password}"
      SQL_USER              = "${module.octain.db_username}"
    }

}
