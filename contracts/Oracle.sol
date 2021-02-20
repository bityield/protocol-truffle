// SPDX-License-Identifier: BitYield
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import '@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol';

contract Oracle {
	// Chainlink price feeds: https://docs.chain.link/docs/ethereum-addresses
	mapping (string => address) private priceFeeds;
	mapping (string => AggregatorV3Interface) private priceAggregators;
  
	mapping (string => bool) private supportedAssets;
  
	constructor() public {
		priceAggregators['BTC'] = AggregatorV3Interface(0x6135b13325bfC4B00278B4abC5e20bbce2D6580e);
		priceAggregators['ETH'] = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
	
		supportedAssets['BTC'] = true;
		supportedAssets['ETH'] = true;
	}
  
	function getAssetLatestRoundData(string memory symbol) 
		public
		view 
		returns (int) 
	{
		require(
			isSupported(symbol),
			"Asset Symbol not supported."
		);
	  
		(
			, 
			int price,
			,
			,
		) = priceAggregators[symbol].latestRoundData();
	
		return price;
	}
  
	function isSupported(string memory symbol) 
		private 
		view 
		returns (bool) 
	{
		return supportedAssets[symbol];
	}
}