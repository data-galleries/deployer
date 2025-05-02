// var storageAccountName = 'lukegcollectoreus2sa'
// var dataStorageAccountName = 'collector4data'
// var appName = 'lukeg-collector-eus2-fa'

param functionAppName string
param storageAccountName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountName
}

// resource DataStorageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
//   name: dataStorageAccountName
// }

resource functionApp 'Microsoft.Web/sites@2021-01-15' existing = {
  name: functionAppName
}

resource BlobOwner 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: storageAccount
  name: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' 
}

// resource StorageBlobDataContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
//   scope: DataStorageAccount
//   name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' 
// }

// resource StorageTableDataContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
//   scope: DataStorageAccount
//   name: '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3' 
// }

// resource StorageQueueDataContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
//   scope: DataStorageAccount
//   name: '974c5e8b-45b9-4653-ba55-5f855dd0fb88' 
// }

resource BlobOwnerRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: storageAccount
  name: guid('BlobOwnerRoleAssignment')
  properties: {
    roleDefinitionId: BlobOwner.id
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// resource BlobContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   scope: DataStorageAccount
//   name: guid('BlobContributorRoleAssignment')
//   properties: {
//     roleDefinitionId: StorageBlobDataContributor.id
//     principalId: functionApp.identity.principalId
//     principalType: 'ServicePrincipal'
//   }
// }

// resource TableContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   scope: DataStorageAccount
//   name: guid('TableContributorRoleAssignment')
//   properties: {
//     roleDefinitionId: StorageTableDataContributor.id
//     principalId: functionApp.identity.principalId
//     principalType: 'ServicePrincipal'
//   }
// }

// resource QueueContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   scope: DataStorageAccount
//   name: guid('QueueContributorRoleAssignment')
//   properties: {
//     roleDefinitionId: StorageQueueDataContributor.id
//     principalId: functionApp.identity.principalId
//     principalType: 'ServicePrincipal'
//   }
// }
