#!/usr/bin/env

set -Eeuo pipefail

# ==================================================
# Enterprise Environment Verification
# ==================================================

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "${ROOT_DIR}/automation/lib/logging.sh"
source "${ROOT_DIR}/automation/lib/common.sh"

if [[ -f "${ROOT_DIR}/config/project.env" ]]; then
    source "${ROOT_DIR}/config/project.env"
else
    error "config/project.env not found!"
    exit 1
fi

banner "Enterprise Environment Verification"

TOOLS=(
    git
    docker
    kubectl
    helm
    kind
    trivy
    jq
    yq
)

FAILED=0

for tool in "${TOOLS[@]}"; do
    info "Checking ${tool}..."

    if command_exists "${tool}"; then
        success "${tool} found"
    else
        error "${tool} not found"
        FAILED=1
    fi
done

echo

if [[ ${FAILED} -eq 0 ]]; then
    success "Environment Ready."
    exit 0
else
    error "Environment verification failed."
    exit 1
fi
