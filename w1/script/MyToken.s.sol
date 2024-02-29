// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MyToken} from "src/MyToken.sol";

contract MyTokenScript is Script {
    MyToken myToken;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = 
        vm.startBroadcast(deployerPrivateKey);
        myToken = new MyToken();

        myToken.mint()
        vm.stopBroadcast();
    }
}
