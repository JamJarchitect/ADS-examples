targetScope = 'resourceGroup'

param parMyOrgTla string

param parLocation string

param parNumberOfHosts int

param parDomain string

param parDomainAdminUPN string

param parAdminUsername string

@secure()
param parAdminPassword string

resource avdpocvnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = {
  name: '${parMyOrgTla}-avd-vnet/avd-poc-subnet1'
}

resource avdhp 'Microsoft.DesktopVirtualization/hostPools@2022-02-10-preview' existing = {
  name: '${parMyOrgTla}-avd-ms-hp1'
}

output avdhptoken object = avdhp.properties.registrationInfo

resource avdsessionhostnics 'Microsoft.Network/networkInterfaces@2021-08-01' = [for i in range(0, parNumberOfHosts): {
  name: '${parMyOrgTla}avdmsnic${i}'
  location: parLocation
  properties: {
    ipConfigurations: [
      {
        name: 'config'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: avdpocvnet.id
          }
        }
      }
    ]
  }
}]

resource avdsessionhosts 'Microsoft.Compute/virtualMachines@2021-11-01' = [for i in range(0, parNumberOfHosts): {
  name: '${parMyOrgTla}avdms${i}'
  location: parLocation
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'microsoftwindowsdesktop'
        offer: 'office-365'
        sku: 'win10-21h2-avd-m365'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        diskSizeGB: 127
        osType: 'Windows'
      }
    }
    osProfile: {
      computerName: '${parMyOrgTla}avdms${i}'
      adminUsername: parAdminUsername
      adminPassword: parAdminPassword
      allowExtensionOperations: true
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          assessmentMode: 'ImageDefault'
          patchMode: 'AutomaticByOS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: avdsessionhostnics[i].id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    licenseType: 'Windows_Client'
  }
}]

resource avdshjoindomain 'Microsoft.Compute/virtualMachines/extensions@2018-10-01' = [for i in range(0, parNumberOfHosts):{
  name: '${avdsessionhosts[i].name}/joindomain'
  location: parLocation
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      name: parDomain
      ouPath: ''
      user: parDomainAdminUPN
      restart: true 
      options: 3
    }
    protectedSettings: {
      password: parAdminPassword
    }
  }
}]
