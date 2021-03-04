// SPDX-License-Identifier: Bityield
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { AddressArrayUtils } from "./lib/AddressArrayUtils.sol";

contract Controller is Ownable {
	using AddressArrayUtils for address[];
	
	constructor() public {
		Ownable(msg.sender);
	}
}