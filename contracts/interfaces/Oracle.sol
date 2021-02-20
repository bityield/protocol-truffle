// SPDX-License-Identifier: BitYield
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

contract OracleInterface {
  function getAssetLatestRoundData(string memory) 
    external 
    returns (int)
  {}
}