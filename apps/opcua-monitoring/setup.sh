#!/bin/bash


echo "Setting up Azure resources"

echo "Please specify a subscription"
read SUBSCRIPTION 

az account set --subscription $SUBSCRIPTION


az eventhubs namespace create --name akriopc -g akriopc --enable-kafka true --enable-auto-inflate true --sku Standard 

az eventhubs eventhub create --name akriopchub -g akriopc --namespace-name akriopc


# Creating an Azure Stream Analytics cluster and job to process telemetry from eventhubs for eventual consumption by Power BI.

az extension add --name stream-analytics 

az stream-analytics cluster create --location westus3 --sku name ="Default" capacity=24 --name "Akri OPC Cluster" -g akriopc 