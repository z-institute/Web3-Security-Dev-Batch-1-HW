// SPDX-License-Identifier: UNLICENSED

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

pragma solidity 0.8.20;

contract MyToken is ERC20 {
    address public owner;
    mapping(address account => uint256 amount) public mintedTokenAmount;

    error InvalidAmount();

    constructor() ERC20("MyToken", "MTK") {
        owner = msg.sender;
    }

    // implement a public mint function
    // it allows anyone, except the developer, to mint 10 tokens for themselves,
    // while the developer is not restricted by the limitation of minting only 10 tokens.
    function mint(address to, uint256 amount) public returns (uint256) {
        mintedTokenAmount[msg.sender] += amount;

        if (msg.sender == owner) {
            _mint(to, amount);
        } else {
            if (mintedTokenAmount[msg.sender] > 10 ether) revert InvalidAmount();
            _mint(to, amount);
        }

        return amount;
    }
}
