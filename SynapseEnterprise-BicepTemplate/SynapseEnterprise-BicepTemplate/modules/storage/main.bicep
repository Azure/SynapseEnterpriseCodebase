param storageAccount_name string
param location string
param retention_days int
param peblob_name string
param pefile_name string
param pedfs_name string
param subnet_id string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccount_name
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Disabled'
    allowCrossTenantReplication: false
    //isSftpEnabled: false
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
      days: retention_days
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: retention_days
    }
  }
}



resource fileservice 'Microsoft.Storage/storageAccounts/fileServices@2021-09-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    /*protocolSettings: {
      smb: {}
    }
    cors: {
      corsRules: []
    }*/
    shareDeleteRetentionPolicy: {
      enabled: true
      days: retention_days
    }
  }
}

module peblob '../privateEndpoints/main.bicep' = {
  name: 'peblob-deployment'
  params:{
    location: location
    privateEndpoints_pefile_name : peblob_name
    parent_id : storageAccount.id
    group_id : 'blob'
    subnet_id: subnet_id
  }
}

module pefile '../privateEndpoints/main.bicep' = {
  name: 'pefile-deployment'
  params:{
    location: location
    privateEndpoints_pefile_name : pefile_name
    parent_id : storageAccount.id
    group_id : 'file'
    subnet_id: subnet_id
  }
}

module pedfs '../privateEndpoints/main.bicep' = {
  name: 'pedfs-deployment'
  params:{
    location: location
    privateEndpoints_pefile_name : pedfs_name
    parent_id : storageAccount.id
    group_id : 'dfs'
    subnet_id: subnet_id
  }
}

output storageId string = storageAccount.id
output storageName string = storageAccount.name
output storage object = storageAccount
