terraform {
  backend "pg" {}
}

module "github-runner" {
  source                   = "./github-runner"
  github_token             = var.github_token
  github_runner_repository = "https://github.com/echoes341/workflows"
  ip                       = "192.168.1.109"
}

module "k3s-node-1" {
  source = "./k3s-node"
  ip     = "192.168.1.110"
  name   = "k3s-node-1"
}
