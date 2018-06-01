provider "aws" {}

module "log_storage" {
  source        = "../log-storage"
  name          = "log-storage"
  stage         = "testing"
  namespace     = "travis"
  force_destroy = true
}
