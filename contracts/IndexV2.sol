// SPDX-License-Identifier: Bityield
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./lib/AddressArrayUtils.sol";
import "./interfaces/bityield/market.sol";

import { Comptroller, PriceFeed, Erc20, CErc20, CEth } from "./interfaces/compound/v2/main.sol";

contract IndexV2 is ERC20 {    
    using Address for address;
    using AddressArrayUtils for address[];
    using SafeMath for uint;
    using SafeMath for uint256;

    address internal owner;

    // balance; used to hold a more efficient set of balances per investor address
    // and token address
    struct balance {
        uint ethAmount;
        uint tokAmount;
    }

    // assetAddresses; this is an array of the tokens that will be held in this fund
    // A valid Uniswap pair must be present on the execution network to provide a swap
    address[] internal assetAddresses;

    // assetLimits; this maps the asset(a token's address) => to it's funding allocation maximum
    // example: {0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984 => 100000000000000000}
    mapping (address => uint256) internal assetLimits;

    // balances; one level deeper to hold the balance of a specific token per an address
    // example: {0xInvestorAddress: {0xTokenAddress => (uint256 balance)}
    mapping (address => mapping (address => balance)) internal balances;

    address internal cEtherAddress;
    address internal cCompotrollerAddress;
    address internal cDaiAddress;
    address internal daiAddress;

    /* ============ Events ================= */
    event EnterMarket(
        address indexed from_,
        uint amountDeposited_,
        uint cTokens_,
        uint currentBlock_
    );

    event ExitMarket(
        address indexed from_,
        uint amountWithdrawn_,
        uint cTokens_,
        uint currentBlock_
    );

    event Log(
        string _message, 
        uint256 _amount
    );

    /* ============ Constructor ============ */
    constructor(
        string memory _name,
        string memory _symbol,
        address _daiAddress,
        address _cDaiAddress,
        address _cEtherAddress,
        address _cCompotrollerAddress
    )
        public
        ERC20(_name, _symbol)
    {
        owner = msg.sender;

        daiAddress = _daiAddress;
        cDaiAddress = _cDaiAddress;
        cEtherAddress = _cEtherAddress;
        cCompotrollerAddress = _cCompotrollerAddress;
    }

    // enterMarket; is the main entry point to this contract. It takes msg.value and splits
    // to the allocation ceilings in wei. Any funds not used are returned to the sender
    function enterMarket()
        external
        payable
    {
        // Create a reference to the underlying asset contract, like DAI.
        Erc20 underlying = Erc20(daiAddress);

        // Create a reference to the corresponding cToken contract, like cDAI
        CErc20 cToken = CErc20(cDaiAddress);

        // Amount of current exchange rate from cToken to underlying
        uint256 exchangeRateMantissa = cToken.exchangeRateCurrent();
        emit Log("Exchange Rate (scaled up)", exchangeRateMantissa);

        // Amount added to you supply balance this block
        uint256 supplyRateMantissa = cToken.supplyRatePerBlock();
        emit Log("Supply Rate (scaled up)", supplyRateMantissa);

        uint256 _numTokensToSupply = 100;

        // Approve transfer on the ERC20 contract
        underlying.approve(cDaiAddress, _numTokensToSupply);
        emit Log("Underlying approved", _numTokensToSupply);

        // Mint cTokens
        uint mintResult = cToken.mint(_numTokensToSupply);
        if (mintResult == 0) {
            emit Log("Mint successful", mintResult);
        } else {
            emit Log("Mint failure", mintResult);
        }
        require(mintResult > 0, "unsuccesful mintResult");
    }

    function exitMarket()
        external
    {
        CErc20 cToken = CErc20(cDaiAddress);

        uint256 amount = 100;
        uint256 redeemResult;
        
        // Retrieve your asset based on a cToken amount
        // redeemResult = cToken.redeem(amount);

        // Retrieve your asset based on an amount of the asset
        redeemResult = cToken.redeemUnderlying(amount);

        // Error codes are listed here:
        // https://compound.finance/developers/ctokens#ctoken-error-codes
        emit Log("If this is not 0, there was an error", redeemResult);
    }

    // receive; required to accept ether
    receive()
        external
        payable
    {}

    function custodialWithdraw()
        public
    {
        require(msg.sender == owner, "cannot withdraw if not owner");

        (bool success,) = msg.sender.call{ value: address(this).balance }("");
        require(success, "custodialWithdraw; failed");
    }
}