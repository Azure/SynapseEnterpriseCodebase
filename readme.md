
This codebase is created to convert the Azure Analytics Infrastructure as code and automate the deployment of an enterprise grade Synaspe Workspace.

We can test this codebase through the deploy.ps1 file
1. Open a Powershell console and run the deploy.ps1 file
Usage : ./deploy.ps1 resourcegroup location environment projectcode

Now, we will explain each section of this deployment.
According to the folder structure we have five main components:
1.	modules [Folder]
2.	environments [Folder]
3.	deployments [Folder]
4.	deploy.ps1

•	Modules [Folder]
This section will contain all the modules we want to deploy through the code. Let’s evaluate the contents within the modules folder:

<img src="https://dev.azure.com/ssamadda/9babd695-135e-422b-986d-28bdea4cd910/_apis/git/repositories/341b468b-4b8e-4141-8923-3584866cc2e5/items?path=/Images/modulestructure.jpg&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=BicepTemplate&resolveLfs=true&%24format=octetStream&api-version=5.0"/>  

We can see we have added the below resources as modules:
1.	OneTimeSetup-Natvms
This is an one-time setup module where we will define the Nat-VMs along with the load balancers. 
 
2.	privateEndpoints
This is a module which will define the private endpoints resources. 
 
3.	resourceGroup (Optional, only use if are creating infrastructure from scratch) 
This is a module which will define the target resourcegroup for all the resources. 
 
4.	Storage
This is a module which will define the Azure Storage needed for the deployment. 
 
5.	Synapse
This is a module which will define the Azure Synapse Workspace deployment. 
 
6.	Virtual Network (Optional, only use if are creating infrastructure from scratch)
This is a module which will define the Azure Virtual Network and associated subnets for the deployment. 
 
•	environments [Folder]
This section will define the environment variables that we need for different types of environments. The concept is that the module will be same but the environment variables will be different from one environment to another. Please find the files we need for the dev environment, we have considered one environment in this document: Dev , you may extend it to use other environments.

<img src="https://dev.azure.com/ssamadda/9babd695-135e-422b-986d-28bdea4cd910/_apis/git/repositories/341b468b-4b8e-4141-8923-3584866cc2e5/items?path=/Images/environmentStructure.jpg&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=BicepTemplate&resolveLfs=true&%24format=octetStream&api-version=5.0"/>  

•	deployments [Folder]
This section will define what we want to deploy. So we can pick and choose different modules and combine them and create different types of deployment based on the needs. As from the below screenshot you will find that we have two different deployments here. One is Synapse workspace, private endpoint, storage and the natvms, and another for the optional Vnet & resource group

<img src="https://dev.azure.com/ssamadda/9babd695-135e-422b-986d-28bdea4cd910/_apis/git/repositories/341b468b-4b8e-4141-8923-3584866cc2e5/items?path=/Images/deploymentStructure.jpg&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=BicepTemplate&resolveLfs=true&%24format=octetStream&api-version=5.0"/>  

•	deploy.ps1
This file is responsible for the overall deployment. The usage of this file is :  ./deploy.ps1 resourcegroup location environment projectcode
This will deploy the below resources:
-	ResourceGroup
-	Vnets & Subnets
-	Storage Tiers (Bronze, Silver and Gold)
-	Synapse Workspace
-	Private Endpoints
-	Nat VMs
-	Self Hosted Integration Runtime resource
 
Important Notes and few Assumptions for this deployment section : 
1. VNet and Subnets are already created, the code is already present and commented. So only use it if required.
2. Disable private endpoint network policies are set to true for the subnets    
    The Command below will do it if not yet done, we can add this as part of the initial setup along with creation of resoucegroup, VNet and Subnet.    
    "az network vnet subnet update --disable-private-endpoint-network-policies true --name <pesubnet name> --resource-group <resourcegroup name> --vnet-name <vnet name>"
3. This template will deploy 
    1. An azure synapse workspace, SHIR VM and primary storage. (Managed VNet and private endpoints included)
    2. Three tiers of storage along with the private endpoints
    3. Basic SHIR Configuration from Synapse side. Refer: https://docs.microsoft.com/en-us/azure/data-factory/create-self-hosted-integration-runtime?tabs=data-factory 
    4. Creation of Nat VMs along with Load Balancer. Need to configure the scripts in the nat vms. Please refer https://docs.microsoft.com/en-us/azure/data-factory/tutorial-managed-virtual-network-on-premise-sql-server 
4. DNS configurations are excluded from this template.
5. Managed Private Endpoints and Linked service should be implemented as need basis and manually
6. Test cases are not included in this template
7. Regarding reusing existing ARM templates-----------------------------------------------
    If you have an arm .json template file you can convert it back to .bicep with the below command
    "az bicep decompile --file <template name>.json"
    please refer this for further reference.

Pricing Calculator for the above deployed resources : [https://azure.microsoft.com/en-us/pricing/calculator/Synapse%20ESLZ](https://azure.com/e/2bedfc1bc49c41ca95a6196f393065dd)
