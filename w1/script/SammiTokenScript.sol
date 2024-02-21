// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SammiToken} from "../src/SammiToken.sol";

contract SammiTokenScript is Script {
    function setUp() public {}

    function run() public {
        uint privateKey = vm.envUint("PRIVATE_KEY");
        address account = vm.addr(privateKey);
        console.log("Account", account);

        vm.startBroadcast(privateKey);
        SammiToken st = new SammiToken();
        st.mint(account, 100);
        vm.stopBroadcast();
    }
}
