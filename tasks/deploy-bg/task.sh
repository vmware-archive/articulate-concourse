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

currentSlot=`(helm get values --all ${helm_release} --namespace ${k8s_cluster_ns} -o json | jq .productionSlot)`

if [ "$currentSlot" == "blue" ];
then
  newSlot="green"
  echo "Code needs to be deployed to Green Environment"
else
  newSlot="blue"
  echo "Code needs to be deployed to Blue Environment"
fi

if [ "$environment" == "$newSlot" ];
then
  echo "Deploying Application to $newSlot Environment"
else
  echo "Skipping Deployment as it is not a $environment Environment"
fi

articulateVersion=$newSlot.articulateVersion=$version
helm upgrade --install ${helm_release} articulate --set $enableSlot --set $articulateVersion --namespace ${k8s_cluster_ns} --reuse-values

echo "\n newSlot=$newSlot \n currentSlot=$currentSlot \n enableSlot=$newSlot.enabled=true \n productionSlot=productionSlot=$newSlot" | pbcopy
