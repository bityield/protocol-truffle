const { expect } = require('chai');

const BigNumber = require('bignumber.js');

const Controller = artifacts.require("Controller");
const IndexV2 = artifacts.require("IndexV2");

module.exports = async(deployer, network, accounts) => {
	let name = '';
	let symbol = '';

	let daiAddress = '';
	let cDaiAddress = '';
	let cEtherAddress = '';
	let cCompotrollerAddress = '';

	switch(network) {
		case 'localRopsten':
			name = 'Bityield Stable Leveraged Fund';
			symbol = 'BSLF';

			daiAddress = '0x31F42841c2db5173425b5223809CF3A38FEde360';
			cDaiAddress = '0xbc689667C13FB2a04f09272753760E38a95B998C';
			cEtherAddress = '0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e';
			cCompotrollerAddress = '0x2EAa9D77AE4D8f9cdD9FAAcd44016E746485bddb';

			break;			
		case 'development':
			name = 'Bityield Stable Leveraged Fund';
			symbol = 'BSLF';

			daiAddress = '0x0000000000000000000000000000000000000000';
			cDaiAddress = '0x0000000000000000000000000000000000000000';
			cEtherAddress = '0x0000000000000000000000000000000000000000';
			cCompotrollerAddress = '0x0000000000000000000000000000000000000000';

			break;
		case 'ropsten':
			name = 'Bityield Stable Leveraged Fund';
			symbol = 'BSLF';

			daiAddress = '0x31F42841c2db5173425b5223809CF3A38FEde360';
			cDaiAddress = '0xbc689667C13FB2a04f09272753760E38a95B998C';
			cEtherAddress = '0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e';
			cCompotrollerAddress = '0x2EAa9D77AE4D8f9cdD9FAAcd44016E746485bddb';

			break;
		default:
			throw('cannot deploy to a null network');
	}

	// await deployer.deploy(IndexV2, name, symbol, daiAddress, cDaiAddress, cEtherAddress, cCompotrollerAddress);
};