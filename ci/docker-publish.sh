#!/bin/sh

set -eu

# usage: docker-publish.sh [tag]

tag=""
if [ -n "${1:-}" ]; then
    tag="$1"
    registry="registry.cncf.ci/linkerd/linkerd"
fi

# if DOCKER_CREDENTIALS is set, save it locally.
if [ -n "${DOCKER_CREDENTIALS:-}" ]; then
  mkdir -p ~/.docker
  echo "$DOCKER_CREDENTIALS" > ~/.docker/config.json
fi

# For debugging, alow this to be run without pushing.
docker_target="dockerBuildAndPush"
if [ "${NO_PUSH:-}" = "1" ]; then
  docker_target="docker"
fi

if [ -n "$tag" ]; then
    ./sbt "set Base.dockerRegistry in (linkerd, Bundle) := \"${registry}\"" "set Base.dockerTag in (linkerd, Bundle) := \"${tag}\"" "linkerd/bundle:${docker_target}" \
          "set Base.dockerRegistry in (namerd, Bundle) := \"${registry}\"" "set Base.dockerTag in (namerd, Bundle) := \"${tag}\"" "namerd/bundle:${docker_target}" \
          "set Base.dockerRegistry in (namerd, Dcos) := \"${registry}\"" "set Base.dockerTag in (namerd, Dcos) := \"dcos-${tag}\"" "namerd/dcos:${docker_target}"
else
  ./sbt "linkerd/bundle:${docker_target}" \
        "namerd/bundle:${docker_target}" \
        "namerd/dcos:${docker_target}"
fi
