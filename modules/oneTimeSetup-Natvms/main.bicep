@description('Name of the First Nat VM')
param vmFirstNatVMName string
@description('Name of the Second Nat VM')
param vmSecondNatVMName string
@description('Location of the deployment')
param location string
@description('ssh public key name for first VM') 
param sshPublicKeyFirstVMName string
@description('ssh public key name for second VM') 
param sshPublicKeySecondVMName string 
@description('Load Balancer name')
param loadBalancerName string
@description('UserName for the VMs')
param userName string = 'azureuser'
@description('public key for the first VM')
param publicKeyVM1 string 
@description('public key for the second VM')
param publicKeyVM2 string 
@description('Subnet for the NIC')
param nicSubnet string 
@description('Name of the private Link Service')
param privateLinkServicesName string
@description('Subscription ID of the deployment')

resource sshPublicKeyFirstVMResource 'Microsoft.Compute/sshPublicKeys@2021-11-01' = {
  name: sshPublicKeyFirstVMName
  location: location
  properties: {
    publicKey: publicKeyVM1
  }
}

resource sshPublicKeySecondVMResource 'Microsoft.Compute/sshPublicKeys@2021-11-01' = {
  name: sshPublicKeySecondVMName
  location: location
  properties: {
    publicKey: publicKeyVM2
  }
}

resource firstVMResource 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmFirstNatVMName
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
        name: '${vmFirstNatVMName}_OsDisk_1_d7ba073cf8864bb59abce99789fac5e0'
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
      computerName: vmFirstNatVMName
      adminUsername: userName
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/azureuser/.ssh/authorized_keys'
              keyData: publicKeyVM1
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
  name: '${vmFirstNatVMName}vmnic001'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig3'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          
          subnet: {
            id: nicSubnet
          }
          loadBalancerBackendAddressPools: [
            {
              id: loadBalancersName.id
            }
          ]
        }
      }
    ]
  }
}

resource secondVMResource 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmSecondNatVMName
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
        name: '${vmSecondNatVMName}_OsDisk_1_8419dfefd51f4bb89ed071ecf1b2f022'
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
      computerName: vmSecondNatVMName
      adminUsername: userName
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/azureuser/.ssh/authorized_keys'
              keyData: publicKeyVM2
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
  name: '${vmSecondNatVMName}vmnic002'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig4'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          
          subnet: {
            id: nicSubnet
          }
          loadBalancerBackendAddressPools: [
            {
              id: loadBalancersName.id
            }
          ]
        }
      }
    ]
  }
}

resource loadBalancersName 'Microsoft.Network/loadBalancers@2020-11-01' = {
  name: loadBalancerName
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
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: nicSubnet
          }
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backendpool'        
      }
    ]
    loadBalancingRules: []
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
  parent: loadBalancersName  
}

resource privateLinkServicesName_resource 'Microsoft.Network/privateLinkServices@2020-11-01' = {
  name: privateLinkServicesName
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
        id: '${loadBalancersName.id}/frontendIPConfigurations/frontendip1'
      }
    ]
    ipConfigurations: [
      {
        name: 'pls-subnet-1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: nicSubnet
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
  }
}
