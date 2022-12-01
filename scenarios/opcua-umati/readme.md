## Scenario setup.

### Requirements
- Azure Subscription

### Steps 
- Install AksLite 
 ```sh
New-AksLiteDeployment -SingleMachineCluster -AcceptEula -LinuxVmCpuCount 4 -LinuxVmMemoryInMB 8192 -ServiceIpRangeSize 10
```
- Run setup.sh or setup.ps1
- Setup Azure Cloud resources
    - Eventhub 
- Install E4K
```powershell
helm install e4k oci://e4kpreview.azurecr.io/helm/az-e4k `
--version 0.1.0-amd64 `
-f .\e4k-values.yaml
```
- Install Apollo 
    - clone Apollo repo locally and switch to e4k-bridge branch
    - ensure values.apollo.e4k.yaml contain the below values
```yaml
authenticationMethod: serviceAccountToken
mqttBroker: azedge-dmqtt-frontend.default:1883
supervisorImage: edgeappmodel.azurecr.io/apollo/runtime/edge-application-supervisor
supervisorTag: 0.1.0.30172
moduleConnectorImage: edgeappmodel.azurecr.io/apollo/runtime/module-connector
moduleConnectorTag: 0.1.0.30172
logLevel: Debug
```
## 3. Install Akri
```sh
helm repo add akri-helm-charts https://project-akri.github.io/akri/
```

from the project-apollo/asset-discovery branch under distrib/kubernetes/akri
```sh
kubectl apply -f .\akri\namespace.yaml
kubectl apply -f .\akri\secret.yaml
kubectl apply -f .\akri\rolebinding.yaml
kubectl apply -f .\akri\discovery-handler.yaml
kubectl apply -f .\akri\umati.yaml

helm install akri akri-helm-charts/akri -f .\akri\values.yaml
```