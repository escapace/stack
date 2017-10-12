variable "environment" {
  description = "Environment tag, e.g prod (only lowercase alphanumeric characters and hyphens allowed)"
}

variable "name" {
  description = "Name tag, e.g stack (only lowercase alphanumeric characters and hyphens allowed)"
  default     = "stack"
}

variable "role" {
  description = "IAM role name"
}

data "aws_iam_role" "secure-store-role" {
  name = "${var.role}"
}

resource "aws_s3_bucket" "secure-store-logs" {
  bucket = "secure-store-logs-${var.name}-${var.environment}"
  acl    = "log-delivery-write"

  lifecycle_rule {
    id      = "log"
    enabled = true

    prefix  = "log/"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 180
    }
  }

  tags {
    Name = "${var.name}"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket" "secure-store" {
  bucket = "secure-store-${var.name}-${var.environment}"
  acl    = "private"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.secure-store-logs.id}"
    target_prefix = "log/"
  }

  tags {
    Name = "${var.name}"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_iam_policy" "secure-store-policy" {
    name = "secure-store-policy.${var.name}-${var.environment}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [ "s3:*" ],
      "Resource": [
        "${aws_s3_bucket.secure-store.arn}",
        "${aws_s3_bucket.secure-store.arn}/*"
      ]
    }
  ]
}
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket_policy" "secure-store-bucket-policy" {
  bucket = "${aws_s3_bucket.secure-store.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_iam_role.secure-store-role.arn}"
      },
      "Action": [ "s3:*" ],
      "Resource": [
        "${aws_s3_bucket.secure-store.arn}",
        "${aws_s3_bucket.secure-store.arn}/*"
      ]
    }
  ]
}
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "secure-store-policy-attachment" {
  role       = "${data.aws_iam_role.secure-store-role.name}"
  policy_arn = "${aws_iam_policy.secure-store-policy.arn}"

  lifecycle {
    create_before_destroy = true
  }
}

output "bucket_domain_name" {
  value = "${aws_s3_bucket.secure-store.bucket_domain_name}"
}

output "id" {
  value = "${aws_s3_bucket.secure-store.id}"
}

output "arn" {
  value = "${aws_s3_bucket.secure-store.arn}"
}
