#!/usr/bin/env bash
set -eu
set -o pipefail

IMAGE_URL="$(curl --silent https://raw.githubusercontent.com/openshift/installer/master/data/data/rhcos.json | jq --raw-output '.baseURI + .images.openstack.path')"

echo "Downloading RHCOS image from:"
echo "$IMAGE_URL"

curl --insecure --compressed -L -O "$IMAGE_URL"

IMAGE_NAME=$(echo "${IMAGE_URL##*/}")

gzip -l $IMAGE_NAME >/dev/null 2>&1

# Lets check to see if file is compressed with gzip
# and uncompress it if so
if [[ $? -eq 0 ]]
then
   echo "$IMAGE_NAME is compressed. Expanding..."
   gunzip -f $IMAGE_NAME
   IMAGE_NAME="${IMAGE_NAME%.gz}"
fi

# Save image with user specified name.
if [ "$#" -eq 1 ]
then
   mv $IMAGE_NAME ${1}
   IMAGE_NAME=${1}
fi
echo File saved as $IMAGE_NAME
