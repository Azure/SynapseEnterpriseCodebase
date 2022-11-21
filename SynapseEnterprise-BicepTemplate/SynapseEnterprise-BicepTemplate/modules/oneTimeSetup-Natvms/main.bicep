param virtualMachines_myVM1_name string 
param virtualMachines_myVM2_name string 
param location string 
param sshPublicKeys_myVM1_key_name string 
param sshPublicKeys_myVM2_key_name string 
param loadBalancers_newloadbalancer007_name string 
param username string = 'azureuser'
param publickeyvm1 string 
param publickeyvm2 string 
param nicsubnet string 
param privateLinkServices_newprivatelink007_name string
param subscription_id string
param resourcegroup string  


resource sshPublicKeys_myVM1_key_name_resource 'Microsoft.Compute/sshPublicKeys@2021-11-01' = {
  name: sshPublicKeys_myVM1_key_name
  location: location
  properties: {
    publicKey: publickeyvm1
  }
}

resource sshPublicKeys_myVM2_key_name_resource 'Microsoft.Compute/sshPublicKeys@2021-11-01' = {
  name: sshPublicKeys_myVM2_key_name
  location: location
  properties: {
    publicKey: publickeyvm2
  }
}

resource virtualMachines_myVM1_name_resource 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: virtualMachines_myVM1_name
  location: location
  zones: [
    '1'
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: '${virtualMachines_myVM1_name}_OsDisk_1_d7ba073cf8864bb59abce99789fac5e0'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Standard_LRS'          
        }
        deleteOption: 'Delete'
        diskSizeGB: 30
      }
      dataDisks: []
    }
    osProfile: {
      computerName: virtualMachines_myVM1_name
      adminUsername: username
      //adminPassword: password
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/azureuser/.ssh/authorized_keys'
              keyData: publickeyvm1
            }
          ]
        }
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
      }
      secrets: []
      allowExtensionOperations: true
      
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic1.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource nic1 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${virtualMachines_myVM1_name}myvmnic001'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig3'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          
          subnet: {
            id: nicsubnet
          }
          loadBalancerBackendAddressPools: [
            {
              id: loadBalancers_newloadbalancer007_name_mybackendpool.id
            }
          ]
        }
      }
    ]
  }
}

resource virtualMachines_myVM2_name_resource 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: virtualMachines_myVM2_name
  location: location
  zones: [
    '1'
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: '${virtualMachines_myVM2_name}_OsDisk_1_8419dfefd51f4bb89ed071ecf1b2f022'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
        diskSizeGB: 30
      }
      dataDisks: []
    }
    osProfile: {
      computerName: virtualMachines_myVM2_name
      adminUsername: username
      //adminPassword: password
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/azureuser/.ssh/authorized_keys'
              keyData: publickeyvm2
            }
          ]
        }
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
      }
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        { 
          id: nic2.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource nic2 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${virtualMachines_myVM2_name}myvmnic002'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig4'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          
          subnet: {
            id: nicsubnet
          }
          loadBalancerBackendAddressPools: [
            {
              id: loadBalancers_newloadbalancer007_name_mybackendpool.id
            }
          ]
        }
      }
    ]
  }
}

resource loadBalancers_newloadbalancer007_name_resource 'Microsoft.Network/loadBalancers@2020-11-01' = {
  name: loadBalancers_newloadbalancer007_name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'frontendip1'
        properties: {
          //privateIPAddress: '10.6.5.4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: nicsubnet
          }
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'mybackendpool'        
      }
    ]
    loadBalancingRules: [
      /*{
        name: 'rule1'
        properties: {
          frontendIPConfiguration: {
            id: '/subscriptions/${subscription_id}/resourceGroups/${resourcegroup}/providers/Microsoft.Network/loadBalancers/${loadBalancers_newloadbalancer007_name}/frontendIPConfigurations/frontendip1'
          }
          frontendPort: 1433
          backendPort: 1433
          enableFloatingIP: false
          idleTimeoutInMinutes: 15
          protocol: 'Tcp'
          enableTcpReset: false
          loadDistribution: 'Default'
          disableOutboundSnat: true
        }
      }*/
    ]
    probes: [
      {
        name: 'newhealthprobe'
        properties: {
          protocol: 'Tcp'
          port: 22
          intervalInSeconds: 15
          numberOfProbes: 2
        }
      }
    ]
    inboundNatRules: []
    outboundRules: []
    inboundNatPools: []
  }
}

resource loadBalancers_newloadbalancer007_name_mybackendpool 'Microsoft.Network/loadBalancers/backendAddressPools@2020-11-01' = {
  name: 'mybackendpool'
  parent: loadBalancers_newloadbalancer007_name_resource  
}

resource privateLinkServices_newprivatelink007_name_resource 'Microsoft.Network/privateLinkServices@2020-11-01' = {
  name: privateLinkServices_newprivatelink007_name
  location: location
  properties: {
    fqdns: []
    visibility: {
      subscriptions: []
    }
    autoApproval: {
      subscriptions: []
    }
    enableProxyProtocol: false
    loadBalancerFrontendIpConfigurations: [
      {
        id: '${loadBalancers_newloadbalancer007_name_resource.id}/frontendIPConfigurations/frontendip1'
      }
    ]
    ipConfigurations: [
      {
        name: 'pls-subnet-1'
        properties: {
          //privateIPAddress: '10.6.5.5'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: nicsubnet
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
  }
}
