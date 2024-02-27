// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "contracts/MockERC20.sol";
import "forge-std/Script.sol";

contract DeployTokenImplementation is Script {
    function run() public {
        // Use address provided in config to broadcast transactions
        vm.startBroadcast();
        // Deploy the ERC-20 token
        MockERC20 implementation = new MockERC20("test name", "test symbol");
        // Stop broadcasting calls from our address
        vm.stopBroadcast();
        // Log the token address
        console.log("Token Implementation Address:", address(implementation));
    }
}
