# Terraform - Advanced Features and Best Practices

This repository contains a Terraform project where I am experimenting with advanced features, best practices, and
setting up a GitHub CI/CD pipeline using GitHub Actions. The goal is to create an infrastructure-as-code (IaC) solution
that adheres to the latest standards in Terraform and integrates seamlessly with CI/CD workflows.

[![Terraform Validator](https://github.com/rblessings/terraform/actions/workflows/terraform_validation.yml/badge.svg)](https://github.com/rblessings/terraform/actions/workflows/terraform_validation.yml)
[![Dependabot Updates](https://github.com/rblessings/terraform/actions/workflows/dependabot/dependabot-updates/badge.svg)](https://github.com/rblessings/terraform/actions/workflows/dependabot/dependabot-updates)

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
    - [Setup](#setup)
    - [Running Terraform](#running-terraform)
    - [GitHub Actions Pipeline](#github-actions-pipeline)
- [License](#license)

## Overview

This project demonstrates how to build, deploy, and manage infrastructure with Terraform, showcasing the following:

- Usage of advanced Terraform features (modules, workspaces, remote backends, etc.)
- Terraform best practices (code structure, variable usage, state management)
- Automated deployment using GitHub Actions
- Versioning and code review workflows

## Features

- **Terraform Modules**: Encapsulation of reusable code with Terraform modules.
- **Remote Backend**: Storing Terraform state in a remote backend (e.g., S3, Azure Blob Storage, or Terraform Cloud).
- **Workspaces**: Managing multiple environments (e.g., development, staging, production).
- **CI/CD Pipeline**: Continuous integration and continuous deployment with GitHub Actions.
- **Automated Testing**: Integration of automated testing tools like `terraform validate` and `terraform plan`.

## Prerequisites

Before using this repository, ensure that the following software is installed:

- [Terraform](https://www.terraform.io/downloads.html) (version >= 1.x)
- [Git](https://git-scm.com/)
- [GitHub Account](https://github.com)
- Access to a Kubernetes cluster (On-prem, AWS, Azure, GCP, etc.) with appropriate credentials.

## Usage

### Running Terraform

```bash
terraform plan
terraform apply
terraform destroy
```

## License

This project is open-source software released under the [MIT License](https://opensource.org/license/MIT).
