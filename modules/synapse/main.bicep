@description('Location of the deployment')
param location string
@description('Name of the primary storage account')
param primaryStorageAccountName string
@description('Retention days limit')
param retentionDays int
@description('Private Endpoint name for Blob storage')
param peBlobName string
@description('Private Endpoint name for File storage')
param peFileName string
@description('Private Endpoint name for DFS storage')
param peDFSName string
@description('Subnet ID where the PE will be deployed')
param subnetId string
@description('Name of the Synapse Workspace')
param workspaceName string
@description('Name of the primary File system')
param fileSystemName string
@description('PE name for the Synapse Dev')
param peSynapseDevName string
@description('PE name for the Synapse SQL')
param peSynapseSQLName string
@description('PE name for the Synapse SQL on demand')
param peSynapseSQLOnDemandName string
@description('Tenant ID for the deployment')
param tenantId string
@description('Username for the Synapse Dedicated Pool')
param userName string
@description('Password for the Synapse Dedicated Pool')
@secure()
param password string
@description('Subnet ID for the SHIR runtime VM')
param runtimeSubnetId string
@description('Project Code for the deployment')
param projectCode string

module primaryStorage '../storage/main.bicep' = {
  name: 'primaryStorage-Deployment'
  params:{
    location: location
    storageAccountName: primaryStorageAccountName
    retentionDays: retentionDays
    peBlobName: peBlobName
    peFileName: peFileName
    peDFSName: peDFSName
    subnetId: subnetId
  }
}

@description('variable used for creating unique names')
var core = 'core'
@description('variable used for creating unique names')
var accountURL = 'https://${primarystorage.outputs.storageName}.dfs.${core}.windows.net'

resource synapsews 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: workspaceName
  location: location
  tags: {
    Tag1: 'automated'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      resourceId: primaryStorage.outputs.storageId
      createManagedPrivateEndpoint: true
      accountUrl: accountURL
      filesystem: fileSystemName
    }
    encryption: {}
    managedVirtualNetwork: 'default'
    sqlAdministratorLogin: 'sqladminuser'
    sqlAdministratorLoginPassword: ''
    privateEndpointConnections: [
      {
        properties: {
          privateEndpoint: {}
          privateLinkServiceConnectionState: {
            status: 'Approved'
          }
        }
      }
      {
        properties: {
          privateEndpoint: {}
          privateLinkServiceConnectionState: {
            status: 'Approved'
          }
        }
      }
      {
        properties: {
          privateEndpoint: {}
          privateLinkServiceConnectionState: {
            status: 'Approved'
          }
        }
      }
    ]
    managedVirtualNetworkSettings: {
      preventDataExfiltration: true
      allowedAadTenantIdsForLinking: [
        tenantId
      ]
    }
    publicNetworkAccess: 'Disabled'
    azureADOnlyAuthentication: false
    trustedServiceBypassEnabled: false
  }
}

module pesynapseDev '../privateEndpoints/main.bicep' = {
  name: 'peDev-deployment'
  params:{
    location: location
    privateEndpoints_pefile_name : peSynapseDevName
    parent_id : synapsews.id
    group_id : 'Dev'
    subnet_id: subnet_id
  }
}

module pesynapseSql '../privateEndpoints/main.bicep' = {
  name: 'peSql-deployment'
  params:{
    location: location
    privateEndpoints_pefile_name : peSynapseSQLName
    parent_id : synapsews.id
    group_id : 'Sql'
    subnet_id: subnet_id
  }
}

module pesynapseSqlOnDemand '../privateEndpoints/main.bicep' = {
  name: 'peSqlOnDemand-deployment'
  params:{
    location: location
    privateEndpoints_pefile_name : peSynapseSQLOnDemandName
    parent_id : synapsews.id
    group_id : 'Sql'
    subnet_id: subnet_id
  }
}

resource ApachePool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {
  name: '${workspaceName}/${projectCode}pool'
  location: location
  properties: {
    sparkVersion: '3.1'
    nodeCount: 10
    nodeSize: 'Small'
    nodeSizeFamily: 'MemoryOptimized'
    autoScale: {
      enabled: true
      minNodeCount: 3
      maxNodeCount: 10
    }
    autoPause: {
      enabled: true
      delayInMinutes: 15
    }
    isComputeIsolationEnabled: false
    sessionLevelPackagesEnabled: true
    cacheSize: 10
    dynamicExecutorAllocation: {
      enabled: true
      minExecutors: 1
      maxExecutors: 4
    }
    provisioningState: 'Succeeded'
  }
  dependsOn: [
    synapsews
  ]
}

resource workspaces_manualsynapsews_name_Dedicated_SQL_Pool 'Microsoft.Synapse/workspaces/sqlPools@2021-06-01' = {
  name: '${workspaceName}/${projectCode}DedicatedSQLPool'
  location: location
  sku: {
    name: 'DW100c'
    capacity: 0
  }
  properties: {
    maxSizeBytes: 263882790666240
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    storageAccountType: 'LRS'
    provisioningState: 'Succeeded'
  }
  dependsOn: [
    synapsews
  ]
}

resource shirVM 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: '${projectCode}shirvm'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2_v3'
    }
    osProfile: {
      computerName: '${projectCode}shirvm'
      adminUsername: userName
      adminPassword: password
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [
        {
          diskSizeGB: 32
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${projectCode}myshirvmnic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          
          subnet: {
            id: runtimeSubnetId
          }
        }
      }
    ]
  }
}


