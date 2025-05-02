param resourceGroup object
param staticWebApp object

resource StaticWebApp 'Microsoft.Web/staticSites@2024-04-01' = {
	name: staticWebApp.name
	location: resourceGroup.location
	sku: {
		name: 'Standard'
		tier: '!!'
	}
	identity: {
		type: 'SystemAssigned'
	}
}

