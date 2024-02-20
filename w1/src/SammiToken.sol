// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

error OnlyDeployerCanMintOver10();

contract SammiToken is ERC20 {
    address public deployer;

    constructor() ERC20("SammiToken", "ST") {
        deployer = msg.sender;
    }

    function mint(address to, uint256 amount) external {
        uint256 startGas = gasleft();

        uint256 notDeployerLimit = 10;

        if (deployer != to && balanceOf(to) + amount > notDeployerLimit) {
            revert OnlyDeployerCanMintOver10();
        }

        _mint(to, amount * 10 ** uint256(decimals()));

        console.log(startGas - gasleft());
    }
}
