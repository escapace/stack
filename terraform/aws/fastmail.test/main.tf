provider "aws" {}

resource "random_string" "id" {
  length = 8
  lower = true
  special = false
  upper = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_zone" "primary" {
  name = "${random_string.id.result}.com"

  lifecycle {
    create_before_destroy = true
  }
}

module "fastmail" {
  source             = "../fastmail"
  name               = "${random_string.id.result}"
  environment        = "${random_string.id.result}"
  zone_id            = "${aws_route53_zone.primary.zone_id}"
}
