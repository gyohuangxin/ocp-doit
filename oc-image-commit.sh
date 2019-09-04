#!/bin/bash

set -eu

if [ "$#" -eq 1 ]; then
    RELEASE_IMAGE="registry.svc.ci.openshift.org/origin/release:4.2"
    CLUSTER_IMAGE_NAME="$1"
else
    RELEASE_IMAGE=$1
    CLUSTER_IMAGE_NAME=$2
fi

echo
echo "$CLUSTER_IMAGE_NAME commit in $RELEASE_IMAGE:"
oc adm release info "$RELEASE_IMAGE" --commits -o json | jq --raw-output ".references.spec.tags[] | select(.name == \"$CLUSTER_IMAGE_NAME\") | .annotations.\"io.openshift.build.source-location\" + \"/commits/\" + .annotations.\"io.openshift.build.commit.id\""
