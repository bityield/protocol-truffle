const Allocator = artifacts.require("Allocator");
const Oracle = artifacts.require("Oracle");

module.exports = async(deployer, network, accounts) => {
	deployer.deploy(Oracle).then(() => {
		return deployer.deploy(Allocator, `${Oracle.address}`)
	});	
};