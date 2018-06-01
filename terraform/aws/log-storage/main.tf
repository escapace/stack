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

variable "acl" {
  description = "(Optional) The canned ACL to apply. We recommend log-delivery-write for compatibility with AWS services"
  default     = "log-delivery-write"
}

variable "policy" {
  description = "A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy."
  default     = ""
}

variable "prefix" {
  description = "(Optional) Key prefix. Used to manage object lifecycle events."
  default     = ""
}

variable "region" {
  description = "(Optional) If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee."
  default     = ""
}

variable "force_destroy" {
  description = "(Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default     = "false"
}

variable "lifecycle_rule_enabled" {
  description = "(Optional) enable lifecycle events on this bucket"
  default     = "true"
}

variable "versioning_enabled" {
  description = "(Optional) A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket."
  default     = "false"
}

variable "noncurrent_version_expiration_days" {
  description = "(Optional) Specifies when noncurrent object versions expire."
  default     = "90"
}

variable "noncurrent_version_transition_days" {
  description = "(Optional) Specifies when noncurrent object versions transitions"
  default     = "30"
}

variable "standard_transition_days" {
  description = "Number of days to persist in the standard storage tier before moving to the infrequent access tier"
  default     = "30"
}

variable "glacier_transition_days" {
  description = "Number of days after which to move the data to the glacier storage tier"
  default     = "60"
}

variable "expiration_days" {
  description = "Number of days after which to expunge the objects"
  default     = "90"
}

variable "sse_algorithm" {
  description = "The server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  default     = "AES256"
}

variable "kms_master_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms"
  default     = ""
}

/**
* log-storage
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

data "aws_caller_identity" "current" {}

data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"

  vars = {
    bucket     = "${module.label.id}"
    account_id = "${data.aws_caller_identity.current.account_id}"
  }
}

resource "aws_s3_bucket" "default" {
  bucket        = "${module.label.id}"
  acl           = "${var.acl}"
  region        = "${var.region}"
  force_destroy = "${var.force_destroy}"
  policy        = "${var.policy}"
  policy        = "${var.policy == "" ? data.template_file.policy.rendered : var.policy}"

  versioning {
    enabled = "${var.versioning_enabled}"
  }

  lifecycle {
    create_before_destroy = true
  }

  lifecycle_rule {
    id      = "${module.label.id}"
    enabled = "${var.lifecycle_rule_enabled}"

    prefix = "${var.prefix}"
    tags   = "${module.label.tags}"

    noncurrent_version_expiration {
      days = "${var.noncurrent_version_expiration_days}"
    }

    noncurrent_version_transition {
      days          = "${var.noncurrent_version_transition_days}"
      storage_class = "GLACIER"
    }

    transition {
      days          = "${var.standard_transition_days}"
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = "${var.glacier_transition_days}"
      storage_class = "GLACIER"
    }

    expiration {
      days = "${var.expiration_days}"
    }
  }

  # https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html
  # https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#enable-default-server-side-encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "${var.sse_algorithm}"
        kms_master_key_id = "${var.kms_master_key_id}"
      }
    }
  }

  tags = "${module.label.tags}"
}

output "bucket_domain_name" {
  value = "${aws_s3_bucket.default.bucket_domain_name}"
}

output "bucket_id" {
  value = "${aws_s3_bucket.default.id}"
}

output "bucket_arn" {
  value = "${aws_s3_bucket.default.arn}"
}

output "prefix" {
  value = "${var.prefix}"
}
