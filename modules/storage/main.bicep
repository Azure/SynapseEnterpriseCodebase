@description('Name of the Storage Account')
param storageAccountName string
@description('Location of the deployment')
param location string
@description('Retention days limit')
param retentionDays int
@description('Name of the private endpoint blob storage')
param peBlobName string
@description('Name of the private endpoint file storage')
param peFileName string
@description('Name of the private endpoint DFS storage')
param peDFSName string
@description('Subnet ID where the private endpoints will be deployed')
param subnetId string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Disabled'
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    isHnsEnabled: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        table: {
          keyType: 'Account'
          enabled: true
        }
        queue: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource blobservice 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: true
      days: retentionDays
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: retentionDays
    }
  }
}



resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2021-09-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: true
      days: retentionDays
    }
  }
}

module peBlob '../privateEndpoints/main.bicep' = {
  name: 'peblob-deployment'
  params:{
    location: location
    privateEndpoints_pefile_name : peBlobName
    parent_id : storageAccount.id
    group_id : 'blob'
    subnet_id: subnetId
  }
}

module peFile '../privateEndpoints/main.bicep' = {
  name: 'pefile-deployment'
  params:{
    location: location
    privateEndpoints_pefile_name : peFileName
    parent_id : storageAccount.id
    group_id : 'file'
    subnet_id: subnetId
  }
}

module peDFS '../privateEndpoints/main.bicep' = {
  name: 'pedfs-deployment'
  params:{
    location: location
    privateEndpoints_pefile_name : peDFSName
    parent_id : storageAccount.id
    group_id : 'dfs'
    subnet_id: subnetId
  }
}

output storageId string = storageAccount.id
output storageName string = storageAccount.name
output storage object = storageAccount
