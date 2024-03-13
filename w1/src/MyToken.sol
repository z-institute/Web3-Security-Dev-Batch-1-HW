// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract MyToken is ERC20, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    uint256 public constant MAX_MINT_AMOUNT = 10 ether;
    mapping(address => uint256) public mintedAmounts;

    constructor() ERC20("MyToken", "MTK") {
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public {
        if (hasRole(ADMIN_ROLE, _msgSender())) {
            _mint(to, amount);
        } else {
            require(mintedAmounts[to] + amount <= MAX_MINT_AMOUNT, "Cannot mint more than 10 tokens.");
            mintedAmounts[to] += amount;
            _mint(to, amount);
        }
    }
}
