variable "domain" {}

variable "spf_include" {
  default = [
    "include:spf.messagingengine.com",
  ]
}

resource "cloudflare_record" "mx_record10" {
  domain   = "${var.domain}"
  name     = "${var.domain}"
  type     = "MX"
  ttl      = "300"
  value    = "in1-smtp.messagingengine.com."
  priority = 10

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "mx_record20" {
  domain   = "${var.domain}"
  name     = "${var.domain}"
  type     = "MX"
  ttl      = "300"
  value    = "in2-smtp.messagingengine.com."
  priority = 20

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "spf_txt" {
  domain = "${var.domain}"
  name   = "${var.domain}"
  type   = "TXT"
  ttl    = "300"
  value  = "v=spf1 ${join(" ", var.spf_include)} ?all"

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "spf_spf" {
  domain = "${var.domain}"
  name   = "${var.domain}"
  type   = "SPF"
  ttl    = "300"
  value  = "v=spf1 ${join(" ", var.spf_include)} ?all"

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "fm1_domainkey" {
  domain = "${var.domain}"
  name   = "fm1._domainkey"
  type   = "CNAME"
  ttl    = "300"
  value  = "fm1.${var.domain}.dkim.fmhosted.com."

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "fm2_domainkey" {
  domain = "${var.domain}"
  name   = "fm2._domainkey"
  type   = "CNAME"
  ttl    = "300"
  value  = "fm2.${var.domain}.dkim.fmhosted.com."

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "fm3_domainkey" {
  domain = "${var.domain}"
  name   = "fm3._domainkey"
  type   = "CNAME"
  ttl    = "300"
  value  = "fm3.${var.domain}.dkim.fmhosted.com."

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "caldavs" {
  domain = "${var.domain}"
  name   = "${var.domain}"
  type   = "SRV"
  ttl    = "300"

  data = {
    proto    = "_tcp"
    service  = "_caldavs"
    priority = 0
    weight   = 1
    port     = 443
    target   = "caldav.fastmail.com."
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "pop3s" {
  domain = "${var.domain}"
  name   = "${var.domain}"
  type   = "SRV"
  ttl    = "300"

  data = {
    proto    = "_tcp"
    service  = "_pop3s"
    priority = 10
    weight   = 1
    port     = 995
    target   = "pop.fastmail.com."
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "carddavs" {
  domain = "${var.domain}"
  name   = "${var.domain}"
  type   = "SRV"
  ttl    = "300"

  data = {
    proto    = "_tcp"
    service  = "_carddavs"
    priority = 0
    weight   = 1
    port     = 443
    target   = "carddav.fastmail.com."
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "imaps" {
  domain = "${var.domain}"
  name   = "${var.domain}"
  type   = "SRV"
  ttl    = "300"

  data = {
    proto    = "_tcp"
    service  = "_imaps"
    priority = 0
    weight   = 1
    port     = 993
    target   = "imap.fastmail.com."
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "submission" {
  domain = "${var.domain}"
  name   = "${var.domain}"
  type   = "SRV"
  ttl    = "300"

  data = {
    proto    = "_tcp"
    service  = "_submission"
    priority = 0
    weight   = 1
    port     = 587
    target   = "smtp.fastmail.com."
  }

  lifecycle {
    create_before_destroy = true
  }
}
