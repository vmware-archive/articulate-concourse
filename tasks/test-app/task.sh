#!/bin/sh

set -eu

echo "Login to PKS API [$PKS_API]"
pks login -a "$PKS_API" -u "$PKS_CLI_USERNAME" -p "$PKS_CLI_PASSWORD" --skip-ssl-verification
echo "Retrieve cluster credentials and configuration for [${k8s_cluster_name}]"
pks get-kubeconfig "${k8s_cluster_name}" -a api.pks.caas.pez.pivotal.io -u "$PKS_CLI_USERNAME" -p "$PKS_CLI_PASSWORD" -k 2>&1

echo "Switch kubectl context to [${k8s_cluster_name}]"
kubectl config use-context ${k8s_cluster_name}
kubectl cluster-info

echo "Test Application..."

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

helm test ${helm_release} --namespace ${k8s_cluster_ns}
