param resourceGroup object
param storageAccount object
param serverFarm object
param applicationInsights object
param functionApp object
param keyVault object

resource StorageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccount.name
  location: resourceGroup.location
  sku: storageAccount.sku
  kind: storageAccount.kind
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}

resource ServerFarm 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: serverFarm.name
  location: resourceGroup.location
  sku: serverFarm.sku
  properties: {}
}

resource ApplicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsights.name
  location: resourceGroup.location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

var generated_appConfig = concat(functionApp.settings, [
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: ApplicationInsights.properties.InstrumentationKey
  }
])

resource FunctionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: functionApp.name
  location: resourceGroup.location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: ServerFarm.id
    siteConfig: {
      appSettings: generated_appConfig
    }
    httpsOnly: true
  }
}

resource KeyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: keyVault.name
  location: resourceGroup.location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: FunctionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
          ]
          keys: [
            'get'
            'sign'
          ]
          certificates: [
            'get'
          ]
        }
      }
    ]
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
  }
}

// Blob Owner
var blobOwnerGuid = guid(StorageAccount.id, FunctionApp.name, 'BlobOwnerRoleAssignment')

resource BlobOwnerRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: StorageAccount
  name: blobOwnerGuid
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b')
    principalId: FunctionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

var tableContributorGuid = guid(StorageAccount.id, FunctionApp.name, 'TableContributorRoleAssignment')

resource TableContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: StorageAccount
  name: tableContributorGuid
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')
    principalId: FunctionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

var queueContributorGuid = guid(StorageAccount.id, FunctionApp.name, 'QueueContributorRoleAssignment')

resource QueueContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: queueContributorGuid
  scope: StorageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '974c5e8b-45b9-4653-ba55-5f855dd0fb88')
    principalId: FunctionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
