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

resource FunctionApp 'Microsoft.Web/sites@2021-03-01' = {
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
      use32BitWorkerProcess: false
      netFrameworkVersion: 'v6.0'
    }
    httpsOnly: true
  }
}

resource KeyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
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
resource BlobOwner 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: StorageAccount
  name: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' 
}

var blobOwnerExists = empty(resourceId('Microsoft.Authorization/roleAssignments', guid(StorageAccount.name, FunctionApp.name, 'BlobOwnerRoleAssignment')))

resource BlobOwnerRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if(blobOwnerExists) {
  scope: StorageAccount
  name: guid(storageAccount.name, functionApp.name, 'BlobOwnerRoleAssignment')
  properties: {
    roleDefinitionId: BlobOwner.id
    principalId: FunctionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Table Contributor
resource TableContributor 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: StorageAccount
  name: '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3' 
}

var tableContributorExists = empty(resourceId('Microsoft.Authorization/roleAssignments', guid(StorageAccount.name, FunctionApp.name, 'TableContributorRoleAssignment')))

resource TableContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (tableContributorExists) {
  scope: StorageAccount
  name: guid(storageAccount.name, functionApp.name, 'TableContributorRoleAssignment')
  properties: {
    roleDefinitionId: TableContributor.id
    principalId: FunctionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Queue Contributor
resource QueueContributor 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: StorageAccount
  name: '974c5e8b-45b9-4653-ba55-5f855dd0fb88' 
}

var queueContributorExists = empty(resourceId('Microsoft.Authorization/roleAssignments', guid(StorageAccount.name, FunctionApp.name, 'QueueContributorRoleAssignment')))

resource QueueContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if(queueContributorExists) {
  scope: StorageAccount
  name: guid(storageAccount.name, functionApp.name, 'QueueContributorRoleAssignment')
  properties: {
    roleDefinitionId: QueueContributor.id
    principalId: FunctionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
