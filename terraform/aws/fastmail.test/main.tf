provider "aws" {}

resource "aws_route53_zone" "primary" {
  name = "testtesttest.com"
}

module "fastmail" {
  source             = "../fastmail"
  name               = "testtesttest.com"
  zone_id            = "${aws_route53_zone.primary.zone_id}"
}
