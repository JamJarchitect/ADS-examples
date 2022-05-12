targetScope = 'subscription'

param parLocation string

@allowed([
  'POC'
  'ADS'
  'MVP'
])
param parDeploymentType string 

var varHubVnetRgName = '${parDeploymentType}-hub-rg'
var varSpoke1VnetRgName = '${parDeploymentType}-spoke1-rg'
var varHubVnetName = '${parDeploymentType}-hub-vnet'
var varSpoke1VnetName = '${parDeploymentType}-spoke1-vnet'

resource hubvnetrg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: varHubVnetRgName
  location: parLocation
}

resource spoke1vnetrg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: varSpoke1VnetRgName
  location: parLocation
}

module hubvnetdeploy 'hubvnet.bicep' = {
  scope: resourceGroup(hubvnetrg.name)
  name: 'hubvnetdeploy'
  params:{
    parLocation: parLocation
    parSpoke1VnetName: varSpoke1VnetName
    parSpoke1VnetRg: varSpoke1VnetRgName
    parHubVnetName: varHubVnetName
  }
}

module spoke1vnetdeploy 'spoke1vnet.bicep' = {
  scope: resourceGroup(spoke1vnetrg.name)
  name: 'spoke1vnetdeploy'
params:{
  parLocation: parLocation
  parHubVnetRg: varHubVnetRgName
  parSpoke1VnetName: varSpoke1VnetName
  parHubVnetName: varHubVnetName
}
}
