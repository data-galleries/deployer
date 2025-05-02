
from luke_lib.dict_helpers import try_add

def build(config) :
    name = config['name']
    staticWebAppName = f"{name}-swa"
    try_add("staticWebApp.name", staticWebAppName, config)
    return config
