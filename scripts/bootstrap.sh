#!/usr/bin/env bash

set -e

if ! command -v kubectl &>/dev/null; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  mv kubectl /usr/local/bin/
fi

if ! command -v kustomize &>/dev/null; then
  curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
  mv kustomize /usr/local/bin/
fi

if ! command -v helm &>/dev/null; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# if ! command -v k3s &> /dev/null; then
#   curl -sfL https://get.k3s.io | sh -
#   chmod 644 /etc/rancher/k3s/k3s.yaml
#   export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
# fi
