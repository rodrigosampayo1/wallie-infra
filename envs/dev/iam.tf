
resource "aws_key_pair" "root" {

    key_name   = "octain_${var.namespace}_${var.env}_ec2_key"
    public_key = file("${pathexpand(var.private_ssh_key_fn)}.pub")

}

# EC2 IAM Policy for SQS and Cloud Watch Metric Delivery
resource "aws_iam_role" "ec2_access_role" {

  name               = "octain-${var.namespace}-${var.env}-${var.region}-${resource.random_string.ec2_suffix.result}-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [        
        {
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },            
            "Action": "sts:AssumeRole",
            "Effect": "Allow"
        }
    ]
}
EOF

}

# EC2 IAM Policy for SQS and Cloud Watch Metric Delivery
resource "aws_iam_role_policy" "ec2_metrics_access_role_policy" {
    
  name = "octain-${var.namespace}-${var.env}-${var.region}-${resource.random_string.ec2_suffix.result}-role-policy"
  role = aws_iam_role.ec2_access_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "cloudwatch:PutMetricData"
            ],
            "Resource": "*"
        }     
    ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_iam_profile" {

  name  = "octain-${var.namespace}-${var.env}-${var.region}-${resource.random_string.ec2_suffix.result}-profile"
  role  = aws_iam_role.ec2_access_role.name

}
