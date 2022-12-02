param location string
param virtualNetworks_myvnet_name string
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

module resourcegroup '../../modules//virtualNetwork/main.bicep' = {
  name: 'vnet-deployment'
  params:{
    location: location
    virtualNetworks_myvnet_name: virtualNetworks_myvnet_name
    address_prefix: address_prefix
    default_subnet_name: default_subnet_name
    address_prefix_default_subnet: address_prefix_default_subnet
    pe_subnet_name: pe_subnet_name
    address_prefix_pe_subnet: address_prefix_pe_subnet
    be_subnet_name: be_subnet_name
    address_prefix_be_subnet: address_prefix_be_subnet
    fe_subnet_name: fe_subnet_name
    address_prefix_fe_subnet: address_prefix_fe_subnet
    pls_subnet_name: pls_subnet_name
    address_prefix_pls_subnet: address_prefix_pls_subnet
  }
}
