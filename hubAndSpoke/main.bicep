targetScope = 'subscription'

param location string

@allowed([
  'POC'
  'ADS'
  'MVP'
])
param deploymenttype string 

resource hubvnetrg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${deploymenttype}-hubvnet-rg'
  location: location
}

module hubvnetdeploy 'hubvnet.bicep' = {
  scope: resourceGroup(hubvnetrg.name)
  name: 'hubvnetdeploy'
  params: {
    location: location
    hubvnetname: '${deploymenttype}-hub-vnet'
  }
}
