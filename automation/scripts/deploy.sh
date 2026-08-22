#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# Enterprise Online Boutique - Deployment Automation
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTOMATION_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$AUTOMATION_DIR/.." && pwd)"

# ------------------------------------------------------------
# Project Paths
# ------------------------------------------------------------

APP_DIR="$PROJECT_ROOT/apps/online-boutique"
RELEASE_MANIFEST="$APP_DIR/release/kubernetes-manifests.yaml"

# ------------------------------------------------------------
# Colors / Logging
# ------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ------------------------------------------------------------
# Header
# ------------------------------------------------------------

echo
echo "============================================================"
echo " Enterprise Online Boutique - Deployment"
echo "============================================================"
echo

info "Project Root: $PROJECT_ROOT"
info "Application Directory: $APP_DIR"
info "Release Manifest: $RELEASE_MANIFEST"

# ------------------------------------------------------------
# 1. Check Required Tools
# ------------------------------------------------------------

echo
info "Checking required tools..."

REQUIRED_COMMANDS=("kubectl" "kind")

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        success "$cmd found"
    else
        error "$cmd is not installed or not available in PATH."
        exit 1
    fi
done

# ------------------------------------------------------------
# 2. Check Project Structure
# ------------------------------------------------------------

echo
info "Checking project structure..."

if [[ ! -d "$APP_DIR" ]]; then
    error "Application directory not found:"
    echo "       $APP_DIR"
    exit 1
fi

success "Application directory found"

if [[ ! -f "$RELEASE_MANIFEST" ]]; then
    error "Release Kubernetes manifest not found:"
    echo "       $RELEASE_MANIFEST"
    exit 1
fi

success "Release Kubernetes manifest found"

# ------------------------------------------------------------
# 3. Check Kubernetes Cluster
# ------------------------------------------------------------

echo
info "Checking Kubernetes cluster..."

if ! kubectl cluster-info >/dev/null 2>&1; then
    error "Kubernetes cluster is not reachable."
    echo
    echo "Start your Kind cluster and run this script again."
    exit 1
fi

success "Kubernetes cluster is reachable"

# ------------------------------------------------------------
# 4. Display Cluster Information
# ------------------------------------------------------------

echo
info "Kubernetes nodes:"

kubectl get nodes -o wide

# ------------------------------------------------------------
# 5. Validate Kubernetes Manifest
# ------------------------------------------------------------

echo
info "Validating Kubernetes manifest..."

if kubectl apply --dry-run=client -f "$RELEASE_MANIFEST" >/dev/null 2>&1; then
    success "Kubernetes manifest validation passed"
else
    error "Kubernetes manifest validation failed."
    exit 1
fi

# ------------------------------------------------------------
# 6. Deploy Application
# ------------------------------------------------------------

echo
info "Deploying Online Boutique..."

kubectl apply -f "$RELEASE_MANIFEST"

success "Kubernetes manifest applied successfully"

# ------------------------------------------------------------
# 7. Wait for Resources
# ------------------------------------------------------------

echo
info "Waiting for Kubernetes resources to initialize..."

sleep 10

# ------------------------------------------------------------
# 8. Show Pods
# ------------------------------------------------------------

echo
echo "============================================================"
echo " Pod Status"
echo "============================================================"

kubectl get pods -o wide

# ------------------------------------------------------------
# 9. Show Deployments
# ------------------------------------------------------------

echo
echo "============================================================"
echo " Deployment Status"
echo "============================================================"

kubectl get deployments

# ------------------------------------------------------------
# 10. Show Services
# ------------------------------------------------------------

echo
echo "============================================================"
echo " Service Status"
echo "============================================================"

kubectl get services

# ------------------------------------------------------------
# 11. Check Deployment Rollout
# ------------------------------------------------------------

echo
info "Checking deployment readiness..."

DEPLOYMENTS=$(kubectl get deployments -o jsonpath='{.items[*].metadata.name}')

DEPLOYMENT_FAILURE=0

if [[ -z "$DEPLOYMENTS" ]]; then
    warning "No deployments found."
    DEPLOYMENT_FAILURE=1
else
    for deployment in $DEPLOYMENTS; do
        echo
        info "Checking rollout: $deployment"

        if kubectl rollout status "deployment/$deployment" --timeout=120s; then
            success "$deployment rollout completed"
        else
            error "$deployment rollout failed or timed out"
            DEPLOYMENT_FAILURE=1
        fi
    done
fi

# ------------------------------------------------------------
# 12. Final Status
# ------------------------------------------------------------

echo
echo "============================================================"
echo " Final Deployment Status"
echo "============================================================"

kubectl get pods
echo

kubectl get deployments
echo

kubectl get services

# ------------------------------------------------------------
# 13. Final Result
# ------------------------------------------------------------

echo

if [[ "$DEPLOYMENT_FAILURE" -ne 0 ]]; then
    echo "============================================================"
    error "Enterprise Online Boutique deployment FAILED"
    echo "============================================================"
    echo
    info "Useful troubleshooting commands:"
    echo
    echo "  kubectl get pods"
    echo "  kubectl get deployments"
    echo "  kubectl get services"
    echo "  kubectl get events --sort-by=.lastTimestamp"
    echo
    exit 1
fi

echo "============================================================"
success "Enterprise Online Boutique deployment completed successfully"
echo "============================================================"
echo

info "Useful commands:"
echo
echo "  kubectl get pods"
echo "  kubectl get deployments"
echo "  kubectl get services"
echo "  kubectl get events --sort-by=.lastTimestamp"
echo
