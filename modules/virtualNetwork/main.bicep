param virtualNetworks_myvnet_name string
param location string
param address_prefix string
param default_subnet_name string
param address_prefix_default_subnet string
param pe_subnet_name string
param address_prefix_pe_subnet string
param be_subnet_name string
param address_prefix_be_subnet string
param fe_subnet_name string
param address_prefix_fe_subnet string
param pls_subnet_name string
param address_prefix_pls_subnet string

resource virtualNetworks_myvnet_name_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworks_myvnet_name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        address_prefix
      ]
    }
    subnets: [
      {
        name: default_subnet_name
        properties: {
          addressPrefix: address_prefix_default_subnet
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: pe_subnet_name
        properties: {
          addressPrefix: address_prefix_pe_subnet
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: be_subnet_name
        properties: {
          addressPrefix: address_prefix_be_subnet
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: fe_subnet_name
        properties: {
          addressPrefix: address_prefix_fe_subnet
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: pls_subnet_name
        properties: {
          addressPrefix: address_prefix_pls_subnet
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
