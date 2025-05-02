@description('Name of the project or solution')
@minLength(3)
@maxLength(37)
param name string
param location string
param displayName string

@allowed([
  'PremiumP1'
  'PremiumP2'
  'Standard'
])
param skuName string = 'Standard'
param skuTier string = 'A0'
param countryCode string = 'US'

var directoryName = toLower('${name}.onmicrosoft.com')

var tenantExists = resourceId('Microsoft.AzureActiveDirectory/b2cDirectories', directoryName) != null

resource newB2c 'Microsoft.AzureActiveDirectory/b2cDirectories@2021-04-01' = if (!tenantExists) {
  name: directoryName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    createTenantProperties: {
      countryCode: countryCode
      displayName: displayName
    }
  }
}
