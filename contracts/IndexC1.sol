// SPDX-License-Identifier: BitYield
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import { AddressArrayUtils } from "./lib/AddressArrayUtils.sol";

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';

import '@nomiclabs/buidler/console.sol';

contract IndexC1 is Ownable {
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
  // 		key -> valid token address
  // 		val -> allocation in wei (uint256)
  mapping(address => uint256) public assetLimits;
  
  // allocations; the allocation ledger for storing the investment amounts per address
  mapping(address => allocation) private allocations;
  
  // allocationBalances; the ledger for the asset token spread for the investor
  mapping(address => allocationBalance[]) private allocationBalances;
  
  // allocation; The object stored in the allocations mapping. What the investors investment amount looks like
  struct allocation {
    address investor;
    uint256 etherAmount;
    uint currentBlock;
    bool completed;
  }
  
  // allocationBalance; holds token amounts for a given investor in the allocationBalances mapping
  struct allocationBalance {
    address token;
    uint256 etherAmount;
    uint[] tokenAmounts;
  }
  
  // name; is the name of the IndexFund
  string public name;
  
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
    Ownable(msg.sender);
    
    name = _name;
    
    require(_assets.length == _limits.length, "Arrays must be equal");
    require(_assets.length != 0, "Array must not be empty");
    
    // Setting the assets and their limits here
    for (uint i = 0; i < _assets.length; i++) {
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
    // require(allocations[msg.sender] == 0,
    //   "This product currently only allows one investment per address / investor"
    // );
    
    // Set the investors initial values in their allocation  
    allocation memory allocationInstance = allocation(msg.sender, msg.value, block.number, false);
  
    // This is where the magic happens on the token swaps
    for (uint i = 0; i < assetAddresses.length; i++) {
      address tokenAddress = assetAddresses[i];
      
      // Calculate the allocation amount
      uint256 tokenEtherAmount = (msg.value * assetLimits[tokenAddress]) / 1000000000000000000;
      
      // Call UniswapRouter for the swap and return the amounts out
      // uint[] memory tokenAmounts = uniswapRouter.swapExactETHForTokens{ 
      //   value: tokenAmount 
      // }(0, getPathForETHtoTOKEN(assetAddresses[i]), address(this), (block.timestamp + 25));

      // For testing purposes until we pass in Uniswap router interface
      uint[] memory tokenAmountsOut = new uint[](2);
      tokenAmountsOut[0] = 19472849;
      tokenAmountsOut[1] = 10000000;
      
      // Create the object for storing the allocation at the token level
      allocationBalance memory allocationBalanceInstance = allocationBalance(
        tokenAddress, 
        tokenEtherAmount, 
        tokenAmountsOut
      );
      
      // Save the token value amount onto the Allocations object of the investor
      allocationBalances[msg.sender].push(allocationBalanceInstance);
    }
  
    // Refund any unused Ether
    (bool success,) = msg.sender.call{ value: address(this).balance }("");
    require(success, "refund failed");
    
    // Emit the EnterMarket event
    emit EnterMarket(
      msg.sender, 
      msg.value,
      block.number
    );
    
    // If nothing has failed nor a revert, then we can safely store the balances
    // ------------------------------------------------------------------------------
    // // Set the status to true
    allocationInstance.completed = true;
    
    // // Add the investor allocation object to keep granular details about the trade
    allocations[msg.sender] = allocationInstance; 
  }
  
  function exitMarket(uint ethAmount) public {
    // Check that the amount has in fact been accounted for
    require(ethAmount >= allocations[msg.sender].etherAmount,
      "The amount trying to be withdrawn is less than is available for this investor"
    );
    
    for (uint i = 0; i < allocationBalances[msg.sender].length; i++) {
      IERC20 t = IERC20(assetAddresses[i]);
      uint256 balanceOfToken = t.balanceOf(address(this));
      
      require(balanceOfToken >= 0,
        "Token balance must be greater than 0"
      );
  
      t.transfer(owner(), balanceOfToken);
    }
  }
  
  // function enterMarketApproval(address spender, uint256 amount) external returns (bool) {
  //   return false;
  // }
  // 
  // function exitMarketApproval(address spender, uint256 amount) external returns (bool) {
  //   return false;    
  // }
  
  // getAmountsInForTOKEN; calls the UniswapRouter for the amountsIn on a given token
  function getAmountsInForTOKEN(uint tokenAmount, address token) public view returns (uint[] memory) {
    return uniswapRouter.getAmountsIn(tokenAmount, getPathForETHtoTOKEN(token));
  }
  
  // getPathForETHtoTOKEN; given a token's address, return a path from the WETH UniswapRouter
  function getPathForETHtoTOKEN(address token) private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = uniswapRouter.WETH();
    path[1] = token;
  
    return path;
  }
  
  // getPathForTOKENtoETH; given a token's address, return a path to the WETH UniswapRouter
  function getPathForTOKENtoETH(address token) private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = token;
    path[1] = uniswapRouter.WETH();
    
    return path;
  }

  /* ============ Getters ============ */
  
  // getAllocation; returns a given investors allocation investment amount as a struct representation
  function getAllocation(address investor) public view returns(allocation memory) { return allocations[investor]; }
  
  // getAllocationBalances; returns the investors tokens and balances invested in
  function getAllocationBalances(address investor) public view returns(allocationBalance[] memory) { return allocationBalances[investor]; }
  
  // getAssets; returns an array of all the Fund's investable assets only
  function getAssets() public view returns(address[] memory) { return assetAddresses; }
  
  // getLimit; for a given asset, returns it's allocation ceiling
  function getLimit(address token) public view returns(uint256) { return assetLimits[token]; }
  
  // receive; required to accept ether
  receive() payable external {}
}