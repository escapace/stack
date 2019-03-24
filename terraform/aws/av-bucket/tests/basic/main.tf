module "antivirus" {
  source    = "../.."
  name      = "escapace-stack-av"
  stage     = "test"
  namespace = "example"
}
