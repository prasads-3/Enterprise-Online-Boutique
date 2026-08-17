#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "${ROOT_DIR}/automation/lib/logging.sh"
source "${ROOT_DIR}/config/project.env"

banner "Docker Push Automation"

check_docker_auth() {

    if ! docker info 2>/dev/null | grep -q "Username: ${DOCKER_USERNAME}"; then
        error "Docker Hub login not detected for ${DOCKER_USERNAME}"
        error "Run: docker login"
        exit 1
    fi

    success "Docker Hub authentication detected"
}

push_image() {

    local service="$1"
    local image_name="${DOCKER_USERNAME}/${APPLICATION_NAME}-${service}:${IMAGE_TAG}"

    if ! docker image inspect "${image_name}" >/dev/null 2>&1; then
        error "Local image not found: ${image_name}"
        return 1
    fi

    info "Pushing ${image_name}"

    docker push "${image_name}"

    success "${service} pushed successfully"
}

push_all_images() {

    local failed=0

    while IFS= read -r dockerfile; do

        local service

        if [[ "$(basename "$(dirname "${dockerfile}")")" == "src" ]]; then
            service="$(basename "$(dirname "$(dirname "${dockerfile}")")")"
        else
            service="$(basename "$(dirname "${dockerfile}")")"
        fi

        if ! push_image "${service}"; then
            failed=1
        fi

    done < <(find "${ROOT_DIR}/${SOURCE_DIR}" -type f -name Dockerfile | sort)

    if [[ "${failed}" -ne 0 ]]; then
        error "One or more Docker images failed to push"
        exit 1
    fi
}

check_docker_auth
push_all_images

success "Docker push automation completed"
