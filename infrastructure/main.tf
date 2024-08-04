terraform {
  backend "pg" {}
}

module "github-runner" {
  source                   = "./github-runner"
  github_token             = var.github_token
  github_runner_repository = "https://github.com/echoes341/workflows"
  ip                       = "192.168.1.109"
}

module "scanservjs" {
  source   = "./scanservjs"
  ip       = "192.168.1.123"
  password = var.scanservjs_password
  name     = "scanservjs"
}
