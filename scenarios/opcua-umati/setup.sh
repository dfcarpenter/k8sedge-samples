#!/bin/bash


echo "Setting up Azure resources"

echo "Please specify a subscription"
read SUBSCRIPTION 

az account set --subscription ${$SUBSCRIPTION:-21670d02-8dd7-48aa-8fe4-44d8cb9232bb}

az deployment group create --resource-group akriopc --template-file .\infra.bicep

# Creating an Azure Stream Analytics cluster and job to process telemetry from eventhubs for eventual consumption by Power BI.

az extension add --name stream-analytics 

az stream-analytics cluster create --location westus3 --sku name ="Default" capacity=24 --name "Akri OPC Cluster" -g akriopc 