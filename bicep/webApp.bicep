param resourceGroup object
param storageAccount object
param serverFarm object
param applicationInsights object
param webApp object
param keyVault object

// Storage Account
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

// App Service Plan
resource ServerFarm 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: serverFarm.name
  location: resourceGroup.location
  sku: serverFarm.sku
  properties: {}
}

// Application Insights
resource ApplicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsights.name
  location: resourceGroup.location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

// Web App Configuration
var generated_appConfig = concat(webApp.settings, [
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: ApplicationInsights.properties.InstrumentationKey
  }
  {
    name: 'WEBSOCKETS_ENABLED'
    value: 'true'
  }
])

// Web App
resource WebApp 'Microsoft.Web/sites@2021-03-01' = {
	name: webApp.name
	location: resourceGroup.location
	kind: 'app'
	identity: {
		type: 'SystemAssigned'
	}
	properties: {
		serverFarmId: ServerFarm.id
		siteConfig: {
			appSettings: generated_appConfig
			http20Enabled: true
			webSocketsEnabled: true
			netFrameworkVersion: 'v8.0'
		}
		httpsOnly: true
	}
}

// Key Vault with Web App Access
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
        objectId: WebApp.identity.principalId
        permissions: {
          secrets: [ 'get' ]
          keys: [ 'get', 'sign' ]
          certificates: [ 'get' ]
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

// Blob Owner Role Assignment
resource BlobOwner 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: StorageAccount
  name: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
}

var blobOwnerExists = empty(resourceId('Microsoft.Authorization/roleAssignments', guid(StorageAccount.name, WebApp.name, 'BlobOwnerRoleAssignment')))

resource BlobOwnerRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if(blobOwnerExists) {
  scope: StorageAccount
  name: guid(storageAccount.name, webApp.name, 'BlobOwnerRoleAssignment')
  properties: {
    roleDefinitionId: BlobOwner.id
    principalId: WebApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Table Contributor Role Assignment
resource TableContributor 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: StorageAccount
  name: '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
}

var tableContributorExists = empty(resourceId('Microsoft.Authorization/roleAssignments', guid(StorageAccount.name, WebApp.name, 'TableContributorRoleAssignment')))

resource TableContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if(tableContributorExists) {
  scope: StorageAccount
  name: guid(storageAccount.name, webApp.name, 'TableContributorRoleAssignment')
  properties: {
    roleDefinitionId: TableContributor.id
    principalId: WebApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Queue Contributor Role Assignment
resource QueueContributor 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: StorageAccount
  name: '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
}

var queueContributorExists = empty(resourceId('Microsoft.Authorization/roleAssignments', guid(StorageAccount.name, WebApp.name, 'QueueContributorRoleAssignment')))

resource QueueContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if(queueContributorExists) {
  scope: StorageAccount
  name: guid(storageAccount.name, webApp.name, 'QueueContributorRoleAssignment')
  properties: {
    roleDefinitionId: QueueContributor.id
    principalId: WebApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
