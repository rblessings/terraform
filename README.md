# Terraform - Advanced Features and Best Practices

---

**For a detailed understanding of the project's direction and planned features, please refer to the open issues.**

---

This repository showcases a **Terraform** project focused on advanced features, best practices, and a CI/CD pipeline
based
on GitHub Actions. The goal is to implement a modern Infrastructure as Code (IaC) solution that integrates seamlessly
with CI/CD workflows and GitOps practices, while ensuring scalability, reliability, and observability for a cloud-native
application.

In this project, the application is [UrlRadar](https://github.com/rblessings/urlradar), a URL redirection service. The
infrastructure is built on **Kubernetes** and
includes **Prometheus** and **Grafana** for metrics collection and visualization. These tools provide insights into both
the
performance of the urlradar application and the underlying Kubernetes cluster where the project is deployed.

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
- [HCP Terraform Account](https://app.terraform.io)
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

```bash
# Plan the deployment
terraform plan -var-file="environments/dev.tfvars"

# Apply the deployment
terraform apply -var-file="environments/dev.tfvars"

# Destroy the deployment (if needed)
terraform destroy -var-file="environments/dev.tfvars"
```

### Import Dashboard for Monitoring

To monitor the UrlRadar application and your Kubernetes cluster, you can import pre-built dashboards into Grafana. This
enables you to visualize key metrics related to application health, performance, and resource usage.

#### Steps to Import a Dashboard:

1. **Access Grafana UI**:  
   Open your web browser and navigate to Grafana's URL (e.g., `http://<node-ip>:32000`).

2. **Login to Grafana**:  
   Use the credentials set up in your environment (default: `admin`/`admin`).

3. **Import Dashboard**:
    - In the left sidebar, click the **+** icon.
    - Select **Import**.
    - In the **Import via grafana.com** field, enter the respective Dashboard ID:
        - For Kubernetes cluster monitoring, use **Dashboard ID `315`**.
        - For Spring Boot 3 application monitoring, use **Dashboard ID `19004`**.
    - Click **Load**.

4. **Configure Data Source**:
    - After the dashboard loads, select the appropriate **Prometheus** data source.
    - Click **Import** to finish the setup.

The dashboard is now available, and you can start monitoring your metrics.

### Kubernetes Monitoring Queries

1. **Node CPU Utilization**
    - **Query**:
      ```prometheus
      sum by (node) (rate(container_cpu_usage_seconds_total{container="", image!="", job="kubelet"}[5m])) / sum by (node) (kube_node_status_capacity_cpu_cores{node=~".+"})
      ```
    - **Description**:  
      Shows the CPU utilization as a percentage across nodes, helping identify resource bottlenecks.

2. **Pod Restart Frequency**
    - **Query**:
      ```prometheus
      increase(kube_pod_container_status_restarts_total[5m])
      ```
    - **Description**:  
      Tracks the number of container restarts, indicating potential reliability issues.

### Spring Boot Monitoring Queries

1. **HTTP Response Time**
    - **Query**:
      ```prometheus
      avg by (status) (rate(http_server_requests_seconds_sum{application="UrlRadar", status=~"2.*|5.*"}[1m])) / avg by (status) (rate(http_server_requests_seconds_count{application="UrlRadar", status=~"2.*|5.*"}[1m]))
      ```
    - **Description**:  
      Calculates the average response time for HTTP requests, showing both successful and failed requests.

2. **JVM Heap Memory Usage**
    - **Query**:
      ```prometheus
      (jvm_memory_bytes_used{application="UrlRadar", area="heap"} / jvm_memory_bytes_max{application="UrlRadar", area="heap"}) * 100
      ```
    - **Description**:  
      Monitors heap memory usage as a percentage of total capacity, helping detect memory pressure.

### Summary

- **Kubernetes**: Focus on node CPU utilization and pod restarts for cluster stability.
- **Spring Boot**: Monitor HTTP response times and JVM memory usage for application health.

These are just a few of the many wonderful queries you can perform to gain deeper insights into your systems!

---

## License

This project is open-source software released under the [MIT License](https://opensource.org/license/MIT).
