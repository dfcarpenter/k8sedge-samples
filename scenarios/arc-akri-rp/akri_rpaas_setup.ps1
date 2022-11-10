$env:HELMVALUESPATH="helm-values.yaml"
$CustomLocationObjectId = az ad sp show --id bc313c14-388c-4e7d-a58e-70017303ee3b --query objectId -o tsv--id 
az connectedk8s connect --name "myAkriCluster" -g "testRG" --location westus --custom-locations-oid $CustomLocationObjectId 

$ExtensionType=""
$ServiceAccount=""

az k8s-extension create -c "myAkriCluster" -g "testRG" --name "akriExtension" --cluster-type connectedClusters --extension-type $ExtensionType --config Microsoft.CustomLocation.ServiceAccount=$ServiceAccount 

$ConnectedClusterResourceId=az connectedk8s show -g "testRG" -n "myAkriCluster" --query id -o tsv 
$ClusterExtensionResourceId= az k8s-extension show -g "testRG" -c "myAkriCluster" --cluster-type connectedClusters --name "akriExtension" --query id -o tsv

az customlocation create -g "testRG" -n "myAkriCluster" --namespace "arc" --host-resource-id $ConnectedClusterResourceId --cluster-extension-ids $ClusterExtensionResourceId