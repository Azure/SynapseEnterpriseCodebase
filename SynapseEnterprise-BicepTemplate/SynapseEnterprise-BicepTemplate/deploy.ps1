
#usage ./deploy.ps1 resourcegroup location environment projectcode

$resourcegroup = $args[0]
$location = $args[1]
$environment = $args[2]
$projectcode = $args[3]

#Onetime setup , comment it if you have rg and vnet already setup
Write-Host "Creating a Resource Group.........." -ForegroundColor yellow
az group create --name $resourcegroup --location $location --tags "Tag1"
Write-Host "ResourceGroup Created .........." -ForegroundColor green

#Creating VNet and Subnets
Write-Host "Creating VNet and Subnets .........." -ForegroundColor yellow
$deployment_name = "VnetDeployment$environment" 
az deployment group create --resource-group $resourcegroup --template-file ./deployments/vnetdeploy/main.bicep  --name $deployment_name --parameters ./environments/$environment/vnet_params.json > output.txt
Write-Host "VNet and Subnet created .........." -ForegroundColor green

#Creating Storage Tiers + Synapse Workspac + Nat VMs
$deployment_name = "DataAnalyticsDeployment$environment"
Write-Host "Creating Storage Tiers + Synapse Workspace + Nat VMs........."
az deployment group create --resource-group $resourcegroup --template-file ./deployments/storage_synapse_natVMs/main.bicep --name $deployment_name --parameters ./environments/$environment/params.json > output.txt
Write-Host "Storage Tiers + Synapse ws + NatVMs created.........." -ForegroundColor green

#Creating SHIR
Write-Host "Creating SHIR .........." -ForegroundColor yellow
$workspace = $projectcode+"synapsews"
az synapse integration-runtime create --workspace-name $workspace --resource-group $resourcegroup --name testintegrationruntime --type SelfHosted
Write-Host "SHIR Created. Please configure the VM now" -ForegroundColor green


