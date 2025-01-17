terraform {

  cloud {

    # The name of the organization managing the Terraform workspace,
    # used to group and organize resources.
    organization = "rblessings"

    # The name of the workspace, used to manage different
    # environments or configurations (e.g., dev, prod) within the same project.
    workspaces {
      name = "dev"
    }
  }
}