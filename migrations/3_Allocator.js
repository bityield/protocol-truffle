const Allocator = artifacts.require("Allocator");
const Oracle = artifacts.require("Oracle");

module.exports = async(deployer, network, accounts) => {
	await deployer.deploy(Allocator, `${Oracle.address}`);
};