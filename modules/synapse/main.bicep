param location string
param primarystorageAccount_name string
param retention_days int
param peblob_name string
param pefile_name string
param pedfs_name string
param subnet_id string
param workspaces_name string
param filesystem_name string
param pesynapseDev_name string
param pesynapseSql_name string
param pesynapseSqlOnDemand_name string
param tenantID string
param username string

@secure()
param password string

param runtimesubnet_id string
param project_code string


module primarystorage '../storage/main.bicep' = {
  name: 'primaryStorage-Deployment'
  params:{
    location: location
    storageAccount_name: primarystorageAccount_name
    retention_days: retention_days
    peblob_name: peblob_name
    pefile_name: pefile_name
    pedfs_name: pedfs_name
    subnet_id: subnet_id
  }
}

var core = 'core'
var accountURL = 'https://${primarystorage.outputs.storageName}.dfs.${core}.windows.net'

resource synapsews 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: workspaces_name
  location: location
  tags: {
    Tag1: 'automated'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      resourceId: primarystorage.outputs.storageId
      createManagedPrivateEndpoint: true
      accountUrl: accountURL
      filesystem: filesystem_name
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
        tenantID
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
    privateEndpoints_pefile_name : pesynapseDev_name
    parent_id : synapsews.id
    group_id : 'Dev'
    subnet_id: subnet_id
  }
}

module pesynapseSql '../privateEndpoints/main.bicep' = {
  name: 'peSql-deployment'
  params:{
    location: location
    privateEndpoints_pefile_name : pesynapseSql_name
    parent_id : synapsews.id
    group_id : 'Sql'
    subnet_id: subnet_id
  }
}

module pesynapseSqlOnDemand '../privateEndpoints/main.bicep' = {
  name: 'peSqlOnDemand-deployment'
  params:{
    location: location
    privateEndpoints_pefile_name : pesynapseSqlOnDemand_name
    parent_id : synapsews.id
    group_id : 'Sql'
    subnet_id: subnet_id
  }
}

resource ApachePool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {
  name: '${workspaces_name}/${project_code}pool'
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
  name: '${workspaces_name}/${project_code}DedicatedSQLPool'
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
  name: '${project_code}shirvm'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2_v3'
    }
    osProfile: {
      computerName: '${project_code}shirvm'
      adminUsername: username
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
  name: '${project_code}myshirvmnic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          
          subnet: {
            id: runtimesubnet_id
          }
        }
      }
    ]
  }
}


