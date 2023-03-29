
module "monitor_sns_topic" {

  source     = "cloudposse/sns-topic/aws"
  version    = "v0.20.2"

  name       = "sns-${var.namespace}-${var.env}-${resource.random_string.ec2_suffix.result}"
  namespace  = var.namespace
  stage      = var.env

  encryption_enabled = false
  
  subscribers = {
    email = {
        protocol = "email"
        endpoint = var.monitoring_email
        endpoint_auto_confirms = false
        raw_message_delivery = false
    }
  }

  sqs_dlq_enabled = false
}

module "sns_monitoring" {

  source  = "git::https://github.com/cloudposse/terraform-aws-sns-cloudwatch-sns-alarms.git?ref=0.2.2"
  
  enabled              = true

  sns_topic_name       = module.monitor_sns_topic.sns_topic.name
  sns_topic_alarms_arn = module.monitor_sns_topic.sns_topic.arn
}

