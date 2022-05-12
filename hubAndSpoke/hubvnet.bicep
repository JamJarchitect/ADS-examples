targetScope = 'resourceGroup'

param parLocation string

param parHubVnetName string

param parSpoke1VnetRg string

param parSpoke1VnetName string

var varVngPipName = '${varVngName}pip'

var varVngName = '${parHubVnetName}vng'

resource hubvnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: parHubVnetName
  location: parLocation
  tags: {}
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '192.168.0.0/24'
        }
      }
    ]
  }
}

resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = {
  name: 'GatewaySubnet'
  parent: hubvnet
}

resource hubVnetVngPip 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: varVngPipName
  location: parLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource hubVnetVng 'Microsoft.Network/virtualNetworkGateways@2021-08-01' = {
  name: varVngName
  location: parLocation
  properties: {
    gatewayType: 'Vpn'
    enableBgp: true
    vpnGatewayGeneration: 'Generation1'
    activeActive: false
    vpnType: 'RouteBased'
    ipConfigurations: [
      {
        properties: {
          publicIPAddress: {
            id: hubVnetVngPip.id
          }
          subnet: {
            id: gatewaySubnet.id
          }
        }
      }
    ]
    sku: {
      name: 'Standard'
    }
  }
}

resource spoke1vnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: parSpoke1VnetName
  scope: resourceGroup(parSpoke1VnetRg)
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
