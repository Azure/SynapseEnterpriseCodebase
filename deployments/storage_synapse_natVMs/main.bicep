@description('Subscription ID for the deployment')
param subscriptionId string
@description('Project code of the deployment, it helps for project specific deployment')
param projectCode string
@description('Name of the Vnet')
param vnetName string
@description('Name of the subnet for PE deployment')
param peSubnetName string
@description('Tenant ID for the deployment')
param tenantId string
@description('Subnet name for the SHIR')
param runtimeSubnetName string
@description('Retention Days Limit')
param retentionDays int
@description('Location of the deployment')
param location string = resourceGroup().location
@description('SHIR username for the VM')
param shirUserName string
@description('Password for the SHIR VM')
@secure()
param shirPassword string

@description('Variable for PE Subnet')
var peSubnetId      = '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/${vnetName}/subnets/${peSubnetName}'
@description('Variable for SHIR subnet')
var runtimeSubnetId = '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/${vnetName}/subnets/${runtimeSubnetName}'


// Bronze Storage variables
var storageAccountBronze = '${projectCode}bronzestorage'
var peBlobBronze         = '${storageAccountBronze}peblob'
var peFileBronze         = '${storageAccountBronze}pefile'
var peDFSBronze          = '${storageAccountBronze}pedfs'

module bronzeStorage '../../modules/storage/main.bicep' = {
  name: 'bronzestorage-deployment'
  params:{
    location           : location
    storageAccountName : storageAccountBronze
    retentionDays      : retentionDays
    peBlobName         : peBlobBronze
    peFileName         : peFileBronze
    peDFSName          : peDFSBronze
    subnetId           : peSubnetId
  }
}


//Silver Storage variables
var storageAccountSilver = '${projectCode}silverstorage'
var peBlobSilver         = '${storageAccountSilver}peblob'
var peFileSilver         = '${storageAccountSilver}pefile'
var peDFSSilver          = '${storageAccountSilver}pedfs'

module silverStorage '../../modules/storage/main.bicep' = {
  name: 'silverstorage-deployment'
  params:{
    location           : location
    storageAccountName : storageAccountSilver
    retentionDays      : retentionDays
    peBlobName         : peBlobSilver
    peFileName         : peFileSilver
    peDFSName          : peDFSSilver
    subnetId           : peSubnetId
  }
  dependsOn: [
    bronzeStorage
  ]
}

//Gold Storage
var storageAccountGold = '${projectCode}goldstorage'
var peBlobGold         = '${storageAccountGold}peblob'
var peFileGold         = '${storageAccountGold}pefile'
var peDFSGold          = '${storageAccountGold}pedfs'

module goldStorage '../../modules/storage/main.bicep' = {
  name: 'goldstorage-deployment'
  params:{
    location           : location
    storageAccountName : storageAccountGold
    retentionDays      : retentionDays
    peBlobName         : peBlobGold
    peFileName         : peFileGold
    peDFSName          : peDFSGold
    subnetId           : peSubnetId
  }
  dependsOn: [
    bronzeStorage
    silverStorage
  ]
}

//Synapse Workspace variables
var primaryStorageAccountName = '${projectCode}primstorage'
var peBlobPrim                = '${primaryStorageAccountName}peblob'
var peFilePrim                = '${primaryStorageAccountName}pefile'
var peDFSPrim                 = '${primaryStorageAccountName}pedfs'
var workspaceName             = '${projectCode}synapsews'
var fileSystemName            = 'adlsdata'
var peSynapseDevName          = '${primaryStorageAccountName}pesynapseDev'
var peSynapseSQLName          = '${primaryStorageAccountName}pesynapseSQL'
var peSynapseSQLOnDemandName  = '${primaryStorageAccountName}pesynapseSQLOnDemand'


module synapsews '../../modules/synapse/main.bicep' = {
  name: 'synapse-deployment'
  params:{
    location                  : location
    primaryStorageAccountName : primaryStorageAccountName
    retentionDays             : retentionDays
    peBlobName                : peBlobPrim
    peFileName                : peFilePrim
    peDFSName                 : peDFSPrim
    subnetId                  : peSubnetId
    workspaceName             : workspaceName
    fileSystemName            : fileSystemName
    peSynapseDevName          : peSynapseDevName
    peSynapseSQLName          : peSynapseSQLName
    peSynapseSQLOnDemandName  : peSynapseSQLOnDemandName
    tenantId                  : tenantId
    userName                  : shirUserName
    password                  : shirPassword
    runtimeSubnetId           : runtimeSubnetId
    projectCode               : projectCode
  }
  dependsOn: [
    bronzeStorage
    silverStorage
    goldStorage
  ]
}

//OneTime Setup variables
var vmFirstNatVMName         = '${projectCode}NatVM1'
var vmSecondNatVMName        = '${projectCode}NatVM2'
var sshPublicKeyFirstVMName  = '${projectCode}sshKey1'
var sshPublicKeySecondVMName = '${projectCode}sshKey2'
var loadBalancerName         = '${projectCode}loadbalancer'
@description('Random keys generate, we can change it with our own keys also')
var publicKeyVM1             = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCY0lHjkKnhakYw4Fnoq8Z2d8Tu\r\nuSvdlcPmXZRd8ni3E4o0bJepDHKbkNrRUtGbUTWf5MlWmsGHiuMhumT/XIa8c9ZE\r\nXRYBljMbmbUq10EwJV1uMEyGjHd6YuqaaSdoKy1Y8bN31l13AUpVgoKff7yG3SzO\r\n39pTCn2kEZUlSkcyyLSX5/A033iz8xPKbvZObBB0l0/xzOnbIBknzq6qwgdIwoXx\r\n7qZpHBTHY8eTJumM5qen9J+USGhVLbxxLQJwH23l7GexdgJjXFPDa2ctItajsaZ4\r\nS2PasO1U5Ieel8d/k9G+CUYR/jt7xrc8/Y1+Hm/5wizTS8JWCJKC9VL0QT8Vg3Of\r\n7WmnN6W/xW9eTxiMR99gZyGwNlCaBW7o0et7nyIEdqu/PBePUX+ZCjlRtUR1fhZK\r\n3DrgGCJwjrcr2M4z2oCcCtj3Te7R7GQqzaL8sqDoZk/4kYe963cQCGerjabCrul9\r\nsEKRqfJdRvXBtOvyAC1bSPPSImx5HWt+ENTu05E= generated-by-azure\r\n'
@description('Random keys generate, we can change it with our own keys also')
var publicKeyVM2             = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDYnHRt0voiv9D0+/+luLtR0LgW\r\ngDxTAKQnRq7JljHtjbM1v/MHm0WCGgLH7uj4perj/it/Jke0PUWRcZOW2FBjvd6R\r\nfFwxB3hEnSOj4dFNvwIzwb0bdLVMGtMEif5VxF9jCSiMvA/+fNi6ofJrhxmZLnmJ\r\nKru7LbsJtqYBd7eW/06Ff698V9lVhfpgoT/1LWWUV2eksrcB6+f624/LeS58Hb7i\r\nLxzDxUr8nYSSxGno2XF31U6J6LO4ghWJ33DLoIPcdiJolmefHtFnAM7G4Cvzj7At\r\nKHq39yA2FipOtwAhFuIjNUpKyKaa3Qpv/5b6uLOoN+e9WMVfN3f2r8z6Nv1f5Imd\r\ntA/xrPNW8D6xZRDwWJLCiXgjqX0uUwXNPvIrqTvFHJLOIOHQUZoh4Z+I7+Rj4ltC\r\nSr49jwy1VKUdLMbJGw37S8ACbiGM7c3jrAhs+NvCg7JN8Y0AvEhfxNq7hNr4+Ocv\r\nBgh60ZvlXa2WytzN60CM3oSbsrNaOO4/nCUNvxU= generated-by-azure\r\n'
var privateLinkServicesName  = '${projectCode}natVMLinkService'

module oneTimeSetup '../../modules/oneTimeSetup-Natvms/main.bicep' = {
  name: 'onetime-deployment'
  params:{
    location                : location    
    vmFirstNatVMName        : vmFirstNatVMName
    vmSecondNatVMName       : vmSecondNatVMName
    sshPublicKeyFirstVMName : sshPublicKeyFirstVMName
    sshPublicKeySecondVMName: sshPublicKeySecondVMName
    loadBalancerName        : loadBalancerName
    publicKeyVM1            : publicKeyVM1
    publicKeyVM2            : publicKeyVM2
    nicSubnet               : runtimeSubnetId
    privateLinkServicesName : privateLinkServicesName
  }
  dependsOn: [
    bronzeStorage
    silverStorage
    goldStorage
    synapsews
  ]
}



