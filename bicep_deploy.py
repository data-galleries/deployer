import sys
import os
from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import ResourceManagementClient
from build_bicep_params import build_bicep_params
from jsonic.loader import Load
import subprocess
import requests
import uuid

def delete_resource_group(config):
    name = config['resourceGroup']['name']
    credential = DefaultAzureCredential()
    subscriptionId = config['subscription']['id']
    resource_client = ResourceManagementClient(credential, subscriptionId)
    poller = resource_client.resource_groups.begin_delete(name)
    result = poller.result()
    return result

def deploy_resource_group(config):
    location = config['resourceGroup']['location']
    name = config['resourceGroup']['name']
    credential = DefaultAzureCredential()
    subscriptionId = config['subscription']['id']
    tenantId = config['subscription']['tenantId']
    resource_client = ResourceManagementClient(credential, subscriptionId)
    try:
        rg_result = resource_client.resource_groups.create_or_update(
            name, {
                "location": location,
                "tags": {
                    "environment": "test",
                }
            }
        )

        return rg_result
    except Exception as e:
        deployment_link = f"https://portal.azure.com/{tenantId}/resource/subscriptions/{subscriptionId}/resourceGroups/{name}/deployments"
        raise Exception(f"Failed to deploy resource group '{name}'.\n {deployment_link}") from e

def deploy_with_bicep(configPath):
    config = Load(configPath)
    name = config['name']
    subscriptionId = config['subscription']['id']
    tenantId = config['subscription']['tenantId']

    deploy_resource_group(config)

    deploymentName = f"{name}-deploy"
    resourceGroupName = config['resourceGroup']['name']
    paramFilePath = f"{name}_params.json"
    outfilePath = f"{name}-outfile.txt"

    bicepLink = config['bicep']
    if (bicepLink.startswith("http://") or bicepLink.startswith("https://")): # todo: bicep deploy without local file
        bicepContent = requests.get(bicepLink).text
        id = uuid.uuid4()
        needsCleanup = True
        bicepPath = os.path.join(os.getcwd(), f"{id}.bicep")
        with open(bicepPath, 'w') as bicep_file:
            bicep_file.write(bicepContent)

    else:
        raise Exception("$.bicep must resolve to a url")

    build_bicep_params(bicepPath, config, paramFilePath)

    args = [
        "az.cmd", "deployment", "group", "create",
        "-n", deploymentName,
        "-g", resourceGroupName,
        "--template-file", bicepPath,
        "--parameters", paramFilePath,
    ]

    try:
        with open(outfilePath, 'w') as out_file:
            # Run Azure CLI command
            result = subprocess.run(args, stdout=out_file, stderr=out_file, text=True)

        if result.returncode != 0:
            with open(outfilePath, 'r') as f:
                error_output = f.read()
                print(error_output)
                raise Exception(f"Deployment failed with error: {error_output}")

    except Exception as e:
        deployment_link = f"https://portal.azure.com/#@{tenantId}/resource/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/deployments"
        raise Exception(f"Failed to deploy with Bicep.\nCheck Azure Portal: {deployment_link}") from e

    finally:
        if os.path.exists(paramFilePath):
            os.remove(paramFilePath)
        if os.path.exists(outfilePath):
            os.remove(outfilePath)
        if needsCleanup:
            os.remove(bicepPath)

    return result.returncode

if __name__ == "__main__" :
    configPath = sys.argv[1]
    result = deploy_with_bicep(configPath)
