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

          bootstrap             Initialize a software development workspace with requisites
          setup                 Install and configure all dependencies essential for development
          teardown              Remove development artifacts and restore the host to its pre-setup state
          k8s-setup             Set up the development environment using Docker Compose
          k8s-teardown          Tear down the development environment using Docker Compose
          k8s-list-service      List all services
          k8s-list-namespace    List all namespaces
          k8s-list-pod          List all pods
          k8s-list-status       List all status
          helm-pull             Vendor Helm chart for Dependency-Track
  ```
