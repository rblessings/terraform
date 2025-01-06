# Terraform - Advanced Features and Best Practices

---

The project being deployed to the Kubernetes cluster is located in my
repository: [https://github.com/rblessings/urlradar](https://github.com/rblessings/urlradar).

**For a detailed understanding of the project's direction and planned features, please refer to the open issues.**


---

This repository showcases a Terraform project focused on advanced features, best practices, and a GitHub Actions-based
CI/CD pipeline. The objective is to implement a modern IaC solution that aligns with Terraform's latest standards and
integrates with CI/CD workflows. It also includes comprehensive Kubernetes monitoring with Prometheus and Grafana for
real-time observability, metrics collection, and visualization, ensuring cloud-native infrastructure scalability and
reliability.

[![Terraform Validation](https://github.com/rblessings/terraform/actions/workflows/terraform.yml/badge.svg)](https://github.com/rblessings/terraform/actions/workflows/terraform.yml)
[![Dependabot Updates](https://github.com/rblessings/terraform/actions/workflows/dependabot/dependabot-updates/badge.svg)](https://github.com/rblessings/terraform/actions/workflows/dependabot/dependabot-updates)

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [License](#license)

## Overview

This project demonstrates how to build, deploy, and manage infrastructure with Terraform, showcasing the following:

- Usage of advanced Terraform features (modules, workspaces, remote backends, etc.)
- Terraform best practices (code structure, variable usage, state management)
- Automated deployment using GitHub Actions
- Versioning and code review workflows
- Kubernetes Cluster Monitoring and Observability

## Features

- **Terraform Modules**: Encapsulation of reusable code with Terraform modules.
- **Remote Backend**: Storing Terraform state in a remote backend (e.g., S3, Azure Blob Storage, or Terraform Cloud).
- **Workspaces**: Managing multiple environments (e.g., development, staging, production).
- **CI/CD Pipeline**: Continuous integration and continuous deployment with GitHub Actions.
- **Automated Testing**: Integration of automated testing tools like `terraform validate` and `terraform plan`.
- **Kubernetes Cluster Monitoring**: Setup of Prometheus for metrics collection and Grafana for visualizing Kubernetes
  cluster health, performance, and resource utilization.
- **Observability**: Integration of Prometheus and Grafana provides actionable insights, alerting, and visualization for
  seamless monitoring and troubleshooting of cloud-native environments.

## Prerequisites

Before using this repository, ensure that the following software is installed:

- [Terraform](https://www.terraform.io/downloads.html) (1.10.3 or any newer version)
- [Git](https://git-scm.com/)
- [GitHub Account](https://github.com)
- Access to a Kubernetes cluster (on-premises, AWS, Azure, GCP, etc.) with the appropriate credentials.

## Usage

### Kubernetes Persistent Volume Setup

**Note**: `HostPath` volumes are used for persistent storage in the current development environment. Ensure the
specified paths exist on **all worker nodes** before deployment. This setup is not scalable or highly available. Refer
to [issue #36](https://github.com/rblessings/terraform/issues/36) for future updates.

#### Setup Instructions

```bash
# 1. Transfer the script to each worker node, or manually copy and paste its contents.
scp setup_directories.sh <username>@<node_ip>:/path/to/destination

# 2. Make the script executable
chmod +x setup_directories.sh

# 3. Run the script to create directories
sudo ./setup_directories.sh

# 4. Verify the directories
ls -lh /mnt/data/
```

---

### Deploying the Application to a Kubernetes Cluster

### Deploying the Application to a Kubernetes Cluster

```bash
# Plan the deployment
terraform plan -var-file="environments/dev.tfvars"

# Apply the deployment
terraform apply -var-file="environments/dev.tfvars"

# Destroy the deployment (if needed)
terraform destroy -var-file="environments/dev.tfvars"
```

### Import Kubernetes Cluster Dashboard

To monitor your Kubernetes cluster, you can import a pre-built dashboard into Grafana. This allows you to visualize key
metrics such as pod status, node resource usage, and overall cluster health.

#### Steps to Import the Kubernetes Cluster Dashboard:

1. **Access Grafana UI**:  
   Open your web browser and navigate to Grafana's URL (e.g., `http://<node-ip>:32000`).

2. **Login to Grafana**:  
   Use the credentials set up in the Terraform configuration (default: `admin`/`admin`).

3. **Import Dashboard**:
    - In the left sidebar, click the **+** icon.
    - Select **Import**.
    - In the **Import via grafana.com** field, enter **Dashboard ID `315`** (a popular Kubernetes cluster monitoring
      dashboard).
    - Click **Load**.

4. **Configure Data Source**:
    - After the dashboard loads, select **Prometheus** as the data source.
    - Click **Import** to finish the setup.

The dashboard is now available, and you can start monitoring your Kubernetes cluster metrics.

---

## License

This project is open-source software released under the [MIT License](https://opensource.org/license/MIT).
