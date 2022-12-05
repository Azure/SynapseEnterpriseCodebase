@description('Location of the deployment')
param location string
@description('Private Endpoint Name')
param privateEndpointName string
@description('Private link service Id')
param parentId string
@description('Private Endpoint Group ID')
param groupId string
@description('Subnet ID to deploy the Private Endpoint')
param subnetId string

resource privateEndpointsResource 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: privateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: parentId
          groupIds: [
            groupId
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: subnetId
    }
    customDnsConfigs: []
  }
}
