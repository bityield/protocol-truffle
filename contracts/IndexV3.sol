// SPDX-License-Identifier: Bityield
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./lib/AddressArrayUtils.sol";
import "./interfaces/bityield/market.sol";

import { IaToken, IAaveLendingPool } from "./interfaces/aave/v2/main.sol";

contract IndexV3 is ERC20 {
    using Address for address;
    using AddressArrayUtils for address[];
    using SafeMath for uint;
    using SafeMath for uint256;

    address internal owner;

    mapping(address => uint256) public userDepositedDai;

    IERC20 public dai;
    IaToken public aToken;
    IAaveLendingPool public aaveLendingPool;

    /* ============ Constructor ============ */
    constructor(
        string memory _name,
        string memory _symbol
    )
        public
        ERC20(_name, _symbol)
    {
        owner = msg.sender;

        dai = IERC20(0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD);
        aToken = IaToken(0x58AD4cB396411B691A9AAb6F74545b2C5217FE6a);
        aaveLendingPool = IAaveLendingPool(0x580D4Fdc4BF8f9b5ae2fb9225D584fED4AD5375c);

        // approve the maximum dai
        dai.approve(address(aaveLendingPool), type(uint256).max);
    }

    function enterMarket()
        external
        payable
    {
        uint256 _amountInDai = 10;

        userDepositedDai[msg.sender] = _amountInDai;

        require(dai.transferFrom(msg.sender, address(this), _amountInDai), "DAI Transfer failed!");
        aaveLendingPool.deposit(address(dai), _amountInDai, 0);
    }

    function exitMarket()
        external
    {
        uint256 _amountInDai = 10;

        require(userDepositedDai[msg.sender] >= _amountInDai, "no balance present");

        aToken.redeem(_amountInDai);
        require(dai.transferFrom(address(this), msg.sender, _amountInDai), "DAI Transfer failed!");
        
        userDepositedDai[msg.sender] = userDepositedDai[msg.sender] - _amountInDai;
    }
}