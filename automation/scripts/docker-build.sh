#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "${ROOT_DIR}/automation/lib/logging.sh"
source "${ROOT_DIR}/config/project.env"

banner "Docker Build Automation"


SOURCE_PATH="${ROOT_DIR}/${SOURCE_DIR}"


build_image() {

    local service="$1"
    local context="$2"

    local image_name="${DOCKER_USERNAME}/${APPLICATION_NAME}-${service}:${IMAGE_TAG}"


    banner "Building ${service}"


    info "Image   : ${image_name}"
    info "Context : ${context}"


    docker build \
        --platform "${BUILD_PLATFORM}" \
        -t "${image_name}" \
        "${context}"


    success "${service} image built successfully"

}



discover_and_build() {


    while read -r dockerfile
    do

        service=$(basename "$(dirname "$dockerfile")")


        if [[ "$service" == "src" ]]; then

            service=$(basename "$(dirname "$(dirname "$dockerfile")")")

            context=$(dirname "$(dirname "$dockerfile")")

        else

            context=$(dirname "$dockerfile")

        fi


        build_image "${service}" "${context}"


    done < <(find "${SOURCE_PATH}" -name Dockerfile)


}



discover_and_build


success "All Docker builds completed"
