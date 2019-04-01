output "definitions_bucket_domain_name" {
  value       = "${join("", aws_s3_bucket.definitions.*.bucket_domain_name)}"
  description = "FQDN of bucket"
}

output "definitions_bucket_id" {
  value       = "${join("", aws_s3_bucket.definitions.*.id)}"
  description = "Bucket Name (aka ID)"
}

output "definitions_bucket_arn" {
  value       = "${join("", aws_s3_bucket.definitions.*.arn)}"
  description = "Bucket ARN"
}

output "bucket_domain_name" {
  value       = "${join("", aws_s3_bucket.default.*.bucket_domain_name)}"
  description = "FQDN of bucket"
}

output "bucket_id" {
  value       = "${join("", aws_s3_bucket.default.*.id)}"
  description = "Bucket Name (aka ID)"
}

output "bucket_arn" {
  value       = "${join("", aws_s3_bucket.default.*.arn)}"
  description = "Bucket ARN"
}

output "lambda_scanner_arn" {
  value       = "${aws_lambda_function.scanner.arn}"
  description = "scanner lambda function ARN"
}

output "lambda_scanner_name" {
  value       = "${aws_lambda_function.scanner.arn}"
  description = "${module.default_label.id}-scanner"
}

output "lambda_definition_update_arn" {
  value       = "${aws_lambda_function.definition_update.arn}"
  description = "scanner lambda function ARN"
}

output "lambda_definition_update_name" {
  value       = "${aws_lambda_function.definition_update.arn}"
  description = "${module.default_label.id}-definition-update"
}