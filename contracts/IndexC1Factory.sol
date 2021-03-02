// SPDX-License-Identifier: BitYield
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import './IndexC1.sol';

contract IndexC1Factory {
	function createInstance(
		string memory _name,
		address[] memory _assets, 
		uint256[] memory _limits
	) public {
		new IndexC1(_name, _assets, _limits);
	}
}