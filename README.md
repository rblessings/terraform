# Terraform - Advanced Features and Best Practices

---

The project being deployed to the Kubernetes cluster is located in my
repository: [https://github.com/rblessings/urlradar](https://github.com/rblessings/urlradar).

**For a detailed understanding of the project's direction and planned features, please refer to the open issues.**


---

This repository contains a Terraform project where I am experimenting with advanced features, best practices, and
setting up a GitHub CI/CD pipeline using GitHub Actions. The goal is to create an infrastructure-as-code (IaC) solution
that adheres to the latest standards in Terraform and integrates seamlessly with CI/CD workflows. Additionally, the
project includes comprehensive monitoring of Kubernetes clusters using Prometheus and Grafana, providing real-time
observability, metrics collection, and visualization, ensuring the scalability and reliability of cloud-native
infrastructures.

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

### Running Terraform

```bash
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
terraform destroy -var-file="environments/dev.tfvars"
```

### Import Kubernetes Cluster Dashboard

To start monitoring your Kubernetes cluster, you can import a pre-built Kubernetes cluster dashboard in Grafana. This
will allow you to visualize and monitor the health and performance of your Kubernetes environment with key metrics such
as pod status, node resource usage, and cluster health.

#### **Steps to Import the Kubernetes Cluster Dashboard**:

1. **Access Grafana UI**:
   Open your web browser and navigate to Grafana's URL (e.g., `http://<node-ip>:32000`).

2. **Login to Grafana**:
   Use the credentials you set up in the Terraform configuration (default: `admin`/`admin`).

3. **Import Dashboard**:

- In the left sidebar, click on the **+** icon.
- Select **Import**.
- In the **Import via grafana.com** field, enter **Dashboard ID `315`** (which is a popular Kubernetes cluster
  monitoring dashboard).
- Click **Load**.

4. **Configure Data Source**:

- Once the dashboard is loaded, select **Prometheus** as the data source.
- Click **Import** to finish the setup.

The dashboard is now available, and you can start monitoring your Kubernetes cluster metrics.

### Explore Kubernetes Cluster Metrics

After importing the Kubernetes dashboard into Grafana, you can monitor critical metrics for cluster health and
performance.

#### Key Dashboard Metrics:

1. **Cluster Health**:
    - **API Server**: Request rate, error rate, latency.
    - **Scheduler**: Scheduling latency, unscheduled pods.

2. **Node Metrics**:
    - **CPU Usage**: Per node and overall consumption.
    - **Memory Usage**: Per node and total utilization.
    - **Disk I/O**: Read/write operations per second.

3. **Pod Health and Status**:
    - **Pod Status**: Number of pods in various states.
    - **Pod CPU and Memory Usage**: Resource consumption per pod.

4. **Network Metrics**:
    - **Network Throughput**: Traffic per pod and node.
    - **Network Latency**: Latency between services.

5. **Resource Requests and Limits**:
    - **CPU Requests**: Allocated CPU for pods.
    - **Memory Requests**: Allocated memory for pods.

---

## License

This project is open-source software released under the [MIT License](https://opensource.org/license/MIT).
