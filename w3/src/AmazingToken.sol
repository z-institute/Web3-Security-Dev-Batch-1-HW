// SPDX-License-Identifier: MIT

<<<<<<< HEAD
pragma solidity ^0.8.20;
=======
pragma solidity ^0.8.0;
>>>>>>> main

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Erc20Token
 */
contract AmazingToken is ERC20 {
    // Decimals are set to 18 by default in `ERC20`
    constructor() ERC20("AmazingToken", "Amz") {
        _mint(msg.sender, type(uint256).max);
    }
}
