
locals {
  instance_sg = [
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
      cidr_blocks = [var.internal_network_cidr]      # Local Network Only
    },
    {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = var.allow_http_access
    },
    {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = var.allow_http_access
    }
  ]

  ami = "ami-0014615d641e8e15e"
  app_domain = "dev-app.octain.net"
  app_api_domain = "api-dev-app.octain.net"
  https_admin_email = "brandon.wilkins@kinandcarta.com"
  auth0_domain = "kinandcarta-octain.us.auth0.com"
  auth0_client_id = "LMyOFi2Kv3dJCTkIOwJM9FQf3oqLclfx"
  google_analytics = "G-TZQH56PKY9"
  
  # Keep logs for 90 days in Cloudwatch
  cloudwatch_log_retention_days = 90

  # Active AWS Account ID
  account_id = data.aws_caller_identity.current.account_id

}
