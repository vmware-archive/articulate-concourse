#!/bin/sh

set -eu

echo "Login to PKS API [$PKS_API]"
pks login -a "$PKS_API" -u "$PKS_CLI_USERNAME" -p "$PKS_CLI_PASSWORD" --skip-ssl-verification
echo "Retrieve cluster credentials and configuration for [${k8s-cluster-name}]"
pks get-credentials "${k8s-cluster-name}"
if [[ "$PKS_SKIP_TLS_VERIFY" == "true" ]]; then
kubectl config set-cluster "${k8s-cluster-name}" --certificate-authority=""
kubectl config set-cluster "${k8s-cluster-name}" --insecure-skip-tls-verify=true
fi
echo "Switch kubectl context to [${k8s-cluster-name}]"
kubectl config use-context ${k8s-cluster-name}
kubectl cluster-info

echo "Test Application..."

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

helm test ins1
