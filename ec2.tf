provider "aws" {
    region = "${var.AWS_REGION}"
}

locals {
  userdata = templatefile("user_data.sh", {
    ssm_cloudwatch_config = aws_ssm_parameter.cw_agent.name
  })
}

# Creating EC2 instance in Private Subnet
resource "aws_instance" "demoinstance1" {
  ami           = "ami-0a24ce26f4e187f9a"
  instance_type = "t2.micro"
  count = 1
  key_name = "test"
  vpc_security_group_ids = [ aws_security_group.demosg.id ]
  subnet_id = aws_subnet.demosubnet2.id
  iam_instance_profile = aws_iam_instance_profile.this.name
  user_data = local.userdata
}



resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent config to configure custom log"
  name        = "/cloudwatch-agent/config"
  type        = "String"
  value       = file("cw_agent_config.json")
}

resource "aws_lb" "test-lb" {
  name               = "test-lb"
  internal           = true
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  subnets            = ["${var.subnet_id1}", "${var.subnet_id2}"]

  enable_deletion_protection = true
