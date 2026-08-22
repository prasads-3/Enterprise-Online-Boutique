#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "${ROOT_DIR}/automation/lib/logging.sh"
source "${ROOT_DIR}/config/project.env"

banner "Trivy Security Scan"

info "Scanning project filesystem..."
info "Project: ${PROJECT_NAME}"

trivy fs \
    --scanners vuln,secret \
    --severity HIGH,CRITICAL \
    --exit-code 1 \
    "${ROOT_DIR}"

success "Trivy filesystem security scan completed successfully"
