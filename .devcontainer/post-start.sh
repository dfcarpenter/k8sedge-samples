
export AKRI_HELM_CRICTL_CONFIGURATION="--set kubernetesDistro=k8s"

echo "post-start start"
echo "$(date +'%Y-%m-%d %H:%M:%S')    post-start start" >> "$HOME/status"

az connectedk8s connect --name AzureArcTest1 --resource-group AzureArcTest

echo "E4K install start"
helm install e4k oci://e4kpreview.azurecr.io/helm/az-e4k --version 0.1.0-amd64 --set e4kdmqtt.broker.backend.chainCount=1
echo "E4k install complete"

# echo "Akri install start"
# $namespace = 'akri'

# helm repo add akri-helm-charts https://project-akri.github.io/akri/

# helm repo update

# helm install akri akri-helm-charts/akri \
#     --namespace $namespace \
#     --set kubernetesDistro=k8s \
#     --set imagePullSecrets[0].name="edgeappmodel-azurecr" \
#     --set custom.discovery.enabled=true  \
#     --set custom.discovery.image.repository="edgeappmodel.azurecr.io/opcua-discovery-handler" \
#     --set custom.discovery.image.tag="latest" \
#     --set custom.discovery.name=akri-opcua-asset-discovery  \
#     --set custom.configuration.enabled=true  \
#     --set custom.configuration.name=akri-opcua-asset-discovery  \
#     --set custom.configuration.discoveryHandlerName=akri-opcua-asset-discovery \
#     --set custom.configuration.discoveryDetails="" \
#     --set custom.configuration.brokerPod.image.repository="edgeappmodel.azurecr.io/opcua-discovery-broker" \
#     --set custom.configuration.brokerPod.envFrom.secretRef="edgeappmodel-azurecr" \
#     --set custom.configuration.brokerPod.image.tag="latest"

# Installing using values.yaml file.
# helm install akri akri-helm-charts/akri `
#     --namespace $namespace `
#     --values values.yaml

# Installing from the AKRI chart that was copied to our repo.
# helm install akri .\distrib\kubernetes\akri\10_akri\helm\ -n akri -f .\distrib\kubernetes\akri\10_akri\values.yaml
echo "Akri install complete"


echo "installing E4K cli start"
wget "https://aka.ms/E4KCLI-Linux" -O E4KCLI.tar.gz && tar -xzf E4KCLI.tar.gz && sudo cp kubectl-azedge_e4k-linux-amd64/kubectl-azedge_e4k /usr/local/bin && rm -rf kubectl-azedge_e4k-linux-amd64/ && rm -rf E4KCLI.tar.gz

echo "E4K cli install complete"

echo "post-start complete"
echo "$(date +'%Y-%m-%d %H:%M:%S')    post-start complete" >> "$HOME/status"
