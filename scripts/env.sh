# Shared settings sourced by every script. Even when a script is run directly,
# without mise, it only sees the lab's own kubeconfig (same value as [env] in mise.toml).
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLUSTER=kubebuilder-lab
export KUBECONFIG="$ROOT/.work/kubeconfig"
