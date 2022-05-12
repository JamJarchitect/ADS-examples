targetScope = 'resourceGroup'

param location string

param hubvnetname string

param spoke1vnetrg string

param spoke1vnetname string

resource hubvnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: hubvnetname
  location: location
  tags: {}
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.0.0/16'
      ]
    }
  }
}

resource spoke1vnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: spoke1vnetname
  scope: resourceGroup(spoke1vnetrg)
}

resource hubtospoke1peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-08-01' = {
  name: 'hubtospoke1'
  parent: hubvnet
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    allowVirtualNetworkAccess: true
    remoteVirtualNetwork: {
      id: spoke1vnet.id
    }
  }
}
