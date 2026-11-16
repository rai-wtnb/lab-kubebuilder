#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$ROOT/operator"

# Do not use the latest tag. With latest, imagePullPolicy becomes Always and the
# kubelet tries to pull a local image that is in no registry, which fails
IMG="${IMG:-lab-operator:dev}"

make docker-build IMG="$IMG"

# kind load docker-image can fail on a missing blob of a multi-arch index, so use
# docker save | ctr import directly (same workaround as lab-argocd / lab-istio / lab-k8s-gateway)
docker save "$IMG" | docker exec -i "$CLUSTER-control-plane" \
  ctr --namespace=k8s.io images import --digests - >/dev/null
echo "OK: loaded $IMG"

make deploy IMG="$IMG"

# Read the namespace and the name prefix from the kustomization kubebuilder generated
ns="$(awk '/^namespace:/{print $2}' config/default/kustomization.yaml)"
prefix="$(awk '/^namePrefix:/{print $2}' config/default/kustomization.yaml)"
# Make sure an image rebuilt under the same tag is picked up
kubectl -n "$ns" rollout restart "deploy/${prefix}controller-manager"
kubectl -n "$ns" rollout status "deploy/${prefix}controller-manager" --timeout=180s
