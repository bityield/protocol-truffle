import json
import os
import sys

indexV1ABI = json.load(open(os.getcwd() + '/build/contracts/IndexV1.json'));
indexV2ABI = json.load(open(os.getcwd() + '/build/contracts/IndexV2.json'));

print('------------------------ BEGIN IndexV1 ABI -------------------------------');
print(json.dumps(indexV1ABI['abi']));
print('------------------------ END IndexV1 ABI ---------------------------------');
print("");

print('------------------------ BEGIN IndexV2 ABI -------------------------------');
print(json.dumps(indexV2ABI['abi']));
print('------------------------ END IndexV2 ABI ---------------------------------');
print("");