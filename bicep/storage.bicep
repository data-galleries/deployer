param storageAccount object
param resourceGroup object

resource StorageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccount.name
  location: resourceGroup.location
  sku: storageAccount.sku
  kind: storageAccount.kind
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
    allowBlobPublicAccess: storageAccount.allowBlobPublicAccess ?? false
  }
}
