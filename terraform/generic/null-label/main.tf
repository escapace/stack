variable "namespace" {
  description = "Namespace, which could be your organization name, e.g. 'cp' or 'cloudposse'"
}

variable "stage" {
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
}

variable "name" {
  description = "Solution name, e.g. 'app' or 'jenkins'"
}

variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  default     = "true"
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
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}

variable "additional_tag_map" {
  type        = "map"
  default     = {}
  description = "Additional tags for appending to each tag map."
}

locals {
  enabled    = "${var.enabled == "true" ? true : false }"
  id         = "${local.enabled ? lower(join(var.delimiter, compact(concat(list(var.namespace, var.stage, var.name), var.attributes)))) : ""}"
  name       = "${local.enabled ? lower(format("%v", var.name)) : ""}"
  namespace  = "${local.enabled ? lower(format("%v", var.namespace)) : ""}"
  stage      = "${local.enabled ? lower(format("%v", var.stage)) : ""}"
  attributes = "${local.enabled ? lower(format("%v", join(var.delimiter, compact(var.attributes)))) : ""}"

  tags = "${
      merge( 
        map(
          "Name", "${local.id}",
          "Namespace", "${local.namespace}",
          "Stage", "${local.stage}"
        ), var.tags
      )
    }"

  tags_as_list_of_maps = ["${null_resource.tags_as_list_of_maps.*.triggers}"]
}

resource "null_resource" "tags_as_list_of_maps" {
  count = "${length(keys(local.tags))}"

  triggers = "${merge(map(
    "key", "${element(keys(local.tags), count.index)}",
    "value", "${element(values(local.tags), count.index)}"
  ),
  var.additional_tag_map)}"
}

output "id" {
  value       = "${local.id}"
  description = "Disambiguated ID"
}

output "name" {
  value       = "${local.name}"
  description = "Normalized name"
}

output "namespace" {
  value       = "${local.namespace}"
  description = "Normalized namespace"
}

output "stage" {
  value       = "${local.stage}"
  description = "Normalized stage"
}

output "attributes" {
  value       = "${local.attributes}"
  description = "Normalized attributes"
}

output "tags" {
  value       = "${local.tags}"
  description = "Normalized Tag map"
}

output "tags_as_list_of_maps" {
  value       = ["${local.tags_as_list_of_maps}"]
  description = "Additional tags as a list of maps, which can be used in several AWS resources"
}
