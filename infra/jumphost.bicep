param naming object
param location string = resourceGroup().location
param tags object = {}
param subnetId string
param adminUsername string = 'bellsadmin'
@secure()
param adminPassword string = ''

var resourceNames = {
  nicName: 'BellsStgNeJuHst-nic'
  ipConfigurationName: 'BellsStgNeJuHst-nic-ipconfig'
  vmName: 'BellsStgNeJuHst'
}

resource BellsStgNeJuHstnic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: resourceNames.nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: resourceNames.ipConfigurationName
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}


resource BellsStgNeJuHst 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: resourceNames.vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_F4s_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: 'win10-21h2-pro'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: resourceNames.vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
        enableVMAgentPlatformUpdates: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: BellsStgNeJuHstnic.id
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
