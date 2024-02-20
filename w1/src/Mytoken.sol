// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract Mytoken is ERC20, Ownable {
    uint256 public MAX_MINT_AMOUNT;
    mapping(address => uint256) public mintedAmounts;

    constructor() ERC20("MyToken", "MT") Ownable(msg.sender) {
        MAX_MINT_AMOUNT = 10; // 100 * (10 ** uint256(decimals()))
        //_mint(msg.sender, initialSupply);
    }

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    function mint(uint256 amount) public {
        require(mintedAmounts[msg.sender] + amount <= MAX_MINT_AMOUNT, "Exceeds max mint amount");

        _mint(msg.sender, amount);
        mintedAmounts[msg.sender] += amount;
    }
}
