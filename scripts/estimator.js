const pry = require('pryjs');

const abi = [{"stateMutability": "nonpayable", "inputs": [{"type": "string", "name": "_name", "internalType": "string"}, {"type": "address[]", "name": "_assets", "internalType": "address[]"}, {"type": "uint256[]", "name": "_limits", "internalType": "uint256[]"}], "type": "constructor"}, {"inputs": [{"indexed": true, "type": "address", "name": "from_", "internalType": "address"}, {"indexed": false, "type": "uint256", "name": "amount_", "internalType": "uint256"}, {"indexed": false, "type": "uint256", "name": "currentBlock_", "internalType": "uint256"}], "type": "event", "name": "EnterMarket", "anonymous": false}, {"inputs": [{"indexed": true, "type": "address", "name": "from_", "internalType": "address"}, {"indexed": false, "type": "uint256", "name": "currentBlock_", "internalType": "uint256"}], "type": "event", "name": "ExitMarket", "anonymous": false}, {"inputs": [{"indexed": true, "type": "address", "name": "previousOwner", "internalType": "address"}, {"indexed": true, "type": "address", "name": "newOwner", "internalType": "address"}], "type": "event", "name": "OwnershipTransferred", "anonymous": false}, {"inputs": [{"type": "uint256", "name": "", "internalType": "uint256"}], "constant": true, "name": "assetAddresses", "outputs": [{"type": "address", "name": "", "internalType": "address"}], "stateMutability": "view", "type": "function"}, {"inputs": [{"type": "address", "name": "", "internalType": "address"}], "constant": true, "name": "assetLimits", "outputs": [{"type": "uint256", "name": "", "internalType": "uint256"}], "stateMutability": "view", "type": "function"}, {"inputs": [], "constant": true, "name": "name", "outputs": [{"type": "string", "name": "", "internalType": "string"}], "stateMutability": "view", "type": "function"}, {"inputs": [], "constant": true, "name": "owner", "outputs": [{"type": "address", "name": "", "internalType": "address"}], "stateMutability": "view", "type": "function"}, {"stateMutability": "nonpayable", "inputs": [], "type": "function", "name": "renounceOwnership", "outputs": []}, {"stateMutability": "nonpayable", "inputs": [{"type": "address", "name": "newOwner", "internalType": "address"}], "type": "function", "name": "transferOwnership", "outputs": []}, {"stateMutability": "payable", "payable": true, "type": "receive"}, {"inputs": [], "name": "enterMarket", "outputs": [], "stateMutability": "payable", "payable": true, "type": "function"}, {"stateMutability": "nonpayable", "inputs": [{"type": "uint256", "name": "ethAmount", "internalType": "uint256"}], "type": "function", "name": "exitMarket", "outputs": []}, {"inputs": [{"type": "uint256", "name": "tokenAmount", "internalType": "uint256"}, {"type": "address", "name": "token", "internalType": "address"}], "constant": true, "name": "getAmountsInForTOKEN", "outputs": [{"type": "uint256[]", "name": "", "internalType": "uint256[]"}], "stateMutability": "view", "type": "function"}, {"inputs": [{"type": "uint256", "name": "tokenAmount", "internalType": "uint256"}, {"type": "address", "name": "token", "internalType": "address"}], "constant": true, "name": "getAmountsOutForTOKEN", "outputs": [{"type": "uint256[]", "name": "", "internalType": "uint256[]"}], "stateMutability": "view", "type": "function"}, {"inputs": [{"type": "address", "name": "investor", "internalType": "address"}], "constant": true, "name": "getAllocation", "outputs": [{"type": "tuple", "name": "", "components": [{"type": "address", "name": "investor", "internalType": "address"}, {"type": "uint256", "name": "etherAmount", "internalType": "uint256"}, {"type": "uint256", "name": "currentBlock", "internalType": "uint256"}, {"type": "bool", "name": "completed", "internalType": "bool"}], "internalType": "struct IndexC1.allocation"}], "stateMutability": "view", "type": "function"}, {"inputs": [{"type": "address", "name": "investor", "internalType": "address"}], "constant": true, "name": "getAllocationBalances", "outputs": [{"type": "tuple[]", "name": "", "components": [{"type": "address", "name": "token", "internalType": "address"}, {"type": "uint256", "name": "etherAmount", "internalType": "uint256"}, {"type": "uint256[]", "name": "tokenAmounts", "internalType": "uint256[]"}], "internalType": "struct IndexC1.allocationBalance[]"}], "stateMutability": "view", "type": "function"}, {"inputs": [], "constant": true, "name": "getAssets", "outputs": [{"type": "address[]", "name": "", "internalType": "address[]"}], "stateMutability": "view", "type": "function"}, {"inputs": [{"type": "address", "name": "token", "internalType": "address"}], "constant": true, "name": "getLimit", "outputs": [{"type": "uint256", "name": "", "internalType": "uint256"}], "stateMutability": "view", "type": "function"}];


	
module.exports = async (callback) => {
	const Web3 = require('web3');
	const web3 = new Web3('ws://localhost:7545');
	
	const indexC1Address = '0x8583d7c9E2208f667BDfA5303798118fe21939D1';
	const contract = new web3.eth.Contract(abi, indexC1Address);
	
	const accounts = await web3.eth.getAccounts();
	
	const enterGas = await contract.methods.enterMarket().estimateGas({from: accounts[0]});
	console.log('gas -> [enterMarket]', enterGas);

	callback();
}