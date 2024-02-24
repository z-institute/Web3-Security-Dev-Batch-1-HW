pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract Token is ERC20 {
    address public immutable owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "TestERC20: only owner");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    )
        ERC20(name, symbol)
    {
        owner = msg.sender;
        _mint(msg.sender, initialSupply);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
