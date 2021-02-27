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
	let name;
	let assets;
	let allocations;
	
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
				"0xDe6bD79980505DC1FeE66A2BbC3881B17EC17818",
				"0x482dC9bB08111CB875109B075A40881E48aE02Cd",
				"0x61460874a7196d6a22D1eE4922473664b3E95270",
				"0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984",
				"0x3BDb41FcA3956A72cd841696bD59ca860F3f0513",
				"0xe3C4f43E690Ed08C4887B284c6ee291059D38105",
				"0xd0A1E359811322d97991E03f863a0C30C2cF029C",
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
			throw 'cannot use a [default] case on IndexC1 deployment';
	}
	
	// Check totals before actually having the contracts constructor throw
	checkAssetLengths(assets, allocations);
	checkAllocationAmounts(allocations);
	
	await deployer.deploy(IndexC1, name, assets, allocations);
};