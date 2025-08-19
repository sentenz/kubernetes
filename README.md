# Kubernetes

- [1. Usage](#1-usage)
  - [1.1. Details](#11-details)
    - [1.1.1. Order of Precedence](#111-order-of-precedence)
    - [1.1.2. Database URL Naming Convention](#112-database-url-naming-convention)
  - [1.2. Prerequisites](#12-prerequisites)
  - [1.3. Task Runner](#13-task-runner)

## 1. Usage

### 1.1. Details

#### 1.1.1. Order of Precedence

Kustomize assembles and applies configuration in a defined hierarchy to ensure predictable overrides, lowest to highest:

- Base Resources
  > Loaded first from `resources:` in base kustomizations.

- Generators
  > ConfigMap- and Secret-generators (`configMapGenerator:`, `secretGenerator:`) produce new objects after base resources.

- Base Patches
  > Any `patches:` declared within base kustomizations are applied.

- Component Patches & Transformers
  > Imported via `components:`, these patches and transformers run next.

- Overlay Patches & Transformers
  > Specified in overlays (`patches:`, `transformers:`), they override earlier modifications.

- Overlay Direct Fields
  > Top-level settings in the overlay—such as `namespace:`, `namePrefix:`, `commonLabels:`, `images:`—are applied last, possessing the highest precedence.

#### 1.1.2. Database URL Naming Convention

All PostgreSQL service endpoints are referenced using the fully qualified Kubernetes service DNS format:

```plaintext
postgresql.<namespace>.svc.cluster.local
```

For in-cluster applications, the recommended JDBC database URL is:

```plaintext
jdbc:postgresql://postgresql.<namespace>.svc.cluster.local:5432/<database>?sslmode=disable
```

Replace `<namespace>` and `<database>` with the actual PostgreSQL namespace and database name. This convention ensures reliable service discovery and avoids ambiguity across different environments.

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
