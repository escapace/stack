provider "aws" {}

variable "region" {
  description = <<EOF
  the AWS region in which resources are created, you must
  set the availability_zones variable as well if you define this value to
  something other than the default"
  EOF

  default = "us-west-2"
}

resource "random_string" "id" {
  length  = 8
  lower   = true
  special = false
  upper   = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "default_role" {
  name = "${random_string.id.result}"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  lifecycle {
    create_before_destroy = true
  }
}

module "secure-store" {
  source      = "../secure-store"
  name        = "${random_string.id.result}"
  environment = "${random_string.id.result}"
  role        = "${aws_iam_role.default_role.name}"
}
