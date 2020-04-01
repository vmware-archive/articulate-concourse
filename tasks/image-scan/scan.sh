#!/bin/sh

set -eu

sleep 60

TAG_NAME=`cat articulate-image/tag`
IMAGEID=`cat articulate-image/image-id`
DIGEST=`cat articulate-image/digest`

echo $IMAGEID-$DIGEST-$TAG_NAME

echo https://${HARBOR_HOST}/api/repositories/hemanth/pks-demo/tags/${TAG_NAME}

wget -O /tmp/scan.json --no-check-certificate  --header "Authorization: Basic ${HARBOR_PASSWORD}" --header "Content-Type: application/json" https://${HARBOR_HOST}/api/repositories/hemanth/pks-demo/tags/${TAG_NAME}

Result=`cat /tmp/scan.json | yq r - "scan_overview.*.severity"`

if [ "$Result" != "High" ] ; then
    echo "Container Images don't have vulnerability of defined High threshold"
else
    echo "Container Images has vulnerability of severity of High and above. Failing the step"
    exit 1
fi

if [ "$Result" != "Critical" ] ; then
    echo "Container Images don't have vulnerability of Critical threshold. Passing the step."
else
    echo "Container Images has vulnerability of severity of Critical and above. Failing the step"
    exit 1
fi