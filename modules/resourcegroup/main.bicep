targetScope = 'subscription'
@description('Name of the ResourceGroup')
param resourceGroupName string
@description('Location of the deployment')
param resourceGroupLocation string

resource newRG 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
}
