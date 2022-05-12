targetScope = 'resourceGroup'

param location string

param hubvnetrg string

param hubvnetname string

param spoke1vnetname string

resource hubvnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: hubvnetname
  scope: resourceGroup(hubvnetrg)
}

resource spoke1vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: spoke1vnetname
  location: location
  tags: {}
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.16.0.0/16'
      ]
    }
  }
}

resource spoke1tohubpeer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-08-01' = {
  parent: spoke1vnet
  name: 'spoke1tohub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
      id: hubvnet.id
    }
  }
}
