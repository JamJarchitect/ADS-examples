targetScope = 'subscription'

param parLocation string

param parNumberOfSpokes int

@allowed([
  'POC'
  'ADS'
  'MVP'
])
param parDeploymentType string

var varHubVnetRgName = '${parDeploymentType}-hub-rg'
var varHubVnetName = '${parDeploymentType}-hub-vnet'

resource hubvnetrg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: varHubVnetRgName
  location: parLocation
}

resource spokevnetrg 'Microsoft.Resources/resourceGroups@2021-04-01' = [for i in range(0, parNumberOfSpokes): {
  name: '${parDeploymentType}-spoke${i}-rg'
  location: parLocation
}]

module hubvnetdeploy 'hubvnet.bicep' = {
  scope: resourceGroup(hubvnetrg.name)
  name: 'hubvnetdeploy'
  params: {
    parLocation: parLocation
    parHubVnetName: varHubVnetName
  }
}

module spokevnetdeploy 'spokevnet.bicep' = [for i in range(0, parNumberOfSpokes): {
  scope: resourceGroup('${parDeploymentType}-spoke${i}-rg')
  dependsOn: [
    spokevnetrg
  ]
  name: 'spokevnetdeploy'
  params: {
    parDeploymentType: parDeploymentType
    parSpokeNumber: '${i}'
    parLocation: parLocation
  }
}]

module hubVnetPeering 'vnetPeering.bicep' = [for i in range(0, parNumberOfSpokes): {
  scope: resourceGroup(hubvnetrg.name)
  dependsOn: [
   spokevnetdeploy 
  ]
  name: 'hubpeerings${i}'
  params: {
    parAllowForwardedTraffic: true
    parAllowGatewayTransit: true
    parAllowVirtualNetworkAccess: true 
    parDestinationVirtualNetworkID: '${subscription().id}/resourceGroups/${parDeploymentType}-spoke${i}-rg/providers/Microsoft.Network/virtualNetworks/${parDeploymentType}-spoke${i}-vnet'
    parDestinationVirtualNetworkName: '${parDeploymentType}-spoke${i}-vnet'
    parSourceVirtualNetworkName: varHubVnetName
    parUseRemoteGateways: false
  }
}]

module spokeVnetsPeering 'vnetPeering.bicep' = [for i in range(0, parNumberOfSpokes): {
  scope: resourceGroup('${parDeploymentType}-spoke${i}-rg')
  name: 'spoketohubpeerings'
  dependsOn: [
    hubVnetPeering
  ]
  params: {
    parAllowForwardedTraffic: true 
    parAllowGatewayTransit: true
    parAllowVirtualNetworkAccess: true 
    parDestinationVirtualNetworkID: '${subscription().id}/resourceGroups/${varHubVnetRgName}/providers/Microsoft.Network/virtualNetworks/${varHubVnetName}'
    parDestinationVirtualNetworkName: varHubVnetName
    parSourceVirtualNetworkName: '${parDeploymentType}-spoke${i}-vnet'
    parUseRemoteGateways: false
  }
}]
