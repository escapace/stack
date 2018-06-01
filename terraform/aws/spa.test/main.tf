provider "aws" {}

module "spa" {
  source    = "../spa"
  name      = "spa"
  stage     = "testing"
  namespace = "travis"
  aliases   = ["a4hrqs0dxf.com"]
}
