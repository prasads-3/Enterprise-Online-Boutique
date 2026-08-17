#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "${ROOT_DIR}/automation/lib/logging.sh"
source "${ROOT_DIR}/config/project.env"

banner "Docker Build Automation"

SOURCE_PATH="${ROOT_DIR}/${SOURCE_DIR}"

build_image() {
    local service="$1"
    local dockerfile="$2"
    local context="$3"

    local image_name="${DOCKER_USERNAME}/${APPLICATION_NAME}-${service}:${IMAGE_TAG}"

    if [[ "${FORCE_REBUILD:-false}" != "true" ]] && docker image inspect "${image_name}" >/dev/null 2>&1; then
        info "${service}: image already exists - skipping build"
        return 0
    fi

    banner "Building ${service}"

    info "Image      : ${image_name}"
    info "Dockerfile : ${dockerfile}"
    info "Context    : ${context}"

    docker build \
        --platform "${BUILD_PLATFORM}" \
        -t "${image_name}" \
        -f "${dockerfile}" \
        "${context}"

    success "${service} image built successfully"
}

discover_and_build() {

    local dockerfile
    local service
    local context

    while IFS= read -r dockerfile; do

        if [[ "$(basename "$(dirname "${dockerfile}")")" == "src" ]]; then
            service="$(basename "$(dirname "$(dirname "${dockerfile}")")")"
            context="$(dirname "${dockerfile}")"
        else
            service="$(basename "$(dirname "${dockerfile}")")"
            context="$(dirname "${dockerfile}")"
        fi

        build_image "${service}" "${dockerfile}" "${context}"

    done < <(find "${SOURCE_PATH}" -type f -name Dockerfile | sort)

}

discover_and_build

success "Docker build automation completed"
