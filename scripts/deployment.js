var IndexC1 = artifacts.require("IndexC1");
var solc = require('solc');

module.exports = (callback) => {
	IndexC1.web3.eth.getGasPrice((error, result) => { 
		const gasPrice = Number(result);
		console.log("Gas Price is " + gasPrice + " wei");

		const IndexC1Contract = web3.eth.contract(MetaCoin._json.abi);
		const contractData = IndexC1Contract.new.getData({data: IndexC1._json.bytecode});
		const gas = Number(web3.eth.estimateGas({data: contractData}))

		console.log("gas estimation = " + gas + " units");
		console.log("gas cost estimation = " + (gas * gasPrice) + " wei");
		console.log("gas cost estimation = " + IndexC1.web3.fromWei((gas * gasPrice), 'ether') + " ether");
	});
};