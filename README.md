# Terraform - Advanced Features and Best Practices

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

- [Terraform](https://www.terraform.io/downloads.html) (version >= 1.x)
- [Git](https://git-scm.com/)
- [GitHub Account](https://github.com)
- Access to a Kubernetes cluster (On-prem, AWS, Azure, GCP, etc.) with appropriate credentials.

## Usage

### Running Terraform

```bash
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
terraform destroy -var-file="environments/dev.tfvars"
```

## **Import Kubernetes Cluster Dashboard**

To start monitoring your Kubernetes cluster, you can import a pre-built Kubernetes cluster dashboard in Grafana. This
will allow you to visualize and monitor the health and performance of your Kubernetes environment with key metrics such
as pod status, node resource usage, and cluster health.

### **Steps to Import the Kubernetes Cluster Dashboard**:

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

---

## **Explore the Kubernetes Cluster Metrics**

After importing the Kubernetes dashboard into Grafana, you can begin exploring critical Kubernetes metrics that provide
insights into the health and performance of your cluster. As a Principal Cloud DevOps Engineer, this setup enables a
comprehensive and proactive approach to monitoring cloud-native environments.

### **Key Metrics You Might See on the Dashboard**:

1. **Cluster Health**:

- **API Server**: Metrics such as request rate, error rate, and latency to monitor the health of the Kubernetes API
  server.
- **Scheduler**: Metrics related to pod scheduling, including scheduling latency and number of unscheduled pods.

2. **Node Metrics**:

- **CPU Usage**: Percentage of CPU usage per node and overall CPU resource consumption.
- **Memory Usage**: Memory usage on each node and total memory utilization.
- **Disk I/O**: Read/write operations per second on nodes' disks.

3. **Pod Health and Status**:

- **Pod Status**: Display the number of pods in different states (e.g., Running, Pending, Failed).
- **Pod CPU and Memory Usage**: Breakdown of CPU and memory usage per pod to track resource consumption.

4. **Network Metrics**:

- **Network Throughput**: Monitoring of network traffic for each pod and node (e.g., bytes sent/received).
- **Network Latency**: Tracking latency between services to detect any communication bottlenecks.

5. **Resource Requests and Limits**:

- **CPU Requests**: The amount of CPU allocated for pods across the cluster.
- **Memory Requests**: The amount of memory allocated for pods across the cluster.

---

## Use Cases

### 1. Multi-Environment Deployment Pipeline

**Scenario**: Efficiently manage multiple environments (development, staging, production) with minimal risk of
configuration drift.

**Solution**: Utilize **Terraform workspaces** for environment isolation and **remote backends** (e.g., S3) for secure
state management. Ensure consistency and scalability in deployments via **GitHub Actions** for automated CI/CD
pipelines.

**Impact**: Streamlines deployment across environments, reducing human error and ensuring high-quality, reliable
releases.

---

### 2. Automated Infrastructure Deployment and Scaling

**Scenario**: Automate infrastructure provisioning to support dynamic scaling and reduce manual intervention.

**Solution**: Leverage **Terraform modules** for reusable infrastructure components and integrate **GitHub Actions** for
CI/CD automation. Automate resource creation and updates with minimal downtime.

**Impact**: Accelerates delivery, ensures repeatable infrastructure setups, and improves efficiency through automated,
error-free provisioning.

---

### 3. Infrastructure Governance and Compliance

**Scenario**: Enforce compliance and governance policies across infrastructure deployments in regulated industries.

**Solution**: Use **remote backends** and **workspaces** to maintain versioned, auditable infrastructure. Integrate
automated validation (e.g., `terraform validate`) and enforce **best practices** with code review workflows in **GitHub
Actions**.

**Impact**: Ensures infrastructure meets compliance standards, reduces audit complexity, and minimizes the risk of
non-compliance.

---

### 4. Cloud Cost Optimization

**Scenario**: Optimize cloud infrastructure costs by managing resources efficiently and scaling dynamically.

**Solution**: Implement **Terraform modules** for scalable, reusable infrastructure. Automate resource provisioning and
scaling based on demand using **GitHub Actions** to trigger changes without over-provisioning.

**Impact**: Reduces cloud spend by eliminating underutilized resources and ensuring efficient, on-demand provisioning.

---

### 5. Disaster Recovery and Infrastructure Resilience

**Scenario**: Ensure rapid recovery and high availability of infrastructure in case of failure.

**Solution**: Store infrastructure state in **remote backends** for fast recovery and leverage **Terraform's IaC
approach** for consistent, reproducible setups. Implement automated restoration using **CI/CD pipelines**.

**Impact**: Minimizes downtime, enhances system reliability, and accelerates disaster recovery processes, ensuring
business continuity.

## License

This project is open-source software released under the [MIT License](https://opensource.org/license/MIT).
