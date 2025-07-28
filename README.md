# Kubernetes

- [1. Usage](#1-usage)
  - [1.1. Details](#11-details)
  - [1.2. Prerequisites](#12-prerequisites)
  - [1.3. Task Runner](#13-task-runner)

## 1. Usage

### 1.1. Details

### 1.2. Prerequisites

### 1.3. Task Runner

- [Makefile](Makefile)
  > Refer to the Makefile as the Task Runner file.

  > [!NOTE]
  > Run the `make help` command in the terminal to list the tasks used for the project.

  ```plaintext
  $ make help

  Task Runner
          A collection of tasks used in the current project.

  Usage
          make <task>

          bootstrap                       Initialize a software development workspace with requisites
          setup                           Install and configure all dependencies essential for development
          teardown                        Remove development artifacts and restore the host to its pre-setup state
          k8s-setup                       Set up the development environment using Docker Compose
          k8s-teardown                    Tear down the development environment using Docker Compose
          k8s-deploy-dependency-track     Deploy Kubernetes manifests for Dependency-Track
          k8s-destroy-dependency-track    Destroy Kubernetes manifests for Dependency-Track
          k8s-render-manifests            Render all Kubernetes manifests
          k8s-monitor-status              Monitor the status of all Kubernetes resources
          helm-vendor-charts              Vendor all Helm charts
          helm-render-charts              Render all Helm charts
  ```
