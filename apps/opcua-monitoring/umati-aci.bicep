
param location string

param restartPolicy string = 'Always'

resource umaticg 'Microsoft.ContainerInstance/containerGroups@2021-10-01' = {
  name: 'umatiopc'
  location: 'westus3'
  properties: {
    containers: [
      {
        name: 'umatiopc'
        properties: {
          image: 'ghcr.io/ridomin/umati:dev'
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 2
            }
          }
          ports: [
            {
              port: 4840
              protocol: 'TCP'
            }
          ]
        }
      }
    ]
    osType: 'Linux' 
    restartPolicy: restartPolicy
    ipAddress: {
      ports: [
        {
          port: 4840
          protocol: 'TCP'
        }
      ]
      dnsNameLabel: 'umatiopc'
      type: 'Public'
    }
  }
}

output containerIPv4Address string = umaticg.properties.ipAddress.ip
