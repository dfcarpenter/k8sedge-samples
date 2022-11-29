#!/bin/bash


echo "Setting up Azure resources"

echo "Please specify a subscription"
read SUBSCRIPTION 

az account set --subscription ${$SUBSCRIPTION:-21670d02-8dd7-48aa-8fe4-44d8cb9232bb}

az deployment group create --resource-group akriopc --template-file .\infra.bicep

# Creating an Azure Stream Analytics cluster and job to process telemetry from eventhubs for eventual consumption by Power BI.


az connectedk8s connect --name AzureArcTest1 --resource-group AzureArcTest

echo "E4K install start"
helm install e4k oci://e4kpreview.azurecr.io/helm/az-e4k --version 0.1.0-amd64 -f .\e4k-values.yaml
echo "E4k install complete"

echo "Akri install start"

$namespace = 'akri'

helm repo add akri-helm-charts https://project-akri.github.io/akri/

helm repo update

helm install akri akri-helm-charts/akri \
    --namespace $namespace \
    --set kubernetesDistro=k8s \
    --set imagePullSecrets[0].name="edgeappmodel-azurecr" \
    --set custom.discovery.enabled=true  \
    --set custom.discovery.image.repository="edgeappmodel.azurecr.io/opcua-discovery-handler" \
    --set custom.discovery.image.tag="latest" \
    --set custom.discovery.name=akri-opcua-asset-discovery  \
    --set custom.configuration.enabled=true  \
    --set custom.configuration.name=akri-opcua-asset-discovery  \
    --set custom.configuration.discoveryHandlerName=akri-opcua-asset-discovery \
    --set custom.configuration.discoveryDetails="" \
    --set custom.configuration.brokerPod.image.repository="edgeappmodel.azurecr.io/opcua-discovery-broker" \
    --set custom.configuration.brokerPod.envFrom.secretRef="edgeappmodel-azurecr" \
    --set custom.configuration.brokerPod.image.tag="latest"

# Installing using values.yaml file.
# helm install akri akri-helm-charts/akri \
#     --namespace $namespace `
#     --values values.yaml

# Installing from the AKRI chart that was copied to our repo.
# helm install akri .\distrib\kubernetes\akri\10_akri\helm\ -n akri -f .\distrib\kubernetes\akri\10_akri\values.yaml
echo "Akri install complete"



