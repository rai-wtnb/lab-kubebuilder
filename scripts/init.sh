#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$ROOT"

# The domain that ends the API group, and the Go module name. Override with env vars
DOMAIN="${DOMAIN:-lab.example.com}"
REPO="${REPO:-github.com/rai-wtnb/lab-kubebuilder/operator}"

if [ -f operator/PROJECT ]; then
  echo "skip: operator/ is already scaffolded (remove operator/ to start over)"
  exit 0
fi

mkdir -p operator
cd operator
# The directory name (operator) becomes the project name:
# the namespace is operator-system and resource names get the operator- prefix
kubebuilder init --domain "$DOMAIN" --repo "$REPO"

echo
echo "== Scaffolded. Next, add an API inside operator/ =="
echo "   cd operator"
echo "   kubebuilder create api --group demo --version v1alpha1 --kind Greeting"
