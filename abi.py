import json
import sys

content = json.load(open(sys.argv[1]))

abi = content['abi']
bytecode = content['bytecode']

print(json.dumps(abi))