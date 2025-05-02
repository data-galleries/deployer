param cosmosDb object

resource CosmosDb 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: cosmosDb.name
  location: cosmosDb.location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    enableFreeTier: true // Enables the free tier (400 RU/s and 25GB free storage)
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session' // Balanced consistency level
    }
    capabilities: []
    locations: [
      {
        locationName: cosmosDb.location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
  }
}

resource CosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  parent: CosmosDb
	name: 'agendaDB'
  properties: {
    resource: {
      id: 'agendaDB'
    }
  }
}

resource CosmosDbContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: CosmosDbDatabase
	name: 'agendaItems'
  properties: {
    resource: {
      id: 'agendaItems'
      partitionKey: {
				// Use "id" as the partition key for scalability
        paths: ['/id']
        kind: 'Hash'
      }
    }
    options: {
			// This will be free if free tier is enabled
      throughput: 400
    }
  }
}

output cosmosDbEndpoint string = cosmosDb.properties.documentEndpoint
