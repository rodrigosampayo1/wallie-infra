
# Bastion Server
module "bastion" {

  source = "cloudposse/ec2-instance/aws"
  version                     = "v0.43.0"

  ami = local.ami
  ami_owner                   = "amazon"
  
  # TODO: Pass variable from TF_ENV_DESTROY_ALL to disable this termination step
  #   - Run twice to allow termination, then execute destroy terraform
  disable_api_termination     = true

  ssh_key_pair                = aws_key_pair.root.key_name
  #instance_type               = var.instance_type
  vpc_id                      = module.vpc.vpc_id
  #security_groups             = var.security_groups
  subnet                      = module.dynamic_subnets.public_subnet_ids[0]
  name                        = "octain-${var.env}-${var.type}-bastion-${resource.random_string.ec2_suffix.result}"
  namespace                   = var.namespace
  stage                       = var.env
  associate_public_ip_address = true
  delete_on_termination       = true
  instance_type               = "t2.micro"
  root_volume_size            = 10

  # Enable EGRESS, Inbound SSH, HTTP, HTTPS from all
  security_group_rules = [
    {
      type        = "egress"
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_blocks = var.egress_access
    },
    {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allow_ssh_sources
    }
  ]

}

resource "aws_cloudwatch_log_group" "central_logging_groups_baston" {
  
  name = "${module.bastion.public_dns}"
  retention_in_days = local.cloudwatch_log_retention_days

  tags = {
    Application = var.type
    Namespace   = var.namespace
    Stage       = var.env
    Monitor     = var.monitoring_email
    InstanceId  = module.bastion.id
  }

}

resource "null_resource" "bastion_provision" {

  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = "${module.bastion.id}"
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "bash ../../playbooks/provision-bastion.sh ${module.bastion.public_ip} ${var.private_ssh_key_fn} ${var.env}"
  }

}


resource "aws_cloudwatch_metric_alarm" "bastion-cpu-utilization" {
  
  alarm_name                = "high-cpu-alarm-octain-${var.env}-${var.type}-bastion-${resource.random_string.ec2_suffix.result}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors octain-${var.env}-${var.type}-bastion-${resource.random_string.ec2_suffix.result} cpu utilization"
  alarm_actions             = [ "${module.monitor_sns_topic.sns_topic.arn}" ]
  ok_actions                = [ "${module.monitor_sns_topic.sns_topic.arn}" ]

  dimensions = {
    InstanceId = "${module.bastion.id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "bastion-health-check" {

  count                     = var.type_count
  alarm_name                = "ec2-health-check-octain-${var.env}-${var.type}-bastion-${resource.random_string.ec2_suffix.result}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors ${var.env}-${var.type}-bastion-${resource.random_string.ec2_suffix.result} health status"
  alarm_actions             = [ "${module.monitor_sns_topic.sns_topic.arn}" ]
  ok_actions                = [ "${module.monitor_sns_topic.sns_topic.arn}" ]
  
  dimensions = {
    InstanceId = "${module.bastion.id}"
  }

}

