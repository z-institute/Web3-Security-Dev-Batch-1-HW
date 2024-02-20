// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/console.sol";

contract MyToken is ERC20, AccessControl {
    // Create a new role identifier for the minter role
    bytes32 public constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");

    constructor() ERC20("MyToken", "TKN") {
        // Grant the minter role to a specified account
        _grantRole(DEPLOYER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public {
        //Check that the calling account has the minter role
        if (!hasRole(DEPLOYER_ROLE, msg.sender)) {
            require(balanceOf(to) + amount <= 10 ether, "Exceeds limit");
        }
        _mint(to, amount);
    }
}
