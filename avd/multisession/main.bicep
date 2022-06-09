targetScope = 'subscription'

param parLocation string

param parMyOrgTla string

param parNumberOfHosts int

param parAdminUsername string

@secure()
param parAdminPassword string

param parDomain string

param parDomainAdminUPN string

param parDnsServerIp string

param parIdVnetName string

param parIdVnetRGName string

param parBaseTime string = utcNow('u')

var varExpirationTime = dateTimeAdd(parBaseTime, 'P15D')

resource avdpocrg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${parMyOrgTla}avdrg'
  location: parLocation
}

module avdpocvnet 'avdpocvnet.bicep' = {
  scope: resourceGroup(avdpocrg.name)
  name: 'avdpocvnetdeploy'
  params: {
    parDnsServerIp: parDnsServerIp
    parCompanyTla: parMyOrgTla
    parLocation: parLocation
  }
}

module identitytoavdpocvnetpeering 'vnetPeering.bicep' = {
  scope: resourceGroup(parIdVnetRGName)
  dependsOn: [
    avdpocvnet
  ]
  name: 'idtoavdpocvnetpeeringdeploy'
  params: {
    parAllowForwardedTraffic: true
    parAllowGatewayTransit: false
    parAllowVirtualNetworkAccess: true
    parDestinationVirtualNetworkID: '${subscription().id}/resourceGroups/${avdpocrg.name}/providers/Microsoft.Network/virtualNetworks/${parMyOrgTla}-avd-vnet'
    parDestinationVirtualNetworkName: '${parMyOrgTla}-avd-vnet'
    parSourceVirtualNetworkName: parIdVnetName
    parUseRemoteGateways: false
  }
}

module avdpocvnettoidentityvnetpeering 'vnetPeering.bicep' = {
  scope: resourceGroup(avdpocrg.name)
  dependsOn: [
    avdpocvnet
    identitytoavdpocvnetpeering
  ]
  name: 'avdpoctoidentityvnetpeeringdeploy'
  params: {
    parAllowForwardedTraffic: true
    parAllowGatewayTransit: false
    parAllowVirtualNetworkAccess: true
    parDestinationVirtualNetworkID: '${subscription().id}/resourceGroups/${parIdVnetRGName}/providers/Microsoft.Network/virtualNetworks/${parIdVnetName}'
    parDestinationVirtualNetworkName: parIdVnetName
    parSourceVirtualNetworkName: '${parMyOrgTla}-avd-vnet'
    parUseRemoteGateways: false
  }
}

module avdresources 'avdresources.bicep' = {
  scope: resourceGroup(avdpocrg.name)
  dependsOn: [
    identitytoavdpocvnetpeering
  ]
  name: 'avdresourcesdeploy'
  params: {
    parExpirationTime: varExpirationTime
    parMyOrgTla: parMyOrgTla
    parResourceGroupLocation: avdpocrg.location
  }
}

module avdsessionhosts 'avdsh.bicep' = {
  dependsOn: [
    avdpocvnet
    identitytoavdpocvnetpeering
    avdresources
  ]
  scope: resourceGroup(avdpocrg.name)
  name: 'avdshdeploy'
  params: {
    parLocation: avdpocrg.location
    parMyOrgTla: parMyOrgTla
    parNumberOfHosts: parNumberOfHosts
    parAdminPassword: parAdminPassword
    parAdminUsername: parAdminUsername
    parDomain: parDomain
    parDomainAdminUPN: parDomainAdminUPN
  }
}
