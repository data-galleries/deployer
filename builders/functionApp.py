
from luke_lib.dict_helpers import try_add

def build(config : dict) :
    name = config['name']

    # c = {}
    storageAccountName = f"{name}sa"
    keyVaultName = f"{name}-kv"
    try_add("storageAccount.name", storageAccountName, config)
    try_add("functionApp.name", f"{name}-fa", config)
    try_add("serverFarm.name", f"{name}-sf", config)
    try_add("keyVault.name", keyVaultName, config)
    try_add("applicationInsights.name", f"{name}-ai", config)
    # try_add('resourceGroup.name', f"{name}-rg", config)

    appSettings = [
        {
            "name": "AzureWebJobsStorage__accountName",
            "value": storageAccountName
        },
        {
            "name": "DataStorageAccountName",
            "value": storageAccountName
        },
        {
            "name": "DataStorageAccount__queueServiceUri",
            "value": f"https://{storageAccountName}.queue.core.windows.net/"
        },
        {
            "name": "DataStorageAccount__blobServiceUri",
            "value": f"https://{storageAccountName}.blob.core.windows.net/"
        },
        {
            "name": "DataStorageAccount__serviceUri",
            "value": f"https://{storageAccountName}.blob.core.windows.net/"
        },
        {
            "name": "KeyVaultName",
            "value": f"{keyVaultName}"
        }
    ]

    if not try_add("functionApp.settings", appSettings, config):
        config['functionApp']['settings'] += appSettings


    return config
