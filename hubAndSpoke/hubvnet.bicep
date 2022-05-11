targetScope = 'resourceGroup'

param location string

param hubvnetname string

resource hubvnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: hubvnetname
  location: location
  tags: {}
  properties: {
    addressSpace: {
     addressPrefixes: [
      '52.0.0.0/22' 
     ] 
    }
  }
}
