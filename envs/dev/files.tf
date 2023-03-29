
resource "local_file" "octain_server_env" {
  
  filename = "../../scripts/.octain-${var.env}-env"

  file_permission = 0644

  content = <<-EOT
AWS_DEFAULT_REGION="${var.region}"
BUCKET_NAME="${module.octain.s3_bucket_name}"
SQL_HOST="${module.octain.db_host}"
SQL_DATABASE="${module.octain.db_name}"
SQL_USER="${module.octain.db_username}"
SQL_PASSWORD="${module.octain.db_password}"
SQL_PORT="3306"
AWS_PROFILE="octain"
AWS_ACCESS_KEY_ID="${module.octain.s3_access_key_id}"
AWS_SECRET_ACCESS_KEY="${module.octain.s3_secret_access_key}"
SQS_URL="${module.octain.sqs_url}"
APP_DOMAIN="${local.app_domain}"
APP_API_DOMAIN="${local.app_api_domain}"
SYSTEM_ADMIN_EMAIL="${local.https_admin_email}"
OAUTH_CLIENT_SECRET="${var.OAUTH_CLIENT_SECRET}"
AWS_ACCOUNT_ID="${local.account_id}"
AWS_ACCOUNT_REGION="${var.region}"
ECS_REPO_NAME="${module.octain.ecr_repo_name}"
APP_AUTH0_DOMAIN="${local.auth0_domain}"
APP_CLIENT_ID="${local.auth0_client_id}"
APP_HOST="${local.app_domain}"
GOOGLE_ANALYTICS="${local.google_analytics}"
SENDGRID="${var.SENDGRID}"
PUBLIC_IP="${concat(module.instance.*.public_ip, [""])[0]}"
OPENAI_KEY="${var.OPENAI_KEY}"
EOT

}

# Create login script for web server
resource "local_file" "app_cicd_info" {

  filename = "../../scripts/${var.env}-cicd-config"
  
  # Set to executable
  file_permission = 0755

  content = <<-EOT
#!/bin/bash

# GLOBAL:
#   - DEPLOYMENT_DIRECTORY
# DEV:
#   - DEV_SERVER_COUNT
#   - DEV_BASTION_HOST
#   - DEV_DEPLOYMENT_PRIVATE_KEY
#   - DEV_SERVER_IP_[0 to DEV_SERVER_COUNT - 1] e.g. DEV_SERVER_IP_0

# Convert to uppercase
ENV=$(echo "${var.env}" | tr '[a-z]' '[A-Z]')

if [[ ! -e "create-deployment-key" ]]; then
  echo "Run this is the root scripts directory, and try again .."
  exit 1
fi

if [[ ! -e "$${ENV}.pub" ]]; then
  ./create-deployment-key $${ENV}
fi

BASTION_EXT_IP=${module.bastion.public_ip}
WEBSERVER_DEPLOYMENT_KEY=$(cat $${ENV}.pub)

echo "CICD Pipeline Variables for Deployment"
declare -a SERVER_IPS=( ${join(" ",module.instance.*.private_ip)} )
echo "$${ENV}_SERVER_COUNT=${var.type_count}"
echo "$${ENV}_BASTION_HOST=$${BASTION_EXT_IP}"
echo "$${ENV}_DEPLOYMENT_PRIVATE_KEY=$${WEBSERVER_DEPLOYMENT_KEY}"

# Output all Application Server IPs
i=0
for host in $${SERVER_IPS[@]}; do
  echo "$${ENV}_SERVER_IP_$${i}=$${host}"
  ((i=i+1))
done

  EOT
}

# Create login script for web server
resource "local_file" "app_login_scripts" {
  count = var.type_count

  filename = "../../scripts/${var.env}-${var.type}-${count.index}"
  
  # Set to executable
  file_permission = 0755

  content = <<-EOT
#!/bin/bash

BASTION_EXT_IP=${module.bastion.public_ip}
SERVER_INT_IP=${module.instance[count.index].private_ip}

ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -o "proxycommand ssh -W %h:%p ubuntu@$BASTION_EXT_IP" ubuntu@$SERVER_INT_IP
  EOT
}

# Create login script for the bastion
resource "local_file" "bastion_login_script" {
  filename = "../../scripts/${var.env}-bastion"
  
  # Set to executable
  file_permission = 0755

  content = <<-EOT
#!/bin/bash

BASTION_EXT_IP=${module.bastion.public_ip}

ssh -o StrictHostKeyChecking=no -o "UserKnownHostsFile=/dev/null"  ubuntu@$BASTION_EXT_IP
  EOT
}
