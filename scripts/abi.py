import json
import os
import sys

indexC1ABI = json.load(open(os.getcwd() + '/build/contracts/IndexC1.json'))

print('------------------------ BEGIN IndexC1 ABI -------------------------------')
print(json.dumps(indexC1ABI['abi']))
print('------------------------ END IndexC1 ABI ---------------------------------')
print("")