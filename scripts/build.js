const solc = require('solc');
const fs = require('fs');

const myContractFileName = 'IndexV1.sol';
const MyContractName = 'IndexV1';
const myContractFilePath = `../contracts/${myContractFileName}`;
const myContractCode = fs.readFileSync(myContractFilePath).toString();

const input = {
  language: 'Solidity',
  sources: {
	[myContractFileName]: {
	  content: myContractCode
	}
  },
  settings: {
	outputSelection: {
	  '*': {
		'*': ['*']
	  }
	}
  }
};

const output = JSON.parse(solc.compile(JSON.stringify(input)));

if (output.errors) {
  let allWarnings = true;
  output.errors.forEach((potentiallyAnError) => {
	if (potentiallyAnError.type !== 'Warning') allWarnings = false;
  });

  console.error(output.errors);

  if (!allWarnings) {
	console.error('BUILD FAILED, EXITING.');
	process.exit(1);
  }
}

const myContractOutput = output.contracts[myContractFileName][MyContractName];
const bytecode = myContractOutput.evm.bytecode.object;
const abi = myContractOutput.abi;

fs.mkdir('./.build/', { recursive: true }, (err) => {
  if (err) {
	console.error('Error creating a build directory', err);
	console.error('BUILD FAILED, EXITING.');
	process.exit(1);
  }
});

fs.writeFileSync('./.build/bytecode.json', JSON.stringify({ bytecode }));
fs.writeFileSync('./.build/abi.json', JSON.stringify(abi));