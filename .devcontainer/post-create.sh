#!/bin/sh

echo "Starting Post Create Command"

k3d cluster delete

k3d cluster create -p '1883:1883@loadbalancer' -p '8883:8883@loadbalancer' -p '6001:6001@loadbalancer'

helm install akri akri-helm-charts/akri \
    $AKRI_HELM_CRICTL_CONFIGURATION \
    --set opcua.discovery.enabled=true \
    --set opcua.configuration.enabled=true \
    --set opcua.configuration.name=akri-opcua-monitoring \
    --set opcua.configuration.brokerPod.image.repository="ghcr.io/project-akri/akri/opcua-monitoring-broker" \
    --set opcua.configuration.brokerProperties.IDENTIFIER='CNC_Monitoring' \
    --set opcua.configuration.brokerProperties.NAMESPACE_INDEX='2' \
    --set opcua.configuration.discoveryDetails.discoveryUrls[0]="opc.tcp://<SomeServer0 IP address>:<SomeServer0 port>/Quickstarts/ReferenceServer/" \
    # --set opcua.configuration.mountCertificates='true'


helm install e4k oci://e4kpreview.azurecr.io/helm/az-e4k --version 0.1.0-amd64 --set e4kdmqtt.broker.backend.chainCount=1

echo "Ending Post Create Command"