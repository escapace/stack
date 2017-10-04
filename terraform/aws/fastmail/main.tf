variable "name" {}
variable "zone_id" {}

variable "spf_include" {
  default = [
    "include:spf.messagingengine.com",
  ]
}

resource "aws_route53_record" "mx_records" {
  zone_id = "${var.zone_id}"
  name    = "${var.name}"
  type    = "MX"
  ttl     = "300"

  records = [
    "10 in1-smtp.messagingengine.com.",
    "20 in2-smtp.messagingengine.com.",
  ]
}

resource "aws_route53_record" "spf_txt" {
  zone_id = "${var.zone_id}"
  name    = "${var.name}"
  type    = "TXT"
  ttl     = "300"

  records = [
    "v=spf1 ${join(" ", var.spf_include)} ?all",
  ]
}

resource "aws_route53_record" "spf_spf" {
  zone_id = "${var.zone_id}"
  name    = "${var.name}"
  type    = "SPF"
  ttl     = "300"

  records = [
    "v=spf1 ${join(" ", var.spf_include)} ?all",
  ]
}

resource "aws_route53_record" "mesmtp_domainkey" {
  zone_id = "${var.zone_id}"
  name    = "mesmtp._domainkey"
  type    = "CNAME"
  ttl     = "300"

  records = [
    "mesmtp.${var.name}.dkim.fmhosted.com.",
  ]
}

resource "aws_route53_record" "fm1_domainkey" {
  zone_id = "${var.zone_id}"
  name    = "fm1._domainkey"
  type    = "CNAME"
  ttl     = "300"

  records = [
    "fm1.${var.name}.dkim.fmhosted.com.",
  ]
}

resource "aws_route53_record" "fm2_domainkey" {
  zone_id = "${var.zone_id}"
  name    = "fm2._domainkey"
  type    = "CNAME"
  ttl     = "300"

  records = [
    "fm2.${var.name}.dkim.fmhosted.com.",
  ]
}

resource "aws_route53_record" "fm3_domainkey" {
  zone_id = "${var.zone_id}"
  name    = "fm3._domainkey"
  type    = "CNAME"
  ttl     = "300"

  records = [
    "fm3.${var.name}.dkim.fmhosted.com.",
  ]
}

resource "aws_route53_record" "caldavs" {
  zone_id = "${var.zone_id}"
  name    = "_caldavs._tcp"
  type    = "SRV"
  ttl     = "300"

  records = [
    "0 1 443 caldav.fastmail.com.",
  ]
}

resource "aws_route53_record" "pop3s" {
  zone_id = "${var.zone_id}"
  name    = "_pop3s._tcp"
  type    = "SRV"
  ttl     = "300"

  records = [
    "10 1 995 pop.fastmail.com.",
  ]
}

resource "aws_route53_record" "carddavs" {
  zone_id = "${var.zone_id}"
  name    = "_carddavs._tcp"
  type    = "SRV"
  ttl     = "300"

  records = [
    "0 1 443 carddav.fastmail.com.",
  ]
}

resource "aws_route53_record" "imaps" {
  zone_id = "${var.zone_id}"
  name    = "_imaps._tcp"
  type    = "SRV"
  ttl     = "300"

  records = [
    "0 1 993 imap.fastmail.com.",
  ]
}

resource "aws_route53_record" "submission" {
  zone_id = "${var.zone_id}"
  name    = "_submission._tcp"
  type    = "SRV"
  ttl     = "300"

  records = [
    "0 1 587 smtp.fastmail.com.",
  ]
}
