targetScope = 'subscription'

param location string

@allowed([
  'POC'
  'ADS'
  'MVP'
])
param deploymenttype string 

var varHubVnetRgName = '${deploymenttype}-hub-rg'
var varSpoke1VnetRgName = '${deploymenttype}-spoke1-rg'
var varHubVnetName = '${deploymenttype}-hub-vnet'
var varSpoke1VnetName = '${deploymenttype}-spoke1-vnet'

resource hubvnetrg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: varHubVnetRgName
  location: location
}

resource spoke1vnetrg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: varSpoke1VnetRgName
  location: location
}

module hubvnetdeploy 'hubvnet.bicep' = {
  scope: resourceGroup(hubvnetrg.name)
  name: 'hubvnetdeploy'
  params: {
    spoke1vnetname: varSpoke1VnetName
    spoke1vnetrg: varSpoke1VnetRgName
    location: location
    hubvnetname: varHubVnetName
  }
}

module spoke1vnetdeploy 'spoke1vnet.bicep' = {
  scope: resourceGroup(spoke1vnetrg.name)
  name: 'spoke1vnetdeploy'
  params: {
    hubvnetname: varHubVnetName
    hubvnetrg: varHubVnetRgName
    location: location
    spoke1vnetname: varSpoke1VnetName
  }
}
