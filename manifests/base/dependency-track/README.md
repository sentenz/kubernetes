# Dependency-Track

- [1. Usage](#1-usage)
  - [1.1. FQDN](#11-fqdn)
    - [1.1.1. Domain](#111-domain)
    - [1.1.2. Subdomains](#112-subdomains)
  - [1.2. TLS Certificate](#12-tls-certificate)
    - [1.2.1. Self-Signed TLS Certificate](#121-self-signed-tls-certificate)
    - [1.2.2. TLS Secret Configuration](#122-tls-secret-configuration)
  - [1.3. Troubleshoot](#13-troubleshoot)

## 1. Usage

### 1.1. FQDN

#### 1.1.1. Domain

Paths Split the frontend and API into paths under a single hostname, suitable for simpler setups or to access both services under the same domain.

- `values.yaml`
  > The base chart values define the API base URL for the frontend to communicate with the API server.

  ```yaml
  apiBaseUrl: "https://dependency-track.localhost"
  ```

- `patch-dependency-track-ingress.yaml`
  > The ingress configuration for the single hostname using `traefik` defined in `overlays`, modifies the base ingress to route traffic to the appropriate services based on the path.
  >
  > - FQDN `dependency-track.localhost`
  > - Frontend on `/`, API on `/api` and `/health`

  ```yaml
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: dependency-track
    namespace: dependency-track
    annotations:
      traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
  spec:
    ingressClassName: traefik
    rules:
      - host: "dependency-track.localhost"
        http:
          paths:
            - path: /api
              pathType: Prefix
              backend:
                service:
                  name: dependency-track-api-server
                  port:
                    name: web
            - path: /health
              pathType: Prefix
              backend:
                service:
                  name: dependency-track-api-server
                  port:
                    name: web
            - path: /
              pathType: Prefix
              backend:
                service:
                  name: dependency-track-frontend
                  port:
                    name: web
    tls:
      - hosts:
          - "dependency-track.localhost"
        secretName: dependency-track-tls
  ```

#### 1.1.2. Subdomains

Subdomains split the frontend and API into separate subdomains, suitable for more complex and distinct setups.

- `values.yaml`
  > The base chart values define the API base URL for the frontend to communicate with the API server.

  ```yaml
  apiBaseUrl: "https://api.dependency-track.localhost"
  ```

- `patch-dependency-track-ingress.yaml`
  > The ingress configuration for subdomains using `traefik` defined in `overlays`, modifies the base ingress to route traffic to the appropriate services based on the subdomain.
  >
  > - FQDN `dependency-track.localhost`
  > - Frontend on `dependency-track.localhost`, API on `api.dependency-track.localhost`

  ```yaml
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: dependency-track
    namespace: dependency-track
    annotations:
      traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
  spec:
    ingressClassName: traefik
    rules:
      - host: "dependency-track.localhost"
        http:
          paths:
            - path: /
              pathType: Prefix
              backend:
                service:
                  name: dependency-track-frontend
                  port:
                    name: web
      - host: "api.dependency-track.localhost"
        http:
          paths:
            - path: /
              pathType: Prefix
              backend:
                service:
                  name: dependency-track-api-server
                  port:
                    name: web
            - path: /api
              pathType: Prefix
              backend:
                service:
                  name: dependency-track-api-server
                  port:
                    name: web
            - path: /health
              pathType: Prefix
              backend:
                service:
                  name: dependency-track-api-server
                  port:
                    name: web
    tls:
      - hosts:
          - "dependency-track.localhost"
          - "api.dependency-track.localhost"
        secretName: dependency-track-tls
  ```

### 1.2. TLS Certificate

#### 1.2.1. Self-Signed TLS Certificate

The overlay uses a self-signed TLS certificate for local development. The certificate files are included in the overlay directory and referenced in the `kustomization.yaml` file.

> [!TIP]
> mkcert is used to generate the certificate, which is suitable for local development and testing purposes. The certificate is not trusted by default, add the self-signed certificate to the browser's trust store or disable certificate verification in API clients.

- FQDN
  > Generate a self-signed certificate for the single hostname.

  ```bash
  mkcert dependency-track.localhost
  ```

- Subdomains
  > Generate a self-signed certificate for the domain and subdomains.

  ```bash
  mkcert dependency-track.localhost api.dependency-track.localhost
  ```

#### 1.2.2. TLS Secret Configuration

- `kustomization.yaml`
  > The TLS secret is configured in the `kustomization.yaml` file of the `overlays`. It uses the generated certificate files to create a Kubernetes secret of type `kubernetes.io/tls`.

  ```yaml
  secretGenerator:
    - name: dependency-track-tls
      namespace: dependency-track
      type: "kubernetes.io/tls"
      files:
        - tls.crt=dependency-track.localhost+1.pem
        - tls.key=dependency-track.localhost+1-key.pem
  generatorOptions:
    disableNameSuffixHash: true
  ```

### 1.3. Troubleshoot

- Check Resources
  > Ensure the resources are created and running correctly.

  ```bash
  kubectl --kubeconfig=examples/config/kubeconfig.yaml -n dependency-track get secret dependency-track-tls
  kubectl --kubeconfig=examples/config/kubeconfig.yaml -n dependency-track get ingress
  kubectl --kubeconfig=examples/config/kubeconfig.yaml -n dependency-track get pods
  ```

- Check HTTP
  > Verify the services are accessible via HTTP. The `-k` flag skips TLS verification for self-signed certificates.

  ```bash
  curl -k https://dependency-track.localhost/ -I
  curl -k https://api.dependency-track.localhost/ -I
  ```

- `hostNetwork`
  > The `hostNetwork: true` setting is used to allow Traefik to bind to ports 80 and 443 on the host network. This is safe for a local development node (k3s/minikube/kind) that runs on the same machine where the browser services.

  > [!IMPORTANT]
  > Do not enable hostNetwork for remote clusters, it exposes Traefik on node network interfaces and can conflict with host services or create unwanted exposure.
