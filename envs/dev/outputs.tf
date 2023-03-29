# output "alb_name" {
#   description = "The ARN suffix of the ALB"
#   value       = module.alb.alb_name
# }

# output "alb_dns_name" {
#   description = "DNS name of ALB"
#   value       = module.alb.alb_dns_name
# }

output "bastion_ip" {
  description = "Public IP of Bastion"
  value       = concat(module.bastion.*.public_ip, [""])[0]
}

output "web_ip" {
  description = "Public IP of Web Server"
  value       = concat(module.instance.*.public_ip, [""])[0]
}

# output "private_key" {
#   description = "Private SSH Key to login to servers"
#   sensitive   = true
#   value       = resource.aws_key_pair.root.private_key_pem
# }

# output "private_key_filename" {
#   description = "Private SSH Key filename"
#   sensitive   = true
#   value       = "${var.namespace}_${var.env}_ec2_key"
# }