provider "aws" {}

resource "aws_kms_key" "test" {
  description = "SPA"
}

module "spa" {
  source                     = "../spa"
  name                       = "spa"
  stage                      = "testing"
  namespace                  = "travis"
  aliases                    = ["null.escapace.com"]
  origin_force_destroy       = true
  github_repo                = "empty-repository"
  github_username            = "escapace"
  github_poll                = false
  log_sse_algorithm          = "aws:kms"
  log_kms_master_key_id      = "${aws_kms_key.test.arn}"
  artifact_sse_algorithm     = "aws:kms"
  artifact_kms_master_key_id = "${aws_kms_key.test.arn}"
  log_sse_algorithm          = "aws:kms"
  log_kms_master_key_id      = "${aws_kms_key.test.arn}"
}
