terraform {
  backend "pg" {}
}

module "github-runner" {
  source                   = "./github-runner"
  github_token             = var.github_token
  github_runner_repository = "https://github.com/echoes341/workflows"
  ip                       = var.ip_github_runner
}
