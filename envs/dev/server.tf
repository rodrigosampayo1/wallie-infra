
# Primary Web Server
module "instance"  {

  count                       = var.type_count

  source                      = "cloudposse/ec2-instance/aws"
  version                     = "v0.43.0"

  # Attach an IAM Policy
  instance_profile            = aws_iam_instance_profile.ec2_iam_profile.name

  ami                         = local.ami
  ami_owner                   = "amazon"
  disable_api_termination     = true
  
  ssh_key_pair                = aws_key_pair.root.key_name
  vpc_id                      = module.vpc.vpc_id
  
  # Default AMI: Amazon with Ubuntu 16.04 -- See #> aws ec2 describe-images --owners amazon
  # ami = ""

  subnet                      = module.dynamic_subnets.public_subnet_ids[count.index]
  name                        = "${var.namespace}-octain-${var.env}-${var.type}-${resource.random_string.ec2_suffix.result}-${count.index}"
  namespace                   = var.namespace
  stage                       = var.env
  associate_public_ip_address = var.app_public_ip
  delete_on_termination       = true
  instance_type               = var.type_size
  root_volume_size            = var.type_volume_size

  # Enable EGRESS, Inbound SSH, HTTP, HTTPS
  security_group_rules = local.instance_sg

}

resource "aws_cloudwatch_log_group" "central_logging_groups_server" {
  
  count = var.type_count

  name = "${module.instance[count.index].public_dns}"
  retention_in_days = local.cloudwatch_log_retention_days

  tags = {
    Application = var.type
    Namespace   = var.namespace
    Stage       = var.env
    Monitor     = var.monitoring_email
    InstanceId  = module.instance[count.index].id
  }

}

resource "null_resource" "server_provision" {

  count = var.type_count

  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = module.instance[count.index].id
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    # TOOD: Move Private IP to end of input variables to allow many to be provisioned.
    command = "bash ../../playbooks/provision-${var.type}server.sh ${module.bastion.public_ip} ${pathexpand(var.private_ssh_key_fn)} ${module.instance[count.index].private_ip} ${var.env}"
  }

}

resource "aws_cloudwatch_metric_alarm" "server-cpu-utilization" {

  count                       = var.type_count
  
  alarm_name                = "high-cpu-alarm-octain-${var.namespace}-octain-${var.env}-${var.type}-${resource.random_string.ec2_suffix.result}-${count.index}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ${var.namespace}-octain-${var.env}-${var.type}-${resource.random_string.ec2_suffix.result}-${count.index} cpu utilization"
  alarm_actions             = [ "${module.monitor_sns_topic.sns_topic.arn}" ]
  ok_actions                = [ "${module.monitor_sns_topic.sns_topic.arn}" ]

  dimensions = {
    InstanceId = "${module.instance[count.index].id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "server-health-check" {

  count                     = var.type_count
  alarm_name                = "ec2-health-check-octain-${var.namespace}-octain-${var.env}-${var.type}-${resource.random_string.ec2_suffix.result}-${count.index}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors ${var.namespace}-octain-${var.env}-${var.type}-${resource.random_string.ec2_suffix.result}-${count.index} health status"
  alarm_actions             = [ "${module.monitor_sns_topic.sns_topic.arn}" ]
  ok_actions                = [ "${module.monitor_sns_topic.sns_topic.arn}" ]

  dimensions = {
    InstanceId = "${module.instance[count.index].id}"
  }

}

# Process health checks
resource "aws_cloudwatch_metric_alarm" "process-health-check-nginx" {

  count                     = var.type_count
  alarm_name                = "process-health-check-octain-nginx-${var.namespace}-${var.env}-${var.type}-${resource.random_string.ec2_suffix.result}-${count.index}"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "httpd-processes"
  namespace                 = "nginx"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors ${var.namespace}-octain-${var.env}-${var.type}-${resource.random_string.ec2_suffix.result}-${count.index} nginx process health status"
  alarm_actions             = [ "${module.monitor_sns_topic.sns_topic.arn}" ]
  ok_actions                = [ "${module.monitor_sns_topic.sns_topic.arn}" ]

  dimensions = {
    InstanceId = "${module.instance[count.index].id}"
  }

}

resource "aws_cloudwatch_metric_alarm" "process-health-check-docker" {

  count                     = var.type_count
  alarm_name                = "process-health-check-octain-docker-${var.namespace}-${var.env}-${var.type}-${resource.random_string.ec2_suffix.result}-${count.index}"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "docker-processes"
  namespace                 = "docker"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors ${var.namespace}-octain-${var.env}-${var.type}-${resource.random_string.ec2_suffix.result}-${count.index} docker process health status"
  alarm_actions             = [ "${module.monitor_sns_topic.sns_topic.arn}" ]
  ok_actions                = [ "${module.monitor_sns_topic.sns_topic.arn}" ]

  dimensions = {
    InstanceId = "${module.instance[count.index].id}"
  }

}

# Contacting each domain for its active status
resource "aws_cloudwatch_metric_alarm" "site-health-check-app" {

  count                     = var.type_count
  alarm_name                = "site-health-check-octain-app-${var.namespace}-${var.env}-${var.type}-${resource.random_string.ec2_suffix.result}-${count.index}"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "httpd-total-conns"
  namespace                 = "${local.app_domain}:nginx"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "3"
  alarm_description         = "This metric monitors ${var.namespace}-octain-${var.env}-${var.type}-${resource.random_string.ec2_suffix.result}-${count.index} ${local.app_domain} total connections health status"
  alarm_actions             = [ "${module.monitor_sns_topic.sns_topic.arn}" ]
  ok_actions                = [ "${module.monitor_sns_topic.sns_topic.arn}" ]

  dimensions = {
    InstanceId = "${module.instance[count.index].id}"
  }

}

resource "aws_cloudwatch_metric_alarm" "site-health-check-api" {

  count                     = var.type_count
  alarm_name                = "site-health-check-octain-api-${var.namespace}-${var.env}-${var.type}-${resource.random_string.ec2_suffix.result}-${count.index}"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "httpd-total-conns"
  namespace                 = "${local.app_api_domain}:nginx"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "3"
  alarm_description         = "This metric monitors ${var.namespace}-octain-${var.env}-${var.type}-${resource.random_string.ec2_suffix.result}-${count.index} api total connections health status"
  alarm_actions             = [ "${module.monitor_sns_topic.sns_topic.arn}" ]
  ok_actions                = [ "${module.monitor_sns_topic.sns_topic.arn}" ]

  dimensions = {
    InstanceId = "${module.instance[count.index].id}"
  }

}

