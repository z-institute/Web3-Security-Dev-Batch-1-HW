// SPDX-License-Identifier: UNLICENSED
<<<<<<< HEAD
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

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
=======

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
>>>>>>> main
    }
}
