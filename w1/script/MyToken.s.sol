// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {MyToken} from "src/MyToken.sol";

contract MyTokenScript is Script {
    MyToken myToken;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = vm.envAddress("DEPLOYER");

        uint256 user1PrivateKey = vm.envUint("USER1_PRIVATE_KEY");
        address user1 = vm.envAddress("USER1");

        uint256 user2PrivateKey = vm.envUint("USER2_PRIVATE_KEY");
        address user2 = vm.envAddress("USER2");

        uint256 user3PrivateKey = vm.envUint("USER3_PRIVATE_KEY");
        address user3 = vm.envAddress("USER3");

        // deploy a MyToken contract
        vm.startBroadcast(deployerPrivateKey);
        myToken = new MyToken();
        vm.stopBroadcast();

        // mint some tokens first
        vm.startBroadcast(deployerPrivateKey);
        myToken.mint(deployer, 100 ether);
        vm.stopBroadcast();

        vm.startBroadcast(user1PrivateKey);
        myToken.mint(user1, 10 ether);
        vm.stopBroadcast();

        vm.startBroadcast(user2PrivateKey);
        myToken.mint(user2, 9 ether);
        vm.stopBroadcast();

        vm.startBroadcast(user3PrivateKey);
        myToken.mint(user3, 8 ether);
        vm.stopBroadcast();

        // transfer tokens across eoa
        vm.startBroadcast(user1PrivateKey);
        myToken.transfer(user2, 5 ether);
        vm.stopBroadcast();

        vm.startBroadcast(user2PrivateKey);
        myToken.transfer(user3, 4 ether);
        vm.stopBroadcast();

        vm.startBroadcast(user3PrivateKey);
        myToken.transfer(user1, 3 ether);
        vm.stopBroadcast();

        vm.startBroadcast(user1PrivateKey);
        myToken.approve(user2, 3 ether);
        vm.stopBroadcast();

        vm.startBroadcast(user2PrivateKey);
        myToken.transferFrom(user1, user3, 2 ether);

        uint256 allowance = myToken.allowance(user1, user2);
        myToken.transferFrom(user1, user2, allowance);
        vm.stopBroadcast();
    }
}
