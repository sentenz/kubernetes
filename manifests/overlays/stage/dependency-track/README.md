Stage overlay notes for AWS EKS

This overlay adapts the base manifests for a remote staging cluster (EKS).

What this overlay does
- Patches the Traefik Service to `type: LoadBalancer` so EKS will provision a
  cloud Load Balancer (NLB/ELB) and expose ports 80/443.
- Ensures `hostNetwork: false` for Traefik (don't bind to node host network).

TLS and certificates
- Do not use the overlay's self-signed `secretGenerator` in staging. Instead
  use cert-manager or an existing Kubernetes TLS secret backed by ACM or a
  certificate issued for your staging domain.

Access
- After applying the overlay, find the external LB address:

  kubectl -n traefik get svc traefik

  Use the external IP/DNS returned by the LoadBalancer and point your DNS or
  /etc/hosts accordingly to access:

  - dependency-track.staging.example.com
  - api.dependency-track.staging.example.com

Recommendations
- Use cert-manager with a ClusterIssuer for ACME or import an ACM certificate
  into the Load Balancer, then reference the TLS secret in the Ingress.

