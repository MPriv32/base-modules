terraform {
  backend "s3" {
    bucket       = "org-tf-state--732ef4af"
    region       = "us-west-2"
    profile      = "oddball"
    key          = "prod/ecs.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}