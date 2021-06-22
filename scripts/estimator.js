const fs = require('fs');
const pry = require('pryjs');

const IndexV1 = artifacts.require('IndexV1');

module.exports = async (callback) => {
	const Web3 = require('web3');
	const web3 = new Web3('ws://localhost:7545');

	// IndexV1
	const indexABI = JSON.parse(fs.readFileSync("./build/contracts/IndexV1.json")).abi;
	const contract = new web3.eth.Contract(indexABI, IndexV1.address);
	const accounts = await web3.eth.getAccounts();

	console.log('IndexV1: gas -> [enterMarket] beginning...');
	const enterGas = await contract.methods.enterMarket().estimateGas({from: accounts[0]});
	console.log('IndexV1: gas -> [enterMarket] result:', enterGas);

	callback();
}