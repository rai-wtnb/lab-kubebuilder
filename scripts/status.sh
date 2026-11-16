#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$ROOT"

echo "== Nodes =="
kubectl get nodes

if [ ! -f operator/PROJECT ]; then
  echo
  echo "(operator/ is not scaffolded yet. Run mise init)"
  exit 0
fi

domain="$(awk '/^domain:/{print $2}' operator/PROJECT)"
echo
echo "== CRDs of this project (*.$domain) =="
kubectl get crd -o name | grep "\.$domain\$" || echo "(none. Install them with mise install-crds)"

ns="$(awk '/^namespace:/{print $2}' operator/config/default/kustomization.yaml)"
echo
echo "== In-cluster controller ($ns) =="
kubectl -n "$ns" get deploy,pod 2>/dev/null || true
kubectl get ns "$ns" >/dev/null 2>&1 || echo "(not deployed. Use mise deploy, or mise run-local to run it locally)"
