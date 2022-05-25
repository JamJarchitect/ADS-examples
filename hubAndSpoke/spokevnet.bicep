targetScope = 'resourceGroup'

param parLocation string

param parDeploymentType string

param parSpokeNumber string

resource spokeVnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: '${parDeploymentType}-spoke${parSpokeNumber}-vnet'
  location: parLocation
  tags: {}
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.${parSpokeNumber}.0.0/16'
      ]
    }
  }
}

