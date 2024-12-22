terraform {

  cloud {

    # The name of the organization that manages the Terraform workspace,
    # typically used to group and organize resources.
    organization = "rblessings"

    # The name of the Terraform workspace, which helps manage different
    # environments or configurations (e.g., dev, prod, etc.) within the same project.
    workspaces {
      name = "dev"
    }
  }
}