@description('Name of the virtual network')
param vNetName string
@description('location of the deployment')
param location string
@description('Address prefix of the Vnet')
param addressPrefix string
@description('Name of the subnet')
param subnetName string
@description('Address prefix of the subnet')
param addressPrefixSubnet string
@description('Name of the PE subnet')
param peSubnetName string
@description('Address prefix of the PE subnet')
param addressPrefixPESubnet string
@description('Name of the BE subnet')
param beSubnetName string
@description('Address prefix of the BE subnet')
param addressPrefixBESubnet string
@description('Name of the FE subnet')
param feSubnetName string
@description('Address prefix of the FE subnet')
param addressPrefixFESubnet string
@description('Name of the PLS subnet')
param plsSubnetName string
@description('Address prefix of the PLS subnet')
param addressPrefixPLSSubnet string

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: addressPrefixSubnet
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: peSubnetName
        properties: {
          addressPrefix: addressPrefixPESubnet
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: beSubnetName
        properties: {
          addressPrefix: addressPrefixBESubnet
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: feSubnetName
        properties: {
          addressPrefix: addressPrefixFESubnet
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: plsSubnetName
        properties: {
          addressPrefix: addressPrefixPLSSubnet
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}
