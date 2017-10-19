provider "packet" {}

variable "PACKET_PROJECT_ID" {}

variable "facilities" {
  default = ["ams1", "ams1"]
}

variable "plans" {
  default = ["baremetal_0", "baremetal_0"]
}

variable "volume_plans" {
  default = ["storage_2", "storage_1"]
}

variable "volume_sizes" {
  default = [60, 60]
}

module "packer_device" {
  source       = "../device"
  project_id   = "${var.PACKET_PROJECT_ID}"
  facilities   = "${var.facilities}"
  plans        = "${var.plans}"
  volume_plans = "${var.volume_plans}"
  volume_sizes = "${var.volume_sizes}"
}
