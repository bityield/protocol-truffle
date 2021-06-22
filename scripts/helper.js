const config = require('../truffle-config.js');

module.exports = {
	getNetwork: (network) => {
		if (network === "ropsten-fork") {
			return "ropsten"
		} else {
			return network
		}
	},
	getLinkToken: (network) => {
		return config.networks[this.getNetwork(network)].linkToken;
	}
};