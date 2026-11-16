#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$ROOT/operator"

ns="$(awk '/^namespace:/{print $2}' config/default/kustomization.yaml)"
prefix="$(awk '/^namePrefix:/{print $2}' config/default/kustomization.yaml)"
kubectl -n "$ns" logs -f "deploy/${prefix}controller-manager"
