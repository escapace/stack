provider "aws" {}

variable "region" {
  description = <<EOF
  the AWS region in which resources are created, you must
  set the availability_zones variable as well if you define this value to
  something other than the default"
EOF

  default = "us-west-2"
}

variable "cidr_block" {
  description = <<EOF
  the CIDR block to provision for the VPC, if set to something
  other than the default, both internal_subnets and external_subnets have to be
  defined as well
EOF

  default = "10.30.0.0/16"
}

variable "internal_subnets" {
  description = <<EOF
  a list of CIDRs for internal subnets in your VPC, must be set
  if the cidr variable is defined, needs to have as many elements as there are
  availability zones
EOF

  default = ["10.30.0.0/19", "10.30.32.0/19", "10.30.64.0/19"]
}

variable "external_subnets" {
  description = <<EOF
  a list of CIDRs for external subnets in your VPC, must be set
  if the cidr variable is defined, needs to have as many elements as there are
  availability zones
EOF

  default = ["10.30.96.0/19", "10.30.128.0/19", "10.30.160.0/19"]
}

variable "availability_zones" {
  description = <<EOF
  a comma-separated list of availability zones, defaults to all
  AZ of the region, if set to something other than the defaults, both
  internal_subnets and external_subnets have to be defined as well
EOF

  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

module "vpc" {
  source             = "../.."
  name               = "vpc"
  stage              = "testing"
  namespace          = "travis"
  cidr_block         = "${var.cidr_block}"
  internal_subnets   = "${var.internal_subnets}"
  external_subnets   = "${var.external_subnets}"
  availability_zones = "${var.availability_zones}"
}
