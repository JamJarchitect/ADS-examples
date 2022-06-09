param parSourceVirtualNetworkName string

param parDestinationVirtualNetworkName string

param parAllowVirtualNetworkAccess bool

param parAllowForwardedTraffic bool

param parAllowGatewayTransit bool

param parUseRemoteGateways bool

param parDestinationVirtualNetworkID string

resource resVirtualNetworkPeer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
  name: '${parSourceVirtualNetworkName}/peer-to-${parDestinationVirtualNetworkName}'
  properties: {
    allowVirtualNetworkAccess: parAllowVirtualNetworkAccess
    allowForwardedTraffic: parAllowForwardedTraffic
    allowGatewayTransit: parAllowGatewayTransit
    useRemoteGateways: parUseRemoteGateways
    remoteVirtualNetwork: {
      id: parDestinationVirtualNetworkID
    }
  }
}
