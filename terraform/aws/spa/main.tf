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

variable "acm_certificate_arn" {
  description = "Existing ACM Certificate ARN"
  default     = ""
}

variable "aliases" {
  type        = "list"
  description = "List of FQDN's - Used to set the Alternate Domain Names (CNAMEs) setting on Cloudfront"
  default     = []
}

variable "origin_bucket" {
  default = ""
}

variable "origin_path" {
  # http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-values-specify.html#DownloadDistValuesOriginPath
  description = "(Optional) - An optional element that causes CloudFront to request your content from a directory in your Amazon S3 bucket or your custom origin. It must begin with a /. Do not add a / at the end of the path."
  default     = ""
}

variable "origin_force_destroy" {
  default = "false"
}

variable "artifact_force_destroy" {
  default = "true"
}

variable "log_force_destroy" {
  default = "true"
}

variable "bucket_domain_format" {
  default = "%s.s3.amazonaws.com"
}

variable "compress" {
  default = "true"
}

variable "enabled" {
  default = "true"
}

variable "is_ipv6_enabled" {
  default = "true"
}

variable "default_root_object" {
  default = "index.html"
}

variable "response_page_path" {
  default = "/index.html"
}

variable "comment" {
  default = "Managed by Terraform"
}

variable "log_include_cookies" {
  default = "false"
}

variable "log_prefix" {
  default = ""
}

variable "log_standard_transition_days" {
  description = "Number of days to persist in the standard storage tier before moving to the glacier tier"
  default     = "30"
}

variable "log_glacier_transition_days" {
  description = "Number of days after which to move the data to the glacier storage tier"
  default     = "60"
}

variable "log_expiration_days" {
  description = "Number of days after which to expunge the objects"
  default     = "90"
}

variable "forward_query_string" {
  default = "false"
}

variable "cors_allowed_headers" {
  type    = "list"
  default = ["*"]
}

variable "cors_allowed_methods" {
  type    = "list"
  default = ["GET"]
}

variable "cors_allowed_origins" {
  type    = "list"
  default = []
}

variable "cors_expose_headers" {
  type    = "list"
  default = ["ETag"]
}

variable "cors_max_age_seconds" {
  default = "3600"
}

variable "forward_cookies" {
  default = "none"
}

variable "price_class" {
  default = "PriceClass_100"
}

variable "viewer_protocol_policy" {
  description = "allow-all, redirect-to-https"
  default     = "redirect-to-https"
}

variable "allowed_methods" {
  type    = "list"
  default = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
}

variable "cached_methods" {
  type    = "list"
  default = ["GET", "HEAD"]
}

variable "default_ttl" {
  default = "60"
}

variable "min_ttl" {
  default = "0"
}

variable "max_ttl" {
  default = "31536000"
}

variable "geo_restriction_type" {
  # e.g. "whitelist"
  default = "none"
}

variable "geo_restriction_locations" {
  type = "list"

  # e.g. ["US", "CA", "GB", "DE"]
  default = []
}

/* variable "parent_zone_id" { */
/*   default = "" */
/* } */
/*  */
/* variable "parent_zone_name" { */
/*   default = "" */
/* } */

/* variable "null" { */
/*   description = "an empty string" */
/*   default     = "" */
/* } */

// Codebuild

variable "github_username" {
  type = "string"
}

variable "github_repo" {
  type = "string"
}

variable "github_branch" {
  default = "master"
}

variable "github_poll" {
  default = true
}

variable "artifact_standard_transition_days" {
  description = "Number of days to persist in the standard storage tier before moving to the infrequent access tier"
  default     = "60"
}

variable "artifact_glacier_transition_days" {
  description = "Number of days after which to move the data to the glacier storage tier"
  default     = "90"
}

variable "artifact_expiration_days" {
  description = "Number of days after which to expunge the objects"
  default     = "120"
}

variable "codebuild_timeout" {
  description = "How long in minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed."
  default     = "60"
}

// Encryption

variable "log_sse_algorithm" {
  description = "The server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  default     = "AES256"
}

variable "log_kms_master_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms"
  default     = ""
}

variable "origin_sse_algorithm" {
  description = "The server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  default     = "AES256"
}

variable "origin_kms_master_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms"
  default     = ""
}

variable "artifact_sse_algorithm" {
  description = "The server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  default     = "AES256"
}

variable "artifact_kms_master_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms"
  default     = ""
}


module "label" {
  source     = "../../generic/null-label"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
}

resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "${module.label.id}"
}

data "aws_iam_policy_document" "origin" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::$${bucket_name}$${origin_path}*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.default.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::$${bucket_name}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.default.iam_arn}"]
    }
  }
}

data "template_file" "default" {
  template = "${data.aws_iam_policy_document.origin.json}"

  vars {
    origin_path = "${coalesce(var.origin_path, "/")}"
    bucket_name = "${null_resource.default.triggers.bucket}"
  }
}

resource "aws_s3_bucket_policy" "default" {
  bucket = "${null_resource.default.triggers.bucket}"
  policy = "${data.template_file.default.rendered}"
}

resource "aws_s3_bucket" "origin" {
  count         = "${signum(length(var.origin_bucket)) == 1 ? 0 : 1}"
  bucket        = "${module.label.id}"
  acl           = "private"
  tags          = "${module.label.tags}"
  force_destroy = "${var.origin_force_destroy}"

  cors_rule {
    allowed_headers = "${var.cors_allowed_headers}"
    allowed_methods = "${var.cors_allowed_methods}"
    allowed_origins = "${sort(distinct(compact(concat(var.cors_allowed_origins, var.aliases))))}"
    expose_headers  = "${var.cors_expose_headers}"
    max_age_seconds = "${var.cors_max_age_seconds}"
  }

  # https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html
  # https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#enable-default-server-side-encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "${var.artifact_sse_algorithm}"
        kms_master_key_id = "${var.artifact_kms_master_key_id}"
      }
    }
  }
}

module "logs" {
  source                   = "../log-storage"
  namespace                = "${var.namespace}"
  stage                    = "${var.stage}"
  name                     = "${var.name}"
  delimiter                = "${var.delimiter}"
  attributes               = "${var.attributes}"
  tags                     = "${var.tags}"
  prefix                   = "${var.log_prefix}"
  standard_transition_days = "${var.log_standard_transition_days}"
  glacier_transition_days  = "${var.log_glacier_transition_days}"
  expiration_days          = "${var.log_expiration_days}"
  force_destroy            = "${var.log_force_destroy}"
  sse_algorithm            = "${var.log_sse_algorithm}"
  kms_master_key_id        = "${var.log_kms_master_key_id}"
}

resource "null_resource" "default" {
  triggers {
    bucket             = "${element(compact(concat(list(var.origin_bucket), aws_s3_bucket.origin.*.bucket)), 0)}"
    bucket_domain_name = "${format(var.bucket_domain_format, element(compact(concat(list(var.origin_bucket), aws_s3_bucket.origin.*.bucket)), 0))}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudfront_distribution" "default" {
  enabled             = "${var.enabled}"
  is_ipv6_enabled     = "${var.is_ipv6_enabled}"
  comment             = "${var.comment}"
  default_root_object = "${var.default_root_object}"
  price_class         = "${var.price_class}"
  depends_on          = ["aws_s3_bucket.origin"]

  logging_config = {
    include_cookies = "${var.log_include_cookies}"
    bucket          = "${module.logs.bucket_domain_name}"
    prefix          = "${var.log_prefix}"
  }

  aliases = ["${var.aliases}"]

  origin {
    domain_name = "${null_resource.default.triggers.bucket_domain_name}"
    origin_id   = "${module.label.id}"
    origin_path = "${var.origin_path}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path}"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = "${var.acm_certificate_arn}"
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1"
    cloudfront_default_certificate = "${var.acm_certificate_arn == "" ? true : false}"
  }

  default_cache_behavior {
    allowed_methods  = "${var.allowed_methods}"
    cached_methods   = "${var.cached_methods}"
    target_origin_id = "${module.label.id}"
    compress         = "${var.compress}"

    forwarded_values {
      query_string = "${var.forward_query_string}"

      cookies {
        forward = "${var.forward_cookies}"
      }
    }

    viewer_protocol_policy = "${var.viewer_protocol_policy}"
    default_ttl            = "${var.default_ttl}"
    min_ttl                = "${var.min_ttl}"
    max_ttl                = "${var.max_ttl}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "${var.geo_restriction_type}"
      locations        = "${var.geo_restriction_locations}"
    }
  }

  custom_error_response {
    error_caching_min_ttl = "${var.default_ttl}"
    error_code            = 404
    response_code         = 200
    response_page_path    = "${var.response_page_path}"
  }

  tags = "${module.label.tags}"
}

// Pipeline

module "codepipeline_label" {
  source     = "../../generic/null-label"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = ["${compact(concat(var.attributes, list("codepipeline")))}"]
  tags       = "${var.tags}"
}

module "codebuild_label" {
  source     = "../../generic/null-label"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = ["${compact(concat(var.attributes, list("codebuild")))}"]
  tags       = "${var.tags}"
}

resource "aws_s3_bucket" "codepipeline" {
  bucket        = "${module.codepipeline_label.id}"
  acl           = "private"
  force_destroy = "${var.artifact_force_destroy}"
  tags          = "${module.codepipeline_label.tags}"

  lifecycle_rule {
    id      = "${module.codepipeline_label.id}"
    enabled = true
    tags    = "${module.codepipeline_label.tags}"

    transition {
      days          = "${var.artifact_standard_transition_days}"
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = "${var.artifact_glacier_transition_days}"
      storage_class = "GLACIER"
    }

    expiration {
      days = "${var.artifact_expiration_days}"
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "${var.origin_sse_algorithm}"
        kms_master_key_id = "${var.origin_kms_master_key_id}"
      }
    }
  }
}

data "aws_iam_policy_document" "codepipeline_assume_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${module.codepipeline_label.id}"
  assume_role_policy = "${data.aws_iam_policy_document.codepipeline_assume_policy.json}"
}

# CodePipeline policy needed to use CodeCommit and CodeBuild
resource "aws_iam_role_policy" "attach_codepipeline_policy" {
  name = "${module.codepipeline_label.id}"
  role = "${aws_iam_role.codepipeline_role.id}"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketVersioning",
                "s3:PutObject"
            ],
            "Resource": [
              "${aws_s3_bucket.codepipeline.arn}",
              "${aws_s3_bucket.codepipeline.arn}/*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

# CodeBuild IAM Permissions
resource "aws_iam_role" "codebuild_assume_role" {
  name = "${module.codebuild_label.id}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${module.codebuild_label.id}"
  role = "${aws_iam_role.codebuild_assume_role.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
       "s3:PutObject",
       "s3:GetObject",
       "s3:GetObjectVersion",
       "s3:GetBucketVersioning"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline.arn}",
        "${aws_s3_bucket.codepipeline.arn}/*"
      ],
      "Effect": "Allow"
    },
    {
      "Action": [
       "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.origin.arn}",
        "${aws_s3_bucket.origin.arn}/*"
      ],
      "Effect": "Allow"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:GetDistribution",
        "cloudfront:GetDistributionConfig",
        "cloudfront:ListDistributions",
        "cloudfront:ListCloudFrontOriginAccessIdentities",
        "cloudfront:CreateInvalidation",
        "cloudfront:GetInvalidation",
        "cloudfront:ListInvalidations"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
        "${aws_codebuild_project.build_project.id}"
      ],
      "Action": [
        "codebuild:*"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    }
  ]
}
POLICY
}

# CodeBuild Section for the Package stage
resource "aws_codebuild_project" "build_project" {
  name          = "${module.codebuild_label.id}"
  description   = "CodeBuild project for ${module.label.id}"
  service_role  = "${aws_iam_role.codebuild_assume_role.arn}"
  build_timeout = "${var.codebuild_timeout}"
  tags          = "${module.codebuild_label.tags}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:8.11.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      "name"  = "AWS_S3_BUCKET"
      "value" = "${null_resource.default.triggers.bucket}"
    }

    environment_variable {
      "name"  = "AWS_CDN_DISTRIBUTION_ID"
      "value" = "${aws_cloudfront_distribution.default.id}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

# Full CodePipeline
resource "aws_codepipeline" "codepipeline" {
  name     = "${module.codepipeline_label.id}"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store = {
    location = "${aws_s3_bucket.codepipeline.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]

      configuration {
        Owner                = "${var.github_username}"
        Repo                 = "${var.github_repo}"
        Branch               = "${var.github_branch}"
        PollForSourceChanges = "${var.github_poll}"
      }
    }
  }

  stage {
    name = "Deployment"

    action {
      name             = "Deployment"
      category         = "Test"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["code"]
      output_artifacts = ["deployed"]
      version          = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.build_project.name}"
      }
    }
  }
}

output "cf_id" {
  value = "${aws_cloudfront_distribution.default.id}"
}

output "cf_arn" {
  value = "${aws_cloudfront_distribution.default.arn}"
}

output "cf_status" {
  value = "${aws_cloudfront_distribution.default.status}"
}

output "cf_domain_name" {
  value = "${aws_cloudfront_distribution.default.domain_name}"
}

output "cf_etag" {
  value = "${aws_cloudfront_distribution.default.etag}"
}

output "cf_hosted_zone_id" {
  value = "${aws_cloudfront_distribution.default.hosted_zone_id}"
}

output "s3_bucket" {
  value = "${null_resource.default.triggers.bucket}"
}

output "s3_bucket_domain_name" {
  value = "${null_resource.default.triggers.bucket_domain_name}"
}
