variable "region" {
  description = "The AWS region"
}

variable "cidr_block" {
  description = "The CIDR block to provision for the VPC"
}

variable "default_ecs_ami" {
  default = {
    us-east-1      = "ami-dde4e6ca"
    us-west-1      = "ami-6d21770d"
    us-west-2      = "ami-97da70f7"
    eu-west-1      = "ami-c41f3bb7"
    eu-central-1   = "ami-4ba16024"
    ap-northeast-1 = "ami-90ea86f7"
    ap-northeast-2 = "ami-8a4b9ce4"
    ap-southeast-1 = "ami-d603afb5"
    ap-southeast-2 = "ami-1ddce47e"
    sa-east-1      = "ami-29039a45"
  }
}

output "ecs_ami" {
  value = "${lookup(var.default_ecs_ami, var.region)}"
}

output "domain_name_servers" {
  value = "${cidrhost(var.cidr_block, 2)}"
}
