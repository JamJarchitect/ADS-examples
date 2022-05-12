targetScope = 'resourceGroup'

param parLocation string

param parHubVnetRg string

param parHubVnetName string

param parSpoke1VnetName string

resource hubVnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: parHubVnetName
  scope: resourceGroup(parHubVnetRg)
}

resource spoke1Vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: parSpoke1VnetName
  location: parLocation
  tags: {}
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.16.0.0/16'
      ]
    }
  }
}

resource spoke1ToHubPeer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-08-01' = {
  parent: spoke1Vnet
  name: 'spoke1tohub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
  }
}
