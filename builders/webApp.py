
from dict_helpers import try_add, try_get

def build(config):
    name = config['name']
    try_add("webApp.name", f"{name}-wa", config)
    try_add("serverFarm.name", f"{name}-sf", config)
    try_add("applicationInsights.name", f"{name}-ai", config)
    try_add('resourceGroup.name', f"{name}-rg", config)

    keyVaultName = f"{name}-kv"
    try_add("keyVault.name", keyVaultName, config)

    storageAccountName = f"{name}sa"
    try_add("storageAccount.name", storageAccountName, config)

    storageAccountName = try_get("storageAccount.name", config)
    keyVaultName = try_get("keyVault.name", config)

    return config
