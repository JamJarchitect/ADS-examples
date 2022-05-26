targetScope = 'resourceGroup'

param parLocation string

param parHubVnetName string

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

resource hubVngPip 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: varVngPipName
  location: parLocation
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

resource hubvng 'Microsoft.Network/virtualNetworkGateways@2021-08-01' = {
  name: '${parHubVnetName}vng'
  location: parLocation
  properties: {
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    vpnGatewayGeneration: 'Generation1'
    activeActive: false
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          publicIPAddress: {
            id: hubVngPip.id
          }
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: gatewaySubnet.id
          }
        }
      }
    ]
  }
}
