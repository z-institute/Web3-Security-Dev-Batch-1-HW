// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "../src/Token.sol";

contract TokenScript is Script {
    function setUp() public pure {}

    function run() public {
        // vm.broadcast();
        uint256 privateKey = vm.envUint("DEV_PRIVATE_KEY");
        address deployer = vm.addr(privateKey);
        // console2.log("deployer address: ", deployer);
        uint256 user1PrivateKey = vm.envUint("USER1_PRIVATE_KEY");
        address user1 = vm.addr(user1PrivateKey);
        uint256 user2PrivateKey = vm.envUint("USER2_PRIVATE_KEY");
        address user2 = vm.addr(user2PrivateKey);
        uint256 user3PrivateKey = vm.envUint("USER3_PRIVATE_KEY");
        address user3 = vm.addr(user3PrivateKey);

        vm.startBroadcast(privateKey);
        // deploy contract
        Token tk = new Token(); // msg.sender
        console2.log(tk.balanceOf(deployer));
        vm.stopBroadcast();

        // user mint
        vm.startBroadcast(user1PrivateKey);
        tk.mint(user1, 10 * 10 ** 18);
        console2.log(tk.balanceOf(user1));
        vm.stopBroadcast();

        vm.startBroadcast(user2PrivateKey);
        tk.mint(user2, 9 * 10 ** 18);
        console2.log(tk.balanceOf(user2));
        vm.stopBroadcast();

        vm.startBroadcast(user3PrivateKey);
        tk.mint(user3, 8 * 10 ** 18);
        console2.log(tk.balanceOf(user3));
        vm.stopBroadcast();

        vm.startBroadcast(user1PrivateKey);
        tk.transfer(user2, 5 * 10 ** 18);
        console2.log(tk.balanceOf(user1)); // 5 * 10 ** 18
        console2.log(tk.balanceOf(user2)); // 14 * 10 ** 18
        vm.stopBroadcast();

        vm.startBroadcast(user2PrivateKey);
        tk.transfer(user3, 4 * 10 ** 18);
        console2.log(tk.balanceOf(user2)); // 10 * 10 ** 18
        console2.log(tk.balanceOf(user3)); // 12 * 10 ** 18
        vm.stopBroadcast();

        vm.startBroadcast(user3PrivateKey);
        tk.transfer(user1, 3 * 10 ** 18);
        console2.log(tk.balanceOf(user3)); // 9 * 10 ** 18
        console2.log(tk.balanceOf(user1)); // 8 * 10 ** 18
        vm.stopBroadcast();

        vm.startBroadcast(user1PrivateKey);
        tk.approve(user2, 3 * 10 ** 18);
        console2.log(tk.allowance(user1, user2)); // 3 * 10 ** 18
        vm.stopBroadcast();

        vm.startBroadcast(user2PrivateKey);
        tk.transferFrom(user1, user3, 2 * 10 ** 18);
        console2.log(tk.balanceOf(user1)); // 6 * 10 ** 18
        console2.log(tk.balanceOf(user3)); // 11 * 10 ** 18
        console2.log(tk.allowance(user1, user2)); // 10 ** 18

        // tk.transferFrom(user1, user2, tk.balanceOf(user1)); // ERC20InsufficientAllowance
        vm.stopBroadcast();
    }
}
