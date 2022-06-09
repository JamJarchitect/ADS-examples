targetScope = 'resourceGroup'

param parResourceGroupLocation string

param parExpirationTime string

param parMyOrgTla string

resource avdmshostpool 'Microsoft.DesktopVirtualization/hostPools@2022-02-10-preview' = {
  name: '${parMyOrgTla}-avd-ms-hp1'
  location: parResourceGroupLocation
  properties: {
    hostPoolType: 'Pooled'
    loadBalancerType: 'BreadthFirst'
    preferredAppGroupType: 'Desktop'
    registrationInfo: {
      registrationTokenOperation: 'Update'
      token: null
      expirationTime: parExpirationTime
    }
  }
}

resource avdmsdag 'Microsoft.DesktopVirtualization/applicationGroups@2022-02-10-preview' = {
  name: '${parMyOrgTla}-avd-ms-dag1'
  location: parResourceGroupLocation
  properties: {
    applicationGroupType: 'Desktop'
    hostPoolArmPath: avdmshostpool.id
  }
}

resource avdmsworkspace 'Microsoft.DesktopVirtualization/workspaces@2022-02-10-preview' = {
  name: '${parMyOrgTla}-avd-ms-ws1'
  location: parResourceGroupLocation
}

resource avdmsprofilesa 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: '${parMyOrgTla}avdfsl'
  location: parResourceGroupLocation
  sku: {
    name: 'Premium_LRS'
  }
  kind: 'FileStorage'
}

resource avdmsprofilesfs 'Microsoft.Storage/storageAccounts/fileServices@2021-09-01' = {
  name: 'default'
  parent: avdmsprofilesa
}

resource avdmsprofilesshare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = {
  name: 'profiles'
  parent: avdmsprofilesfs 
  properties: {
    accessTier: 'Premium'
    enabledProtocols: 'SMB'
    shareQuota: 100
  }
}
