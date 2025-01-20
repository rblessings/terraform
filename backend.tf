terraform {

  cloud {

    # Organization for grouping and managing Terraform workspaces and resources.
    organization = "rblessings"

    # Workspace for isolating environments (e.g., dev, prod) and managing state.
    workspaces {
      name = "dev"
    }
  }
}
