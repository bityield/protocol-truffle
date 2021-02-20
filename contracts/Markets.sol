// SPDX-License-Identifier: BitYield
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

contract Markets {
	struct market {
		string symbol;
		address location;
		uint128 allocation;
	}
	
	constructor() public { }
	
// 	function getMarket(string memory symbol) 
// 		public 
// 		view 
// 		returns (miniMarket calldata) 
// 	{
// 		require(
// 			isSupported(symbol),
// 			"Asset not supported."
// 		);
// 
// 		return markets[symbol];
// 	}
// 	
// 	function isSupported(string memory symbol) 
// 		private 
// 		view 
// 		returns (bool) 
// 	{
// 		return supportedMarkets[symbol];
// 	}
}