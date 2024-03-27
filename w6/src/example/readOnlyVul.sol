// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICurve {
    function get_virtual_price() external view returns (uint256);

    function add_liquidity(uint256[2] calldata amounts, uint256 min_mint_amount) external payable returns (uint256);

    function remove_liquidity(uint256 lp, uint256[2] calldata min_amounts) external returns (uint256[2] memory);

    function remove_liquidity_one_coin(uint256 lp, int128 i, uint256 min_amount) external returns (uint256);
}

contract ReadOnlyReentranceVul {
    IERC20 public constant token = IERC20(0x06325440D014e39736583c165C2963BA99fAf14E);
    ICurve private constant pool = ICurve(0xDC24316b9AE028F1497c275EB9192a3Ea0f67022);

    mapping(address => uint256) public balanceOf;

    function stake(uint256 amount) external {
        token.transferFrom(msg.sender, address(this), amount);
        balanceOf[msg.sender] += amount;
    }

    function unstake(uint256 amount) external {
        balanceOf[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
    }

    function getReward() external view returns (uint256) {
        uint256 reward = (balanceOf[msg.sender] * pool.get_virtual_price()) / 1e18;
        // transfer reward tokens (skip)
        return reward;
    }
}
