import json
import os
import sys

cwd = os.getcwd()

allocatorABI = json.load(open(cwd + '/build/contracts/Allocator.json'))
oracleABI = json.load(open(cwd + '/build/contracts/Oracle.json'))

print("")

print('------------------------ BEGIN Allocator ABI -------------------------------')
print(json.dumps(allocatorABI['abi']))
print('------------------------ END Allocator ABI ---------------------------------')
print("")

print('------------------------ BEGIN Oracle ABI ----------------------------------')
print(json.dumps(oracleABI['abi']))
print('------------------------ END Oracle ABI ------------------------------------')
print("")

