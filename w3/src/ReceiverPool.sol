// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {LenderPool} from "src/LenderPool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
/**
 * @title ReceiverPool
 */

contract ReceiverPool {
    LenderPool private immutable pool;
    address private immutable owner;

    constructor(address poolAddress) {
        pool = LenderPool(poolAddress);
        owner = msg.sender;
    }

    // Pool will call this function during the flash loan
    function receiveTokens(address tokenAddress, uint256 amount) external {
        require(msg.sender == address(pool), "Sender must be pool");
        // Return all tokens to the pool
        require(IERC20(tokenAddress).transfer(msg.sender, amount), "Transfer of tokens failed");
    }

    function executeFlashLoan(uint256 amount) external {
        require(msg.sender == owner, "Only owner can execute flash loan");
        pool.flashLoan(amount);
    }
}
