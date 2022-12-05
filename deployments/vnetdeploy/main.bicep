@description('Location for the deployment')
param location string
@description('Name of the Virtual Network')
param vNetName string
@description('Address Prefix of the Vnet')
param addressPrefix string
@description('Default Subnet Name')
param defaultSubnetName string
@description('Address prefix for the subnet')
param addressPrefixDefaultSubnet string
@description('Name of the PE Subnet')
param peSubnetName string
@description('Address prefix for the PE Subnet')
param addressPrefixPESubnet string
@description('Name of the BE Subnet')
param beSubnetName string
@description('Address prefix for the BE Subnet')
param addressPrefixBESubnet string
@description('Name of the FE Subnet')
param feSubnetName string
@description('Address prefix for the FE Subnet')
param addressPrefixFESubnet string
@description('Name of the PLS Subnet')
param plsSubnetName string
@description('Address prefix for the PLS Subnet')
param addressPrefixPLSSubnet string

module resourcegroup '../../modules//virtualNetwork/main.bicep' = {
  name: 'vnet-deployment'
  params:{
    location              : location
    vNetName              : vNetName
    addressPrefix         : addressPrefix
    subnetName            : defaultSubnetName
    addressPrefixSubnet   : addressPrefixDefaultSubnet
    peSubnetName          : peSubnetName
    addressPrefixPESubnet : addressPrefixPESubnet
    beSubnetName          : beSubnetName
    addressPrefixBESubnet : addressPrefixBESubnet
    feSubnetName          : feSubnetName
    addressPrefixFESubnet : addressPrefixFESubnet
    plsSubnetName         : plsSubnetName
    addressPrefixPLSSubnet: addressPrefixPLSSubnet
  }
}
