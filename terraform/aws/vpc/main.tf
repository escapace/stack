variable "cidr_block" {
  description = "The CIDR block for the VPC."
}

variable "external_subnets" {
  description = "List of external subnets"
  type        = "list"
}

variable "internal_subnets" {
  description = "List of internal subnets"
  type        = "list"
}

variable "environment" {
  description = "Environment tag, e.g prod"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = "list"
}

variable "name" {
  description = "Name tag, e.g stack"
  default     = "stack"
}

/**
* VPC
*/

resource "aws_vpc" "main" {
  cidr_block                       = "${var.cidr_block}"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true

  tags {
    Name        = "${var.name}"
    Environment = "${var.environment}"
  }

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

  tags {
    Name        = "${var.name}"
    Environment = "${var.environment}"
  }
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

  tags {
    Name = "${var.name}"
    Environment = "${var.environment}"
    Placement = "${format("external-%03d", count.index+1)}"
  }

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

  tags {
    Name = "${var.name}"
    Environment = "${var.environment}"
    Placement = "${format("internal-%03d", count.index+1)}"
  }

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

  tags {
    Name = "${var.name}"
    Environment = "${var.environment}"
  }

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

  tags {
    Name = "${var.name}"
    Environment = "${var.environment}"
    Placement = "${format("internal-%03d", count.index+1)}"
  }

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
