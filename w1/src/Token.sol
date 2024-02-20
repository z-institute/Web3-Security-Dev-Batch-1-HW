// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("Token", "TK") {
        _mint(msg.sender, 100 * (10 ** uint256(decimals())));
    }

    function mint(address to, uint256 amount) public {
        require(balanceOf(msg.sender) + amount <= 10 * 10 ** 18, "You can only mint less than 10");
        _mint(to, amount);
    }
}
