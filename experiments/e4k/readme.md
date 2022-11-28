


```bash 
az group create --name <resource group name> --location eastus

```

```bash 
# Create an Event Hubs namespace. Specify a name for the Event Hubs namespace.
az eventhubs namespace create --name <Event Hubs namespace> --resource-group <resource group name> -l <region, for example: East US>

```



```bash
# Create an event hub. Specify a name for the event hub. 
az eventhubs eventhub create --name <event hub name> --resource-group <resource group name> --namespace-name <Event Hubs namespace>

```

```bash
helm upgrade e4k oci://e4kpreview.azurecr.io/helm/az-e4k --version 0.1.0-amd64 -f values.yaml

```