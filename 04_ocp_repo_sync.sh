#!/bin/bash

set -ex
source common.sh

eval "$(go env)"
echo "$GOPATH" | highlight # should print $HOME/go or something like that

function sync_go_repo_and_patch {
    DEST="$GOPATH/src/$1"
    figlet "Syncing $1" | highlight

    if [ ! -d $DEST ]; then
        mkdir -p $DEST
        git clone $2 $DEST
    fi

    pushd $DEST

    git am --abort || true
    git checkout master
    git pull --rebase origin master
    git branch -D we_dont_need_no_stinkin_patches || true
    git checkout -b we_dont_need_no_stinkin_patches

    shift; shift;
    for arg in "$@"; do
        curl -L $arg | git am
    done
    popd
}

sync_go_repo_and_patch github.com/openshift/origin https://github.com/openshift/origin.git
sync_go_repo_and_patch github.com/openshift/release https://github.com/openshift/release.git

sync_go_repo_and_patch github.com/openshift/machine-config-operator https://github.com/openshift/machine-config-operator.git
sync_go_repo_and_patch github.com/openshift/machine-api-operator https://github.com/openshift/machine-api-operator.git

sync_go_repo_and_patch github.com/openshift/installer https://github.com/openshift/installer.git

sync_go_repo_and_patch github.com/terraform-providers/terraform-provider-openstack https://github.com/terraform-providers/terraform-provider-openstack

sync_go_repo_and_patch github.com/openshift/ci-operator https://github.com/openshift/ci-operator.git
sync_go_repo_and_patch github.com/sallyom/installer-e2e https://github.com/sallyom/installer-e2e.git


sync_go_repo_and_patch sigs.k8s.io/openshift/cluster-api-provider-openstack https://github.com/openshift/cluster-api-provider-openstack.git
