// SPDX-License-Identifier: Block27
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';

import './interfaces/Oracle.sol';


contract Allocator {
  IUniswapV2Router02 private uniswapRouter;
  IUniswapV2Factory  private uniswapFactory;

  OracleInterface private oracle;

  address internal constant UNISWAP = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
  address internal constant UNISWAP_V2 = 0xB0b3B38ef1b32E98f2947e5Ba23ca765158d023B;
  address internal constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
  address internal constant UNISWAP_FACTORY_ADDRESS = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

  using SafeMath for uint256;

  address internal comptroller;
  address internal beneficiary;
  address internal owner;

  string private network;
  string private constant MAINNET = "mainnet";
  string private constant KOVAN   = "kovan";

  mapping (string => address) private uniswapPairs;
  mapping (string => address) private priceFeeds;

  event EnterMarket(address indexed _from, uint _actual, uint _given);
  event ExitMarket(address indexed _from);

  constructor(address oracle_) public {
    // Contract owners and beneficiaries
    owner = msg.sender;
    
    // Set the Oracle address
    oracle = OracleInterface(oracle_);

    // Set the route
    uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);

    // Set the factory
    uniswapFactory = IUniswapV2Factory(UNISWAP_FACTORY_ADDRESS);

    // Set the network based on testing
    network = KOVAN;

    // Development only, not intended to go to Mainnet with this if branch
    if (keccak256(abi.encodePacked(network)) == keccak256(abi.encodePacked(MAINNET))) {
        // Mainnet ------------------------------------------------------
        uniswapPairs['BAT']   = 0x0000000000000000000000000000000000000000;
        uniswapPairs['COMP']  = 0x35A18000230DA775CAc24873d00Ff85BccdeD550;
        uniswapPairs['DAI']   = 0xa1484C3aa22a66C62b77E0AE78E15258bd0cB711;
        uniswapPairs['UNI']   = 0x0000000000000000000000000000000000000000;
        uniswapPairs['USDC']  = 0x0000000000000000000000000000000000000000;
        uniswapPairs['WBTC']  = 0x17C30432ea0e2bA9347edBF73C2745A7183B573f;
        uniswapPairs['WETH']  = 0x0000000000000000000000000000000000000000;
        uniswapPairs['TWBTC'] = 0x0000000000000000000000000000000000000000;

        priceFeeds['CHAIN-ETH_USD'] = 0x0000000000000000000000000000000000000000;
    } else {
        // Kovan --------------------------------------------------------
        uniswapPairs['BAT']   = 0x482dC9bB08111CB875109B075A40881E48aE02Cd;
        uniswapPairs['COMP']  = 0x61460874a7196d6a22D1eE4922473664b3E95270;
        uniswapPairs['DAI']   = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
        uniswapPairs['UNI']   = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
        uniswapPairs['USDC']  = 0x69f923815d702575F0D0c64Ff5587e94fd5B1892;
        uniswapPairs['WBTC']  = 0x3BDb41FcA3956A72cd841696bD59ca860F3f0513;
        uniswapPairs['WETH']  = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;
        uniswapPairs['TWBTC'] = 0xe3C4f43E690Ed08C4887B284c6ee291059D38105;

        priceFeeds['CHAIN-ETH_USD'] = 0x9326BFA02ADD2366b30bacB125260Af641031331;
    }
  }

  function enterMarket(uint amount) public payable {
    require(msg.sender == owner,
      "The owner must be the contract creator"
    );

    uint deadline = block.timestamp + 25;

    // Split tokens, and deploy the swap
    uniswapRouter.swapExactETHForTokens{ 
      value: (msg.value / 6) 
    }(0, getPathForETHtoTOKEN('BAT'), address(this), deadline);
    
    uniswapRouter.swapExactETHForTokens{ 
      value: (msg.value / 6) 
    }(0, getPathForETHtoTOKEN('COMP'), address(this), deadline);
    
    uniswapRouter.swapExactETHForTokens{ 
      value: (msg.value / 6) 
    }(0, getPathForETHtoTOKEN('DAI'), address(this), deadline);
    
    uniswapRouter.swapExactETHForTokens{ 
      value: (msg.value / 6) 
    }(0, getPathForETHtoTOKEN('UNI'), address(this), deadline);
    
    uniswapRouter.swapExactETHForTokens{ 
      value: (msg.value / 6) 
    }(0, getPathForETHtoTOKEN('USDC'), address(this), deadline);
    
    uniswapRouter.swapExactETHForTokens{ 
      value: (msg.value / 6) 
    }(0, getPathForETHtoTOKEN('TWBTC'), address(this), deadline);

    // (No safe failures beyond this point)
    emit EnterMarket(msg.sender, msg.value, amount);

    (bool success,) = msg.sender.call{ 
      value: address(this).balance 
    }("");
    
    require(success, "#enterMarket, refund failed");
  }

  function exitMarket() public {
    require(msg.sender == owner,
      "The owner must be the contract creator"
    );

    _withdraw('BAT');
    _withdraw('COMP');
    _withdraw('DAI');
    _withdraw('UNI');
    _withdraw('USDC');
    _withdraw('TWBTC');

    emit ExitMarket(msg.sender);
  }

  function getEstimatedETHforBAT(uint batAmount) public view returns (uint[] memory) {
    return uniswapRouter.getAmountsIn(batAmount, getPathForETHtoTOKEN('BAT'));
  }

  function getEstimatedETHforCOMP(uint compAmount) public view returns (uint[] memory) {
    return uniswapRouter.getAmountsIn(compAmount, getPathForETHtoTOKEN('COMP'));
  }

  function getEstimatedETHforDAI(uint daiAmount) public view returns (uint[] memory) {
    return uniswapRouter.getAmountsIn(daiAmount, getPathForETHtoTOKEN('DAI'));
  }

  function getEstimatedETHforUSDC(uint usdcAmount) public view returns (uint[] memory) {
    return uniswapRouter.getAmountsIn(usdcAmount, getPathForETHtoTOKEN('USDC'));
  }

  function getEstimatedETHforUNI(uint uniAmount) public view returns (uint[] memory) {
    return uniswapRouter.getAmountsIn(uniAmount, getPathForETHtoTOKEN('UNI'));
  }

  function getEstimatedETHforTWBTC(uint twbtcAmount) public view returns (uint[] memory) {
    return uniswapRouter.getAmountsIn(twbtcAmount, getPathForETHtoTOKEN('TWBTC'));
  }

  function getPair(address tokenA, address tokenB) private view returns (address) {
    return uniswapFactory.getPair(tokenA, tokenB);
  }

  function getRootPair(address destination) private view returns (address) {
    return uniswapFactory.getPair(uniswapRouter.WETH(), destination);
  }

  function getPathForETHtoTOKEN(string memory token) private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = uniswapRouter.WETH();
    path[1] = uniswapPairs[token];

    return path;
  }

  function getTokenBalance(string memory symbol) public view returns (uint256) {
    IERC20 token = IERC20(uniswapPairs[symbol]);
    return token.balanceOf(address(this));
  }

  function getOracleAssetPrice(string memory symbol) public returns (int) {
    return oracle.getAssetLatestRoundData(symbol);
  }

  function _withdraw(string memory symbol) private {
    require(msg.sender == owner,
      "The owner must be the contract creator"
    );

    IERC20 token = IERC20(uniswapPairs[symbol]);

    uint256 balanceOfToken = token.balanceOf(address(this));

    require(balanceOfToken >= 0,
      "Token balance must be greater than 0"
    );

    token.transfer(owner, balanceOfToken);
  }

  // important to receive ETH
  receive() payable external {}
}
