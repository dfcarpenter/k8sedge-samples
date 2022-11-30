// This file setups up both Event Hubs and Stream Analytics Resources for use in this primary edge scenario.


@description('Specifies the Azure location for all resources.')
param location string = 'westus3'


resource eventhubnamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: 'akri-opc-ehnamespace'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    isAutoInflateEnabled: false
    kafkaEnabled: true  
  }
}


resource eventhub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  name: 'akri-opc-eventhub'
  parent: eventhubnamespace
  
  properties: {
    partitionCount: 1
    messageRetentionInDays: 1
  }
}


resource eventhubConsumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-11-01' = {
  name: 'e4kconnector'
  parent: eventhub
}

resource eventHubNamespace_authorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' = {
  name: 'akri-opc-ehnamespace/RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
  dependsOn: [
    eventhubnamespace
  ]
}

var eventHubNamespaceConnectionString = listKeys(eventHubNamespace_authorizationRule.id, eventHubNamespace_authorizationRule.apiVersion).primaryConnectionString




resource streamingAnalyticsJob 'Microsoft.StreamAnalytics/streamingjobs@2021-10-01-preview' = {
  name: 'akri-opc-job'
  location: location 
  sku: {
    capacity: 36
    name: 'Standard'
  }
  properties: {
    compatibilityLevel: '1.1'
  }
} 

resource streamingAnalyticsJobInput 'Microsoft.StreamAnalytics/streamingjobs/inputs@2021-10-01-preview' = {
  name: 'akriopc-inputjob-eventhub'
  parent:  streamingAnalyticsJob
  properties: {
    type: 'Stream'
    datasource: {
      type: 'Microsoft.EventHub/EventHub'
      properties: {
        authenticationMode: 'connectionString'
        consumerGroupName: 'e4kconnector'
        eventHubName: eventhub.name
        partitionCount: 1
        prefetchCount: 1
        serviceBusNamespace: eventhubnamespace.name
        sharedAccessPolicyKey: 'string'
        sharedAccessPolicyName: 'string'
      }    
  }
}
}


resource streamingAnalyticsJobOutput 'Microsoft.StreamAnalytics/streamingjobs/outputs@2021-10-01-preview' = {
  name: 'akriopc-outputjob-powerbi'
  parent:  streamingAnalyticsJob
  properties: {
    datasource: {
      type: 'PowerBI'
      properties: {
        authenticationMode: 'string'
        dataset: 'string'
        groupId: 'string'
        groupName: 'string'
        refreshToken: 'string'
        table: 'string'
        tokenUserDisplayName: 'string'
        tokenUserPrincipalName: 'string'
      }
    }
  }
}
