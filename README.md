# Kubernetes

- [1. Details](#1-details)
  - [1.1. Charts](#11-charts)
  - [1.2. Architecture Diagrams](#12-architecture-diagrams)
  - [1.3. Order of Precedence](#13-order-of-precedence)
  - [1.4. Prerequisites](#14-prerequisites)
- [2. Usage](#2-usage)
  - [2.1. Authentication](#21-authentication)
    - [2.1.1. Kube Config](#211-kube-config)
  - [2.2. Cryptographic](#22-cryptographic)
    - [2.2.1. TLS Certificates and Private Keys](#221-tls-certificates-and-private-keys)
    - [2.2.2. CA-Signed Certificates from CSRs](#222-ca-signed-certificates-from-csrs)
  - [2.3. Secret Manager](#23-secret-manager)
    - [2.3.1. SOPS](#231-sops)
  - [2.4. Task Runner](#24-task-runner)
    - [2.4.1. Makefile](#241-makefile)
- [3. Troubleshoot](#3-troubleshoot)
  - [3.1. TODO](#31-todo)
- [4. References](#4-references)

## 1. Details

### 1.1. Charts

TODO

### 1.2. Architecture Diagrams

```mermaid
flowchart TD
    internet[[Client]]

    subgraph Cloud Provider
        lb[External Load Balancer<br>Ingress Managed]
    end

    internet --> |TLS/HTTPS| lb --> icService

    subgraph Kubernetes Cluster
        direction TB

        subgraph Ingress Control Plane
          ingressResource[Ingress Resource<br>YAML Manifest]
          ingressClass[IngressClass<br>Reverse Proxy]
          icService[Ingress Service<br>Type: LoadBalancer] --> ingressController[Ingress Controller<br>Pod]
          ingressResource -. configures .-> ingressClass -. selects .-> ingressController
        end

        subgraph Namespace
            serviceA[Web Service<br>Type: ClusterIP]
            serviceA --> podA1
            serviceA --> podA2
            subgraph node1[Node]
                podA1[Web<br>Pod 1]
                podA2[Web<br>Pod 2]
            end

            serviceB[API Service<br>Type: ClusterIP]
            serviceB --> podB1
            serviceB --> podB2
            subgraph node2[Node]
                podB1[API<br>Pod 1]
                podB2[API<br>Pod 2]
            end
        end

        ingressController --> |Routes<br/>host foo.example.com<br/>path /| serviceA
        ingressController --> |Routes<br/>host foo.example.com<br/>path /api| serviceB
    end
```

- Client
  > The *external* entity making an HTTP/HTTPS request to an application.

- Load Balancer
  > A *external* managed service provided by a cloud provider (AWS, GCP, Azure) outside of the Kubernetes cluster, created automatically by the Service of type `LoadBalancer`. Operates at Layer 4 (TCP/UDP) or Layer 7 (HTTP/HTTPS).

- Ingress Resource
  > A declarative Kubernetes API object that specifies routing rules (e.g., host-based, path-based) for external traffic. Centralized management as a single entry point for all HTTP/HTTPS traffic, security (TLS termination) and observability (logging, metrics).

- Ingress Service
  > A Kubernetes Service that targets the Pods of the Ingress Controller. Setting its type to `LoadBalancer`, instructs to provision an external load balancer to route traffic to the nodes on the specific `NodePort` of the service.

- IngressClass
  > A Kubernetes resource that defines the Ingress Controller to use for a specific Ingress Resource. It specifies the controller implementation (e.g., Nginx, Traefik) and its configuration.

- Ingress Controller
  > A reverse proxy server (Nginx, Traefik, or Envoy) running as a active component in a Pod within the cluster. Responsible for fulfilling the rules defined in the Ingress Resource.

- Services
  > - **LoadBalancer**: The Ingress Service of type `LoadBalancer` is created to provisions an external load balancer and expose the Ingress Controller to external traffic.
  > - **ClusterIP**: The Ingress Controller sends traffic to a regular Kubernetes Service of type `ClusterIP`. The Service is the internal default cluster communication to endpoints and load balancer, distributing traffic to the healthy Pods that match its *label selector*.

- Pods
  > The Ingress Controller routes traffic to internal ClusterIP Services, which then forward it to the application Pods.

### 1.3. Order of Precedence

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
  > Top-level settings in the overlay such as `namespace:`, `namePrefix:`, `commonLabels:`, `images:` are applied last, possessing the highest precedence.

### 1.4. Prerequisites

TODO

## 2. Usage

### 2.1. Authentication

#### 2.1.1. Kube Config

TODO

### 2.2. Cryptographic

#### 2.2.1. TLS Certificates and Private Keys

TODO

#### 2.2.2. CA-Signed Certificates from CSRs

TODO

### 2.3. Secret Manager

#### 2.3.1. SOPS

1. GPG Key Pair Generation

    - Task Runner
      > Generate a new key pair to be used with SOPS.

      > [!NOTE]
      > The UID can be customized via the `SOPS_UID` variable (defaults to `sops-k8s`).

      ```sh
      make secret-gpg-generate SOPS_UID=<uid>
      ```

2. GPG Public Key Fingerprint

    - Task Runner
      > Print the  GPG Public Key fingerprint associated with a given UID.

      ```sh
      make secret-gpg-show SOPS_UID=<uid>
      ```

    - [.sops.yaml](.sops.yaml)
      > The GPG UID is required for populating in `.sops.yaml`.

      ```yaml
      creation_rules:
        - pgp: "<fingerprint>" # <uid>
      ```

3. SOPS Encrypt/Decrypt

    - Task Runner
      > Encrypt/decrypt one or more files in place using SOPS.

      ```sh
      make secret-sops-encrypt <files>
      make secret-sops-decrypt <files>
      ```

### 2.4. Task Runner

#### 2.4.1. Makefile

- [Makefile](Makefile)
  > The Makefile serves as the task runner.

  > [!NOTE]
  > - Run the `make help` command in the terminal to list the tasks used for the project.
  > - Targets **must** have a leading comment line starting with `##` to be included in the task list.

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

## 3. Troubleshoot

### 3.1. TODO

TODO

## 4. References

- Sentenz [Kubernetes](TODO) article.
