// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MyToken} from "../src/MyToken.sol";

contract DeployMyToken is Script {
    function run() public returns (MyToken) {
        vm.startBroadcast();
        MyToken Mt = new MyToken();
        vm.stopBroadcast();
        return Mt;
    }
}
