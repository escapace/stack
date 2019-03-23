variable "project_id" {
  description = "The id of the project in which to create the device(s)"
}

variable "facilities" {
  type        = "list"
  description = "List of the device facilities"
}

variable "plans" {
  description = "List of the device hardware config slugs"
  type        = "list"
}

variable "volume_plans" {
  type        = "list"
  description = "List of the volume service plan slugs"
}

variable "volume_sizes" {
  type        = "list"
  description = "List of the volume sizes in GB"
}

variable "snapshot_frequency" {
  description = "The snapshot frequency"
  default     = "1month"
}

variable "snapshot_count" {
  description = "Keep n recent snapshots"
  default     = "3"
}

resource "packet_reserved_ip_block" "eip" {
  count      = "${length(var.facilities)}"
  project_id = "${var.project_id}"
  facility   = "${element(var.facilities, count.index)}"
  quantity   = 1

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_pet" "name" {
  count  = "${length(var.facilities)}"
  length = 3

  keepers = {
    cidr_notation = "${element(packet_reserved_ip_block.eip.*.cidr_notation, count.index)}"
    project_id    = "${var.project_id}"
  }
}

resource "packet_device" "device" {
  count            = "${length(var.facilities)}"
  project_id       = "${var.project_id}"
  hostname         = "${element(random_pet.name.*.id, count.index)}"
  facilities       = ["${element(var.facilities, count.index)}"]
  plan             = "${element(var.plans, count.index)}"
  billing_cycle    = "hourly"
  operating_system = "centos_7"

  lifecycle {
    create_before_destroy = true
  }
}

resource "packet_ip_attachment" "attachment" {
  count         = "${length(var.facilities)}"
  device_id     = "${element(packet_device.device.*.id, count.index)}"
  cidr_notation = "${cidrhost(element(packet_reserved_ip_block.eip.*.cidr_notation, count.index), 0)}/32"

  lifecycle {
    create_before_destroy = true
  }
}

resource "packet_volume" "volume" {
  billing_cycle = "hourly"
  count         = "${length(var.facilities)}"
  description   = "${element(random_pet.name.*.id, count.index)} volume"
  facility      = "${element(var.facilities, count.index)}"
  plan          = "${element(var.volume_plans, count.index)}"
  project_id    = "${var.project_id}"
  size          = "${element(var.volume_sizes, count.index)}"

  snapshot_policies = {
    snapshot_frequency = "${var.snapshot_frequency}"
    snapshot_count     = "${var.snapshot_count}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "packet_volume_attachment" "attachment" {
  count     = "${length(var.facilities)}"
  device_id = "${element(packet_device.device.*.id, count.index)}"
  volume_id = "${element(packet_volume.volume.*.id, count.index)}"

  lifecycle {
    create_before_destroy = true
  }
}
