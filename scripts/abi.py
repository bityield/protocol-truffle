import json
import os
import sys

cwd = os.getcwd()

indexC1ABI = json.load(open(cwd + '/build/contracts/IndexC1.json'))
oracleABI = json.load(open(cwd + '/build/contracts/Oracle.json'))

print("")

print('------------------------ BEGIN IndexC1 ABI -------------------------------')
print(json.dumps(indexC1ABI['abi']))
print('------------------------ END IndexC1 ABI ---------------------------------')
print("")

print('------------------------ BEGIN Oracle ABI ----------------------------------')
print(json.dumps(oracleABI['abi']))
print('------------------------ END Oracle ABI ------------------------------------')
print("")

