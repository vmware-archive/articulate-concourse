#!/bin/sh

set -eu

echo "Login to PKS API [$PKS_API]"
pks login -a "$PKS_API" -u "$PKS_CLI_USERNAME" -p "$PKS_CLI_PASSWORD" --skip-ssl-verification
echo "Retrieve cluster credentials and configuration for [${PKS_CLUSTER_NAME}]"
pks get-credentials "${PKS_CLUSTER_NAME}"

echo "Switch kubectl context to [${PKS_CLUSTER_NAME}]"
kubectl config use-context ${PKS_CLUSTER_NAME}
kubectl cluster-info

echo "Deploying Application..."

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

version=`cat ./code/articulate/articulate-version`
cd ./code
echo "Deploying App - $version"
helm upgrade --install articulate articulate --set appVersion=$version
