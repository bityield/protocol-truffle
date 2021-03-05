pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

contract OracleInterface {
  function getUnderlyingPrice(string memory) 
    external 
    returns (int)
  {}
}