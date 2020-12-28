#!/usr/bin/env bash
set -o xtrace

ANSIBLE_VERSION=(2.10.4 2.10 latest)
CONTAINERNAME="manydesigns/ansible"

BUILDFLAGS=(--compress --force-rm)
#https://github.com/opencontainers/image-spec/blob/master/annotations.md#pre-defined-annotation-keys
BUILDFLAGS+=(--label org.opencontainers.image.created="$(date -u +"%Y-%m-%dT%H:%M:%SZ")" )
BUILDFLAGS+=(--label org.opencontainers.image.version="${ANSIBLE_VERSION[0]}" )

TAGS=$(for version in "${ANSIBLE_VERSION[@]}"; do echo "-t ${CONTAINERNAME}:${version}"; done)

# shellcheck disable=SC2068
docker build "${BUILDFLAGS[@]}" \
      --build-arg ANSIBLE_VERSION="${ANSIBLE_VERSION[0]}" \
       ${TAGS[@]} .
