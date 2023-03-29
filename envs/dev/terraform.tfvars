# --------------------------------------------------------------------------------------------------
# Variables for root module.
# --------------------------------------------------------------------------------------------------

namespace = "wallie"
region = "us-west-2"
env = "dev"

aws_profile_name = "default"

# Send emails to #octain-tech-team
monitoring_email = "kc-octain-devops-dev-aaaaiur4sg2lnhxeyco6e6g7au@kinandcarta.slack.com"
#monitoring_email = "brandon.wilkins@kinandcarta.com"

type_count = 1
type = "octain"
type_size = "t2.micro"
type_volume_size = 20
app_public_ip = true # When setting to false, must have VPC Egress Configured

# Enable Load Balancing and Register all Targets
enable_lb = false

# Improve to allow for many zones to have severs deployed to for futher environments
availability_zones = ["us-west-2a", "us-west-2c"]

# Location of the SSH Private Key for Public Key provided Above
private_ssh_key_fn = "~/.ssh/id_rsa"

internal_network_cidr = "10.13.1.0/24"

allow_ssh_sources = [
    "0.0.0.0/0",

    # Brandon Wilkins IP
    #"99.35.61.177/32"
]

# Allow internet access to
egress_access = [
    "0.0.0.0/0"
]

# Allow HTTP/S Traffic ingress to the application servers
allow_http_access = [
    "0.0.0.0/0",
 
    # Cloudflare Proxy IPs: Available from https://www.cloudflare.com/ips-v4
    "173.245.48.0/20",
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "141.101.64.0/18",
    "108.162.192.0/18",
    "190.93.240.0/20",
    "188.114.96.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17",
    "162.158.0.0/15",
    "104.16.0.0/13",
    "104.24.0.0/14",
    "172.64.0.0/13",
    "131.0.72.0/22"
    
]

# TODO: Generate a new SSH Key on Creation of the Development Environment

# ** IN PROGRESS **
# Blue/Green Deployments - Deploy the new color and turn off the old color
# This would require a Load Balancer to direct the traffic to the correct color
# Step 1. Spin up the new color
# Step 2. Verify that the new color is working and testing correctly
# Step 3. Migrate the traffic to the new color.
# Step 4. Await the traffic to be drained and redirected, turn off old color.
#blue = true
#green = false
#traffic_color = "blue"


## ALB
alb_enabled = false
internal = false
http_enabled = true
http_redirect = false
access_logs_enabled = true
alb_access_logs_s3_bucket_force_destroy = true
alb_access_logs_s3_bucket_force_destroy_enabled = true
cross_zone_load_balancing_enabled = false
http2_enabled = true
idle_timeout = 60
ip_address_type = "ipv4"
deletion_protection_enabled = false
deregistration_delay = 15
health_check_path = "/"
health_check_timeout = 10
health_check_healthy_threshold = 2
health_check_unhealthy_threshold = 2
health_check_interval = 15
health_check_matcher = "200-399"
target_group_port = 80
target_group_target_type = "instance"
stickiness = {
  cookie_duration = 60
  enabled         = true
}

