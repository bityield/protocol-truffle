// SPDX-License-Identifier: Bityield
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { AddressArrayUtils } from "./lib/AddressArrayUtils.sol";

contract Controller is Ownable {
	using AddressArrayUtils for address[];

	address public dispatcher;
	address public deployer;
	address public controller;
	address public supervisor;
	address public custodian;

	constructor(
		address _dispatcher,
		address _deployer,
		address _controller,
		address _supervisor,
		address _custodian
	)
		public
	{
		Ownable(msg.sender);

		dispatcher = _dispatcher;
		deployer = _deployer;
		controller = _controller;
		supervisor = _supervisor;
		custodian = _custodian;
	}
}