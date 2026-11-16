#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$ROOT"
mkdir -p .work

if kind get clusters 2>/dev/null | grep -qx "$CLUSTER"; then
  echo "skip: $CLUSTER already exists"
  # Recreate the kubeconfig in case .work was removed
  kind export kubeconfig --name "$CLUSTER" >/dev/null
else
  # KUBECONFIG is set, so the context goes into .work/kubeconfig, not ~/.kube/config
  kind create cluster --name "$CLUSTER" --config kind/cluster.yaml
fi

kubectl get nodes
