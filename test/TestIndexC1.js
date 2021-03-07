const { expect } = require('chai');
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const RevertTraceSubprovider = require('@0x/sol-trace').RevertTraceSubprovider;

const BigNumber = require('bignumber.js');
const pry = require('pryjs');
const truffleAssert = require('truffle-assertions');
const utils = require('ethers').utils;
const web3 = require('web3');

const IndexC1 = artifacts.require("IndexC1");

const checkBalanceAmount = (result, limit) => {
	const balanceEthAmount = new BigNumber(Object.assign({}, result).ethAmount);
	const balanceTokAmount = new BigNumber(Object.assign({}, result).tokAmount);

	expect(balanceEthAmount.toString()).to.equal(limit);
	expect(balanceTokAmount.toNumber()).to.equal(12434562745188401);
};

contract('IndexC1', (accounts) => {
	let instance;
	
	const name = "TestIndexV1";
	const assets = [
		"0xDe6bD79980505DC1FeE66A2BbC3881B17EC17818",
		"0x482dC9bB08111CB875109B075A40881E48aE02Cd",
		"0x61460874a7196d6a22D1eE4922473664b3E95270",
		"0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984",
		"0x3BDb41FcA3956A72cd841696bD59ca860F3f0513",
		"0xe3C4f43E690Ed08C4887B284c6ee291059D38105",
		"0xd0A1E359811322d97991E03f863a0C30C2cF029C",
	];
	
	const limits = [
		"300000000000000000",
		"300000000000000000",
		"100000000000000000",
		"100000000000000000",
		"80000000000000000",
		"60000000000000000",
		"60000000000000000",
	];
	
	const owner = accounts[0];
	
	beforeEach(async () => {	
		await IndexC1.new(name, assets, limits).then((contract) => {
			instance = contract;
		});
	});
	
	it("#name should return the correct name", async () => {
		expect(await instance.name.call()).to.equal(name);
	});
	
	it("#enterMarket splits and swaps the funds sent", async () => {
		let contract;
		let value;
		
		return new Promise((resolve, reject) => {
		  resolve(instance);
		})
		  .then(i => {
			contract = i;
			value = new BigNumber(1000000000000000000);
			  
			return i.enterMarket({
				from: owner,
				value: value.toString()
			});
		  })
		  .then(r => {
		  	expect(r.logs.length).to.equal(1);
			expect(r.receipt.logs[0].event).to.equal('EnterMarket');
			
			// Ensure that the receipt contains the true value received
			expect(r.receipt.logs[0].args.from_).to.equal(owner);
			expect(r.receipt.logs[0].args.amountDeposited_.toString()).to.equal(value.toString());
			expect(r.receipt.logs[0].args.currentBlock_.toString()).to.not.be.null;
		
			return contract.getInvestorBalanceAmountsByToken(owner, assets[0]);
		  })
		  .then(r => {
		  	checkBalanceAmount(r, limits[0]);
			
			return contract.getInvestorBalanceAmountsByToken(owner, assets[1]);
		  })
		  .then(r => {			
			checkBalanceAmount(r, limits[1]);
			
			return contract.getInvestorBalanceAmountsByToken(owner, assets[2]);
		  })
		  .then(r => {			
			checkBalanceAmount(r, limits[2]);
			
			return contract.getInvestorBalanceAmountsByToken(owner, assets[3]);
		  })		  
		  .then(r => {			
			checkBalanceAmount(r, limits[3]);
			
			return contract.getInvestorBalanceAmountsByToken(owner, assets[4]);
		  })
		  .then(r => {			
		  	checkBalanceAmount(r, limits[4]);
			  
			return contract.getInvestorBalanceAmountsByToken(owner, assets[5]);
  		  })
		  .then(r => {			
			checkBalanceAmount(r, limits[5]);
			
			return contract.getInvestorBalanceAmountsByToken(owner, assets[6]);
		  })
		  .then(r => {			
		    checkBalanceAmount(r, limits[6]);
		  });
	});

	it("#getAssets should return the list of assets", async () => {  
		return instance.getAssets()
			.then(r => {
				for (i = 0; i < r.length; i++) {
					expect(r[i]).to.equal(assets[i]);
				}
			});
	});

	it("#getLimit should return the allocation limit for the given asset", async () => {
		for (i = 0; i < assets.length; i++) {
			const amount  = await instance.getAssetLimit(assets[i]);
			expect(amount.toString()).to.equal(limits[i]);
		}
	});
});