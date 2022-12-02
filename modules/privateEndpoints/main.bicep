param location string
param privateEndpoints_pefile_name string
param parent_id string
param group_id string
param subnet_id string

resource privateEndpoints_pedfsblob_name_resource 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: privateEndpoints_pefile_name
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpoints_pefile_name
        properties: {
          privateLinkServiceId: parent_id
          groupIds: [
            group_id
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
      id: subnet_id
    }
    customDnsConfigs: []
  }
}
