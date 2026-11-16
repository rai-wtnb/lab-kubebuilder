#!/usr/bin/env bash
set -euo pipefail

# Tools managed by mise ([tools] in mise.toml). Point to mise install when one is missing
missing=0
for c in go kubebuilder kind kubectl docker; do
  if ! command -v "$c" >/dev/null 2>&1; then
    echo "NG: $c not found (run mise install in this directory)"
    missing=1
  fi
done
# make / git come from macOS (Xcode Command Line Tools)
for c in make git; do
  if ! command -v "$c" >/dev/null 2>&1; then
    echo "NG: $c not found (xcode-select --install)"
    missing=1
  fi
done
[ "$missing" -eq 0 ] || exit 1

if ! docker info >/dev/null 2>&1; then
  echo "NG: cannot reach the docker daemon. Start colima: colima start kubebuilder-lab --cpu 4 --memory 8 --disk 30"
  echo "    (a colima instance already started for lab-argocd etc. works as is)"
  exit 1
fi

echo "OK: prerequisite tools and the docker daemon are available"
