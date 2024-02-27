
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import "forge-std/console.sol";

contract MockERC20 is ERC20,AccessControl {

   bytes32 immutable public ADMIN_ROLE = keccak256("ADMIN_ROLE");
   constructor(string memory name, string memory symbol)
    ERC20(name, symbol) {
        _grantRole(ADMIN_ROLE, msg.sender);
    }
    function mint(address _recipient, uint256 _amount) external {
        if (!hasRole(ADMIN_ROLE, msg.sender)) {
            require(balanceOf(_recipient) + _amount <= 10, "EXCEEDS_LIMIT");
        }
        _mint(_recipient, _amount);
    }
}
