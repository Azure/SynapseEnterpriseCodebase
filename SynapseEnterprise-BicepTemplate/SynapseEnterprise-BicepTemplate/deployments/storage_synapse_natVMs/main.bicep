param subscription_id string
param project_code string
param vnet_name string
param pesubnet_name string
param tenantID string
param runtimesubnet_name string
param retention_days int
param location string = resourceGroup().location
param shirusername string
param shirpassword string

var pesubnet_id  = '/subscriptions/${subscription_id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/${vnet_name}/subnets/${pesubnet_name}'
var runtimesubnet_id = '/subscriptions/${subscription_id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/${vnet_name}/subnets/${runtimesubnet_name}'


// Bronze Storage
var storageAccount_bronze = '${project_code}bronzestorage'
var peblob_bronze = '${storageAccount_bronze}peblob'
var pefile_bronze = '${storageAccount_bronze}pefile'
var pedfs_bronze = '${storageAccount_bronze}pedfs'

module bronzestorage '../../modules/storage/main.bicep' = {
  name: 'bronzestorage-deployment'
  params:{
    location: location
    storageAccount_name: storageAccount_bronze
    retention_days: retention_days
    peblob_name: peblob_bronze
    pefile_name: pefile_bronze
    pedfs_name: pedfs_bronze
    subnet_id: pesubnet_id
  }
}


//Silver Storage
var storageAccount_silver = '${project_code}silverstorage'
var peblob_silver = '${storageAccount_silver}peblob'
var pefile_silver = '${storageAccount_silver}pefile'
var pedfs_silver = '${storageAccount_silver}pedfs'

module silverstorage '../../modules/storage/main.bicep' = {
  name: 'silverstorage-deployment'
  params:{
    location: location
    storageAccount_name: storageAccount_silver
    retention_days: retention_days
    peblob_name: peblob_silver
    pefile_name: pefile_silver
    pedfs_name: pedfs_silver
    subnet_id: pesubnet_id
  }
  dependsOn: [
    bronzestorage
  ]
}

//Gold Storage
var storageAccount_gold = '${project_code}goldstorage'
var peblob_gold = '${storageAccount_gold}peblob'
var pefile_gold = '${storageAccount_gold}pefile'
var pedfs_gold = '${storageAccount_gold}pedfs'

module goldstorage '../../modules/storage/main.bicep' = {
  name: 'goldstorage-deployment'
  params:{
    location: location
    storageAccount_name: storageAccount_gold
    retention_days: retention_days
    peblob_name: peblob_gold
    pefile_name: pefile_gold
    pedfs_name: pedfs_gold
    subnet_id: pesubnet_id
  }
  dependsOn: [
    bronzestorage
    silverstorage
  ]
}

//Synapse Workspace
var primarystorageAccount_name = '${project_code}primstorage'
var peblob_prim = '${primarystorageAccount_name}peblob'
var pefile_prim = '${primarystorageAccount_name}pefile'
var pedfs_prim = '${primarystorageAccount_name}pedfs'
var workspaces_name = '${project_code}synapsews'
var filesystem_name = 'adlsdata'
var pesynapseDev_name = '${primarystorageAccount_name}pesynapseDev'
var pesynapseSql_name = '${primarystorageAccount_name}pesynapseSQL'
var pesynapseSqlOnDemand_name = '${primarystorageAccount_name}pesynapseSQLOnDemand'


module synapsews '../../modules/synapse/main.bicep' = {
  name: 'synapse-deployment'
  params:{
    location: location
    primarystorageAccount_name: primarystorageAccount_name
    retention_days: retention_days
    peblob_name: peblob_prim
    pefile_name: pefile_prim
    pedfs_name: pedfs_prim
    subnet_id: pesubnet_id
    workspaces_name: workspaces_name
    filesystem_name: filesystem_name
    pesynapseDev_name: pesynapseDev_name
    pesynapseSql_name: pesynapseSql_name
    pesynapseSqlOnDemand_name: pesynapseSqlOnDemand_name
    tenantID: tenantID
    username: shirusername
    password: shirpassword
    runtimesubnet_id: runtimesubnet_id
    project_code: project_code
  }
  dependsOn: [
    bronzestorage
    silverstorage
    goldstorage
  ]
}

//OneTime Setup
var virtualMachines_myVM1_name = '${project_code}NatVM1'
var virtualMachines_myVM2_name = '${project_code}NatVM2'
var sshPublicKeys_myVM1_key_name = '${project_code}sshKey1'
var sshPublicKeys_myVM2_key_name = '${project_code}sshKey2'
var loadBalancers_newloadbalancer007_name = '${project_code}loadbalancer'
var publickeyvm1 = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCY0lHjkKnhakYw4Fnoq8Z2d8Tu\r\nuSvdlcPmXZRd8ni3E4o0bJepDHKbkNrRUtGbUTWf5MlWmsGHiuMhumT/XIa8c9ZE\r\nXRYBljMbmbUq10EwJV1uMEyGjHd6YuqaaSdoKy1Y8bN31l13AUpVgoKff7yG3SzO\r\n39pTCn2kEZUlSkcyyLSX5/A033iz8xPKbvZObBB0l0/xzOnbIBknzq6qwgdIwoXx\r\n7qZpHBTHY8eTJumM5qen9J+USGhVLbxxLQJwH23l7GexdgJjXFPDa2ctItajsaZ4\r\nS2PasO1U5Ieel8d/k9G+CUYR/jt7xrc8/Y1+Hm/5wizTS8JWCJKC9VL0QT8Vg3Of\r\n7WmnN6W/xW9eTxiMR99gZyGwNlCaBW7o0et7nyIEdqu/PBePUX+ZCjlRtUR1fhZK\r\n3DrgGCJwjrcr2M4z2oCcCtj3Te7R7GQqzaL8sqDoZk/4kYe963cQCGerjabCrul9\r\nsEKRqfJdRvXBtOvyAC1bSPPSImx5HWt+ENTu05E= generated-by-azure\r\n'
var publickeyvm2 = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDYnHRt0voiv9D0+/+luLtR0LgW\r\ngDxTAKQnRq7JljHtjbM1v/MHm0WCGgLH7uj4perj/it/Jke0PUWRcZOW2FBjvd6R\r\nfFwxB3hEnSOj4dFNvwIzwb0bdLVMGtMEif5VxF9jCSiMvA/+fNi6ofJrhxmZLnmJ\r\nKru7LbsJtqYBd7eW/06Ff698V9lVhfpgoT/1LWWUV2eksrcB6+f624/LeS58Hb7i\r\nLxzDxUr8nYSSxGno2XF31U6J6LO4ghWJ33DLoIPcdiJolmefHtFnAM7G4Cvzj7At\r\nKHq39yA2FipOtwAhFuIjNUpKyKaa3Qpv/5b6uLOoN+e9WMVfN3f2r8z6Nv1f5Imd\r\ntA/xrPNW8D6xZRDwWJLCiXgjqX0uUwXNPvIrqTvFHJLOIOHQUZoh4Z+I7+Rj4ltC\r\nSr49jwy1VKUdLMbJGw37S8ACbiGM7c3jrAhs+NvCg7JN8Y0AvEhfxNq7hNr4+Ocv\r\nBgh60ZvlXa2WytzN60CM3oSbsrNaOO4/nCUNvxU= generated-by-azure\r\n'
var privateLinkServices_newprivatelink007_name = '${project_code}natVMLinkService'

module oneTimeSetup '../../modules/oneTimeSetup-Natvms/main.bicep' = {
  name: 'onetime-deployment'
  params:{
    location: location
    virtualMachines_myVM1_name : virtualMachines_myVM1_name
    virtualMachines_myVM2_name : virtualMachines_myVM2_name
    sshPublicKeys_myVM1_key_name : sshPublicKeys_myVM1_key_name
    sshPublicKeys_myVM2_key_name : sshPublicKeys_myVM2_key_name
    loadBalancers_newloadbalancer007_name : loadBalancers_newloadbalancer007_name
    publickeyvm1 : publickeyvm1
    publickeyvm2 : publickeyvm2
    nicsubnet : runtimesubnet_id
    privateLinkServices_newprivatelink007_name : privateLinkServices_newprivatelink007_name
    subscription_id: subscription_id
    resourcegroup: resourceGroup().name
  }
  dependsOn: [
    bronzestorage
    silverstorage
    goldstorage
    synapsews
  ]
}



