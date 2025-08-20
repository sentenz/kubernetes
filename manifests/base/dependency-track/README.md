# Dependency Track

- [1. Usage](#1-usage)
  - [1.1. FQDN](#11-fqdn)
    - [1.1.1. Domain](#111-domain)
    - [1.1.2. Subdomains](#112-subdomains)
  - [1.2. Troubleshoot](#12-troubleshoot)

## 1. Usage

### 1.1. FQDN

#### 1.1.1. Domain

Domain Paths ([Ingress Fan Out](https://kubernetes.io/docs/concepts/services-networking/ingress/#simple-fanout)) split the frontend and API into paths under a single hostname, suitable for simpler setups or to access both services under the same domain.

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

  > [!NOTE]
  > [Secure an Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) by specifying a Secret that contains a TLS private key and certificate.

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

Subdomains ([Ingress Name Based](https://kubernetes.io/docs/concepts/services-networking/ingress/#name-based-virtual-hosting)) split the frontend and API into separate subdomains, suitable for more complex and distinct setups.

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

  > [!NOTE]
  > [Secure an Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) by specifying a Secret that contains a TLS private key and certificate.

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

### 1.2. Troubleshoot

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
