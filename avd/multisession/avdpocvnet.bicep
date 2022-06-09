targetScope = 'resourceGroup'

param parCompanyTla string

param parDnsServerIp string

param parLocation string

resource avdpocvnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: '${parCompanyTla}-avd-vnet'
  location: parLocation
  properties: {
    dhcpOptions: {
      dnsServers: [
        '${parDnsServerIp}'
      ]
    }
    addressSpace: {
      addressPrefixes: [
        '52.0.0.0/24'
      ]
    }
    subnets: [
      {
        name: 'avd-poc-subnet1'
        properties: {
          addressPrefix: '52.0.0.0/24'
        }
      }
    ]
  }
}
