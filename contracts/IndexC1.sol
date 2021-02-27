// SPDX-License-Identifier: BitYield
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import { AddressArrayUtils } from "./lib/AddressArrayUtils.sol";

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';

import '@nomiclabs/buidler/console.sol';

contract IndexC1 {
  using AddressArrayUtils for address[];
  
  using SafeMath for uint256;
    
  IUniswapV2Router02 private uniswapRouter;
  IUniswapV2Factory  private uniswapFactory;
  
  /* ============ State Variables ============ */
  
  // assetAddresses; this is an array of the tokens that will be held in this fund 
  // A valid Uniswap pair must be present on the execution network to provide a swap
  address[] public assetAddresses;
  
  // assetLimits; this maps the asset(a token's address) => to it's funding allocation maximum
  // example: {0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984 => 100000000000000000}
  // 		key -> valid Ethereum address
  // 		val -> allocation in wei (uint256)
  mapping(address => uint256) public assetLimits;
  
  // allocations; the allocation ledger for storing the investment amounts per address
  mapping (address => allocation) public allocations;
  
  // The object stored in the allocations mapping. What the investors spread looks like
  struct allocation {
    address investor;
    uint256 amount;
    uint currentBlock;
  }
  
  // name; is the name of the IndexFund
  string public name;
  
  // owner; is the contract sender, usually a comptroller
  address internal owner;
  
  address internal constant UNISWAP_V1 = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
  address internal constant UNISWAP_V2 = 0xB0b3B38ef1b32E98f2947e5Ba23ca765158d023B;
  address internal constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
  address internal constant UNISWAP_FACTORY_ADDRESS = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
  
  /* ============ Events ================= */
  event EnterMarket(
    address indexed from_, 
    uint256 amount_,
    uint currentBlock_
  );
  
  event ExitMarket(
    address indexed from_,
    uint256 amount_,
    uint currentBlock_
  );

  /* ============ Constructor ============ */
  constructor(
    string memory _name,
    address[] memory _assets, 
    uint256[] memory _limits
  ) public {
    name = _name;
    owner = msg.sender;
    
    require(_assets.length == _limits.length, "Arrays must be equal");
    require(_assets.length != 0, "Array must not be empty");
    
    for (uint256 i = 0; i < _assets.length; i++) {
      address asset = _assets[i];
      require(assetLimits[asset] == 0, "Asset already added");
      assetLimits[asset] = _limits[i];
    }

    assetAddresses = _assets;
    uniswapRouter  = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
    uniswapFactory = IUniswapV2Factory(UNISWAP_FACTORY_ADDRESS);
  }
  
  // enterMarket; is the main entry point to this contract. It takes msg.value and splits
  // to the allocation ceilings in wei. Any funds not used are returned to the sender
  function enterMarket() public payable {
    console.log('#enterMarket msg.value', msg.value);
    
    // require(msg.value >= 1000000000000000000, "Amount should be greater than or equal to 1 Ether");
    
    // Send from UI when deployed to Mainnet
    uint deadline = block.timestamp + 35;
    
    // Keep a running total of the allocation amounts
    uint256 totals = 0;

    for (uint256 i = 0; i < assetAddresses.length; i++) {
      uint256 c1 = (msg.value * assetLimits[assetAddresses[i]]) / 1000000000000000000;
      
      totals += c1;
      
      // uniswapRouter.swapExactETHForTokens{ value: c1 }(0, getPathForETHtoTOKEN(assetAddresses[i]), address(this), deadline);
    }
    
    // require(msg.value == totals, "Amounts computed for investment must equal that of the msg.value, ether.");
    
    emit EnterMarket(
      msg.sender, 
      msg.value,
      block.number
    );
    
    allocations[msg.sender] = allocation(msg.sender, msg.value, block.number);
  
    (bool success,) = msg.sender.call{ value: address(this).balance }("");
    require(success, "refund failed");
    }
  
  // getAmountsInForTOKEN; calls the UniswapRouter for the amountsIn on a given token
  function getAmountsInForTOKEN(uint tokenAmount, address token) public view returns (uint[] memory) {
    return uniswapRouter.getAmountsIn(tokenAmount, getPathForETHtoTOKEN(token));
    }
  
  // getPathForETHtoTOKEN; given a token's address, return a path through the WETH UniswapRouter
  function getPathForETHtoTOKEN(address token) private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = uniswapRouter.WETH();
    path[1] = token;
  
    return path;
  }

  /* ============ Getters ============ */
  
  // getAllocation; returns a given investors allocation investment amount as a struct representation
  function getAllocation(address investor) external view returns(allocation memory) { return allocations[investor]; }
  
  // getAssets; returns an array of all the Fund's investable assets only
  function getAssets() external view returns(address[] memory) { return assetAddresses; }
  
  // getLimit; for a given asset, returns it's allocation ceiling
  function getLimit(address token) external view returns(uint256) { return assetLimits[token]; }
  
  // receive; required to accept ether
  receive() payable external {}
}