terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "rblessings-cloud-devops"

    workspaces {
      name = "terraform-project-workspace"
    }
  }
}