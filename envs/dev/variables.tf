
variable "monitoring_email" {
  type = string
  description = "Email to contact if there is a change in application state"
}

variable "region" {
  description = "The AWS region in which global resources are set up."
  type        = string
  default     = "us-east-1"
}

variable "SENDGRID" {
  type = string
  description = "Pass in the Sendgrid API Secret stored in the CICD Variables"
}

variable "OPENAI_KEY" {
  type = string
  description = "Pass in the OPENAI KEY stored in the CICD Variables"
}

variable "OAUTH_CLIENT_SECRET" {
  type = string
  description = "Pass in the OAUTH Client Secret stored in the CICD Variables"
}

variable "allow_http_access" {
  type = list
  description = "Allow CIDR Source to Access HTTP/S Ports INGRESS"
}

variable "alb_enabled" {
  type = bool
  default = false
}

variable "enable_lb" {
  type = bool
  default = false
  description = "Enable Load Balancer aginst multiple targets"
}

variable "namespace" {
  type = string
  description = "Client that this network is assigned to"
}

variable "aws_profile_name" {
  type = string  
}

variable "availability_zones" {
  #type = string
  default = "us-west-2a"
  description = "Availability zone for the network"
}

variable "type_count" {
  type = number
  default = 1
  description = "Number of application servers to deploy"
}

variable "app_public_ip" {
    type = bool
    default = true
    description = "Create a public IP for the appliation server"
}

variable "type_volume_size" {
  type = number
  description = "Volume size of the servers being created for the application"
}

variable "type_size" {
  type = string
  description = "Instance type for the servers to be spun up"
}

variable "type" {
  type = string
  description = "Type of servers being spun up"
}

variable "env" {
  type = string
  description = "Used to auto populate various names through systems"
}

variable "private_ssh_key_fn" {
    type = string
    description = "Private SSH Key Filename on local machine"
}

variable "internal_network_cidr" {
    type = string
    description = "Internal network for the environment"
}

variable "egress_access" {
    type = list
    description = "List of CIDRs that may be accessed from the servers"
}

variable "allow_ssh_sources" {
    type = list
    description = "List of CIDRs that may access the bastion server"
}


# ALB
variable "internal" {
  type        = bool
  description = "A boolean flag to determine whether the ALB should be internal"
}

variable "http_enabled" {
  type        = bool
  description = "A boolean flag to enable/disable HTTP listener"
}

variable "http_redirect" {
  type        = bool
  description = "A boolean flag to enable/disable HTTP redirect to HTTPS"
}

variable "access_logs_enabled" {
  type        = bool
  description = "A boolean flag to enable/disable access_logs"
}

variable "cross_zone_load_balancing_enabled" {
  type        = bool
  description = "A boolean flag to enable/disable cross zone load balancing"
}

variable "http2_enabled" {
  type        = bool
  description = "A boolean flag to enable/disable HTTP/2"
}

variable "idle_timeout" {
  type        = number
  description = "The time in seconds that the connection is allowed to be idle"
}

variable "ip_address_type" {
  type        = string
  description = "The type of IP addresses used by the subnets for your load balancer. The possible values are `ipv4` and `dualstack`."
}

variable "deletion_protection_enabled" {
  type        = bool
  description = "A boolean flag to enable/disable deletion protection for ALB"
}

variable "deregistration_delay" {
  type        = number
  description = "The amount of time to wait in seconds before changing the state of a deregistering target to unused"
}

variable "health_check_path" {
  type        = string
  description = "The destination for the health check request"
}

variable "health_check_timeout" {
  type        = number
  description = "The amount of time to wait in seconds before failing a health check request"
}

variable "health_check_healthy_threshold" {
  type        = number
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy"
}

variable "health_check_unhealthy_threshold" {
  type        = number
  description = "The number of consecutive health check failures required before considering the target unhealthy"
}

variable "health_check_interval" {
  type        = number
  description = "The duration in seconds in between health checks"
}

variable "health_check_matcher" {
  type        = string
  description = "The HTTP response codes to indicate a healthy check"
}

variable "alb_access_logs_s3_bucket_force_destroy" {
  type        = bool
  description = "A boolean that indicates all objects should be deleted from the ALB access logs S3 bucket so that the bucket can be destroyed without error"
}

variable "alb_access_logs_s3_bucket_force_destroy_enabled" {
  type        = bool
  description = <<-EOT
    When `true`, permits `force_destroy` to be set to `true`.
    This is an extra safety precaution to reduce the chance that Terraform will destroy and recreate
    your S3 bucket, causing COMPLETE LOSS OF ALL DATA even if it was stored in Glacier.
    WARNING: Upgrading this module from a version prior to 0.27.0 to this version
      will cause Terraform to delete your existing S3 bucket CAUSING COMPLETE DATA LOSS
      unless you follow the upgrade instructions on the Wiki [here](https://github.com/cloudposse/terraform-aws-s3-log-storage/wiki/Upgrading-to-v0.27.0-(POTENTIAL-DATA-LOSS)).
      See additional instructions for upgrading from v0.27.0 to v0.28.0 [here](https://github.com/cloudposse/terraform-aws-s3-log-storage/wiki/Upgrading-to-v0.28.0-and-AWS-provider-v4-(POTENTIAL-DATA-LOSS)).
    EOT
}

variable "target_group_port" {
  type        = number
  description = "The port for the default target group"
}

variable "target_group_target_type" {
  type        = string
  description = "The type (`instance`, `ip` or `lambda`) of targets that can be registered with the target group"
}

variable "stickiness" {
  type = object({
    cookie_duration = number
    enabled         = bool
  })
  description = "Target group sticky configuration"
}