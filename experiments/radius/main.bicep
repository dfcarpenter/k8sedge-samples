import radius as radius 

param environment string 

resource app 'Applications.Core/applications@2022-03-15-privatepreview' = {
  name: 'myApp'
  location: 'global'
  properties: {
    environment: environment
  }
}

resource frontend 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'frontend'
  location: 'global'
  properties: {
    application: app.id
    connections: {
      mondodb: {
        source: dbconnector.id 
      }
    } 
    container: {
      image: 'nginx:latest'
    }
  }
}



resource container 'Applications.Core/containers@2022-03-15-privatepreview' = {
  name: 'my-backend'
  location: 'global'
  properties: {
    application: app.id
    container: {
      image: 'myimage'
    }
    connections: {
      blob: {
        source: blobContainer.id 
        iam: {
          kind: 'azure'
          roles: [
            'Storage Blob Data Reader'
          ]
        }
      }
    }
  }
}


resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: 'mystorage/default/mycontainer'
}

resource account 'Microsoft.DocumentDB/databaseAccounts@2020-04-01' = {
  name: 'account-${guid(resourceGroup().name)}'
  location: azureLocation
  kind: 'MongoDB'
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: azureLocation
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
  }


  resource underlyingdb 'mongodbDatabases' = {
    name: 'mydb'
    properties: {
      resource: {
        id: 'mydb'
      }
      options: { 
        throughput: 400
      }
    }
  }
}

resource dbconnector 'Applications.Connector/mongoDatabases@2022-03-15-privatepreview' = {
  name: 'dbconnector'
  location: 'global'
  properties: {
    environment: environment 
    resource: account::underlyingdb.id 
  }
}
