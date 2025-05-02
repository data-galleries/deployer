# build a bicep parameter file from a simple json key value file.

import json

def build_bicep_params(bicep_path, config, output_path):
    needed_params = []
    with open(bicep_path) as bicep_file:
        line = bicep_file.readline()
        while line:
            if line.startswith("param"):
                needed_params.append(line.split(" ")[1])
            line = bicep_file.readline()

    bicep_parameter_object = {}
    bicep_parameter_object["$schema"] = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
    bicep_parameter_object["contentVersion"] = "1.0.0.0"
    params = {}

    for key in config:
        if key not in needed_params:
            continue
        params[key] = {"value": config[key]}

    bicep_parameter_object["parameters"] = params
    with open(output_path, 'w') as outfile:
        json.dump(bicep_parameter_object, outfile, indent=4)


if __name__ == "__main__":
	import sys
	from os.path import normpath, join, dirname, abspath

	if len(sys.argv) != 4:
		print("Usage: python build_bicep_params.py <bicep_path> <config_path> <output_path>")
		sys.exit(1)

	bicep_path = normpath(sys.argv[1])
	config_path = normpath(sys.argv[2])
	output_path = normpath(sys.argv[3])

	with open(config_path) as config_file:
		config = json.load(config_file)

	build_bicep_params(bicep_path, config, output_path)
