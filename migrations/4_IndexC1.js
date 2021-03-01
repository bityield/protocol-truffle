const { expect } = require('chai');

const BigNumber = require('bignumber.js');
const IndexC1 = artifacts.require("IndexC1");

const checkAssetLengths = (a, b) => {
	expect(a.length).to.equal(b.length);
};

const checkAllocationAmounts = (items) => {
	let totals = 0;
	
	for (i = 0; i < items.length; i++) {
		let value = new BigNumber(items[i]);
		
		totals += value.toNumber();
	}
	
	expect(totals).to.equal(1000000000000000000);
};

module.exports = async(deployer, network, accounts) => {
	let name = '';
	let assets = [
		"0x0000000000000000000000000000000000000000"
	];
	let allocations= [
		"1000000000000000000"
	];
	
	switch(network) {
		case "development":
			name = "TestGeneralPurposeV1";
			assets = [
				"0x0000000000000000000000000000000000000001",
				"0x0000000000000000000000000000000000000002",
				"0x0000000000000000000000000000000000000003",
				"0x0000000000000000000000000000000000000004",
				"0x0000000000000000000000000000000000000005",
				"0x0000000000000000000000000000000000000006",
				"0x0000000000000000000000000000000000000007",
			];
			
			allocations = [
				"300000000000000000",
				"300000000000000000",
				"100000000000000000",
				"100000000000000000",
				"80000000000000000",
				"60000000000000000",
				"60000000000000000",
			];
			
			break;
		case "ropsten":
			name = "High Yield GP1";
			
			assets = [
				"0x3949d09628eA7a714Ea3C34cA8A520EdACf3825D", // xWETH
				"0xe39e6637395AC1d0d01c12e846E43fbDD01249fB", // xWBTC
				"0x339A8c5Fd0D82CbeFA8fBfb4333Cb5540177F672", // xUNI
				"0xc102eF924Ea10E6cD8D2AA775b5Cd0dAb01CDB47", // xCOMP
				"0x1207e7D4e82Bd98c18BA79bA80160F0816420E4d", // xDAI
				"0x91f61442E3A714782E8931Da0fefe620A30b2D21", // xUSDC
				"0x2e3443a910DC27891365994f8D50bcad04B2F768", // xBAT
			];
			
			allocations = [
				"300000000000000000",
				"300000000000000000",
				"100000000000000000",
				"100000000000000000",
				"80000000000000000",
				"60000000000000000",
				"60000000000000000",
			];
			
			break;
		default:
			console.log('Deploying to a none cased network:', network);
	}
	
	// Check totals before actually having the contracts constructor throw
	checkAssetLengths(assets, allocations);
	checkAllocationAmounts(allocations);
	
	await deployer.deploy(IndexC1, name, assets, allocations);
};