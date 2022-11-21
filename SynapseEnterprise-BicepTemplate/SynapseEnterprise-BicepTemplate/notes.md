Assumptions & Notes: Version 0.3

1. VNet and Subnets are already created , the code is already present and commented. So only use it if require.

2. Disable private endpoint network policies are set to true for the subnets    
    The Command below will do it if not yet done, we can add this as part of the initial setup along with creation of resoucegroup, VNet and Subnet.    
    "az network vnet subnet update --disable-private-endpoint-network-policies true --name <pesubnet name> --resource-group <resourcegroup name> --vnet-name <vnet name>"

3. This template will deploy 
    1. An azure synapse workspace, SHIR VM and a primary storage. (Managed Vnet and private endpoints included)
    2. Three tiers of storage along with the private endpoints
    3. Basic SHIR Configuration from Synapse side. Refer: https://docs.microsoft.com/en-us/azure/data-factory/create-self-hosted-integration-runtime?tabs=data-factory 
    4. Creation of Nat VMs along with Load Balancer. Need to configure the scripts in the nat vms. Please refer https://docs.microsoft.com/en-us/azure/data-factory/tutorial-managed-virtual-network-on-premise-sql-server 

4. DNS configurations are excluded from this template.

5. Managed Private Endpoints and Linked service should be implemented as need basis and manually
https://docs.microsoft.com/en-us/azure/synapse-analytics/security/synapse-workspace-managed-private-endpoints
https://docs.microsoft.com/en-us/azure/synapse-analytics/data-integration/linked-service

6. Test cases are not included in this template

Regarding resuing existing ARM templates-----------------------------------------------

    If you have a arm .json template file you can convert it back to .bicep with the below command
    "az bicep decompile --file <template name>.json"
    please refer https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/decompile?tabs=azure-cli for further reference.

 


