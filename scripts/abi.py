import json
import os
import sys

cwd = os.getcwd()

allocatorABI = json.load(open(cwd + '/build/contracts/Allocator.json'))
oracleABI = json.load(open(cwd + '/build/contracts/Oracle.json'))

print('Allocator ABI --------------------------------------------------------------')
print(json.dumps(allocatorABI['abi']))
print()

print('Oracle ABI -----------------------------------------------------------------')
print(json.dumps(oracleABI['abi']))
print()

