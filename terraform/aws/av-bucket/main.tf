module "default_label" {
  source     = "../../generic/null-label"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
}

resource "aws_s3_bucket" "definitions" {
  bucket        = "${module.default_label.id}-definitions"
  acl           = "${var.definitions_acl}"
  region        = "${var.definitions_region}"
  force_destroy = "${var.definitions_force_destroy}"
  policy        = "${var.definitions_policy}"

  versioning {
    enabled = "${var.definitions_versioning_enabled}"
  }

  lifecycle_rule {
    id      = "${module.default_label.id}"
    enabled = "${var.definitions_lifecycle_rule_enabled}"

    prefix = "${var.lifecycle_prefix}"
    tags   = "${var.definitions_lifecycle_tags}"

    noncurrent_version_expiration {
      days = "${var.definitions_noncurrent_version_expiration_days}"
    }

    noncurrent_version_transition {
      days          = "${var.definitions_noncurrent_version_transition_days}"
      storage_class = "GLACIER"
    }

    transition {
      days          = "${var.definitions_standard_transition_days}"
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = "${var.definitions_glacier_transition_days}"
      storage_class = "GLACIER"
    }

    expiration {
      days = "${var.definitions_expiration_days}"
    }
  }

  # https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html
  # https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#enable-default-server-side-encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "${var.definitions_sse_algorithm}"
        kms_master_key_id = "${var.definitions_kms_master_key_id}"
      }
    }
  }

  tags = "${module.default_label.tags}"
}

resource "null_resource" "lambda" {
  provisioner "local-exec" {
    command = "curl -0 -s -S -L https://github.com/escapace/bucket-antivirus-function/releases/download/v${var.version}/lambda.zip -o ${path.module}/files/lambda.zip"
  }
}

resource "aws_iam_role" "definition_update" {
  name = "${module.default_label.id}-definition-update"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "definition_update" {
  name        = "${module.default_label.id}-definition-update"
  path        = "/"
  description = "IAM policy for clamav defintion updates"

  policy = <<POLICY
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
         ],
         "Resource":"*"
      },
      {
         "Action":[
            "s3:GetObject",
            "s3:GetObjectTagging",
            "s3:PutObject",
            "s3:PutObjectTagging",
            "s3:PutObjectVersionTagging"
         ],
         "Effect":"Allow",
         "Resource":"${aws_s3_bucket.definitions.arn}/*"
      }
   ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "definition_update" {
  role       = "${aws_iam_role.definition_update.name}"
  policy_arn = "${aws_iam_policy.definition_update.arn}"
}

resource "aws_lambda_function" "definition_update" {
  filename      = "${path.module}/files/lambda.zip"
  function_name = "${module.default_label.id}-definition-update"
  role          = "${aws_iam_role.definition_update.arn}"
  handler       = "update.lambda_handler"

  # source_code_hash = "${filebase64sha256("${path.module}/files/lambda.zip")}"
  runtime                        = "python2.7"
  timeout                        = "${var.definitions_timeout}"
  memory_size                    = "${var.definitions_memory_size}"
  reserved_concurrent_executions = "${var.definitions_reserved_concurrent_executions}"

  environment {
    variables = {
      AV_DEFINITION_S3_BUCKET = "${aws_s3_bucket.definitions.id}"
    }
  }

  depends_on = ["null_resource.lambda"]

  tags = "${module.default_label.tags}"
}

resource "aws_cloudwatch_event_rule" "definition_update" {
  name                = "${module.default_label.id}-definition-update"
  description         = "Update clamav definitions every ${var.update_frequency}"
  schedule_expression = "rate(${var.update_frequency})"
}

resource "aws_cloudwatch_event_target" "definition_update" {
  rule = "${aws_cloudwatch_event_rule.definition_update.name}"
  arn  = "${aws_lambda_function.definition_update.arn}"
}

resource "aws_lambda_permission" "definition_update" {
  # statement_id = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.definition_update.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.definition_update.arn}"
}

resource "aws_iam_role" "scanner" {
  name = "${module.default_label.id}-scanner"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "scanner" {
  name        = "${module.default_label.id}-scanner"
  path        = "/"
  description = "IAM policy for clamav scanner"

  policy = <<POLICY
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
         ],
         "Resource":"*"
      },
      {
         "Action":[
            "s3:*"
         ],
         "Effect":"Allow",
         "Resource":"*"
      }
   ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "scanner" {
  role       = "${aws_iam_role.scanner.name}"
  policy_arn = "${aws_iam_policy.scanner.arn}"
}

resource "aws_lambda_function" "scanner" {
  filename      = "${path.module}/files/lambda.zip"
  function_name = "${module.default_label.id}-scanner"
  role          = "${aws_iam_role.scanner.arn}"
  handler       = "scan.lambda_handler"

  # source_code_hash = "${filebase64sha256("${path.module}/files/lambda.zip")}"
  runtime                        = "python2.7"
  timeout                        = "${var.timeout}"
  memory_size                    = "${var.memory_size}"
  reserved_concurrent_executions = "${var.reserved_concurrent_executions}"

  environment {
    variables = {
      AV_DEFINITION_S3_BUCKET = "${aws_s3_bucket.definitions.id}"
    }
  }

  depends_on = ["null_resource.lambda"]

  tags = "${module.default_label.tags}"
}

resource "aws_s3_bucket" "default" {
  bucket        = "${module.default_label.id}"
  acl           = "${var.acl}"
  region        = "${var.region}"
  force_destroy = "${var.force_destroy}"
  policy        = "${var.policy}"

  versioning {
    enabled = "${var.versioning_enabled}"
  }

  lifecycle_rule {
    id      = "${module.default_label.id}"
    enabled = "${var.lifecycle_rule_enabled}"

    prefix = "${var.lifecycle_prefix}"
    tags   = "${var.lifecycle_tags}"

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

  tags = "${module.default_label.tags}"
}

resource "aws_lambda_permission" "allow_terraform_bucket" {
  # statement_id = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.scanner.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.default.arn}"
}

resource "aws_s3_bucket_notification" "bucket_terraform_notification" {
  bucket = "${aws_s3_bucket.default.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.scanner.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}
