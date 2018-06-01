/* Source code for this software was modified from */
/* https://github.com/segmentio/stack. See SEGMENTIO-STACK-LICENSE license for */
/* details. */

variable "namespace" {
  description = "Namespace, which could be your organization name"
  type        = "string"
}

variable "stage" {
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
  type        = "string"
}

variable "name" {
  description = "Name  (e.g. `bastion` or `db`)"
  type        = "string"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `name`, `namespace`, `stage`, etc."
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `policy` or `role`)"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. map('BusinessUnit`,`XYZ`)"
}

//

variable "cidr_block" {
  description = <<EOF
  the CIDR block to provision for the VPC, if set to something
  other than the default, both internal_subnets and external_subnets have to be
  defined as well
EOF
}

variable "external_subnets" {
  description = <<EOF
  a list of CIDRs for external subnets in your VPC, must be set
  if the cidr variable is defined, needs to have as many elements as there are
  availability zones
EOF

  type = "list"
}

variable "internal_subnets" {
  description = <<EOF
  a list of CIDRs for internal subnets in your VPC, must be set
  if the cidr variable is defined, needs to have as many elements as there are
  availability zones
EOF

  type = "list"
}

variable "availability_zones" {
  description = <<EOF
  a comma-separated list of availability zones, defaults to all
  AZ of the region, if set to something other than the defaults, both
  internal_subnets and external_subnets have to be defined as well
EOF

  type = "list"
}

/**
* VPC
*/

module "label" {
  source     = "../../generic/null-label"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
}

resource "aws_vpc" "main" {
  cidr_block                       = "${var.cidr_block}"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true

  tags = "${module.label.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

/**
* Gateways
*/

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  lifecycle {
    create_before_destroy = true
  }

  tags = "${module.label.tags}"
}

resource "aws_nat_gateway" "main" {
  count         = "${length(var.internal_subnets)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.external.*.id, count.index)}"
  depends_on    = ["aws_internet_gateway.main"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "nat" {
  count = "${length(var.internal_subnets)}"
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }
}

/**
* Subnets.
*/

resource "aws_subnet" "external" {
  vpc_id                          = "${aws_vpc.main.id}"
  cidr_block                      = "${element(var.external_subnets, count.index)}"
  availability_zone               = "${element(var.availability_zones, count.index)}"
  count                           = "${length(var.external_subnets)}"
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true
  ipv6_cidr_block                 = "${cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, count.index+length(var.external_subnets))}"

  tags = "${module.label.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "internal" {
  vpc_id                          = "${aws_vpc.main.id}"
  cidr_block                      = "${element(var.internal_subnets, count.index)}"
  availability_zone               = "${element(var.availability_zones, count.index)}"
  count                           = "${length(var.internal_subnets)}"
  assign_ipv6_address_on_creation = true
  ipv6_cidr_block                 = "${cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, count.index)}"

  tags = "${module.label.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

/**
* Route tables
*/

resource "aws_route_table" "external" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = "${aws_internet_gateway.main.id}"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags = "${module.label.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "internal" {
  count  = "${length(var.internal_subnets)}"
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.main.*.id, count.index)}"
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = "${aws_internet_gateway.main.id}"

    /* egress_only_gateway_id = "${aws_egress_only_internet_gateway.egress.id}" */
  }

  tags = "${module.label.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

/**
* Route associations
*/

resource "aws_route_table_association" "internal" {
  count          = "${length(var.internal_subnets)}"
  subnet_id      = "${element(aws_subnet.internal.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.internal.*.id, count.index)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table_association" "external" {
  count          = "${length(var.external_subnets)}"
  subnet_id      = "${element(aws_subnet.external.*.id, count.index)}"
  route_table_id = "${aws_route_table.external.id}"

  lifecycle {
    create_before_destroy = true
  }
}

/**
* Outputs
*/

// The VPC ID
output "id" {
  value = "${aws_vpc.main.id}"
}

// A comma-separated list of subnet IDs.
output "external_subnets" {
  value = ["${aws_subnet.external.*.id}"]
}

// A list of subnet IDs.
output "internal_subnets" {
  value = ["${aws_subnet.internal.*.id}"]
}

// The default VPC security group ID.
output "security_group" {
  value = "${aws_vpc.main.default_security_group_id}"
}

// The list of availability zones of the VPC.
output "availability_zones" {
  value = ["${aws_subnet.external.*.availability_zone}"]
}

// The internal route table ID.
output "internal_rtb_id" {
  value = "${join(",", aws_route_table.internal.*.id)}"
}

// The external route table ID.
output "external_rtb_id" {
  value = "${aws_route_table.external.id}"
}

// The list of EIPs associated with the internal subnets.
output "internal_nat_ips" {
  value = ["${aws_eip.nat.*.public_ip}"]
}

output "ipv6_cidr_block" {
  value = "${aws_vpc.main.ipv6_cidr_block}"
}
