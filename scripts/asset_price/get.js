const Allocator = artifacts.require("Allocator");

module.exports = async(callback) => {
	try {
		let allocator = await Allocator.deployed();
		let callCOMP = await allocator.getEstimatedETHforCOMP('100');
		
		console.log('COMP[0]:', callCOMP[0]);
		console.log('COMP[1]:', callCOMP[1]);
	} catch (e) {
		console.log(e);
	}

	return callback()
};