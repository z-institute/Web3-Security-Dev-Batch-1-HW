// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Mytoken} from "src/Mytoken.sol";

contract MytokenScript is Script {
    function setUp() public {}

    function run() public {
        //forge script script/Mytoken.s.sol:MytokenScript --rpc-url $SEPOLIA_RPC_URL -vvvvv
        //forge script script/Mytoken.s.sol:MytokenScript --broadcast --etherscan-api-key $ETH_API_KEY --verify --rpc-url $SEPOLIA_RPC_URL
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        uint256 user1_private = vm.envUint("USER1_PRIVATE_KEY");
        address user1_addr = vm.addr(user1_private);
        uint256 user2_private = vm.envUint("USER2_PRIVATE_KEY");
        address user2_addr = vm.addr(user2_private);
        uint256 user3_private = vm.envUint("USER3_PRIVATE_KEY");
        address user3_addr = vm.addr(user3_private);

        vm.startBroadcast(deployerPrivateKey);
        //deploy the contract
        Mytoken c = new Mytoken();
        console2.log(c.owner());

        console2.log(user1_private);
        console2.log(user1_addr);
        c.mint(vm.addr(deployerPrivateKey), 100);
        console2.log("coin balance deployer:", c.balanceOf(deployer));
        vm.stopBroadcast();

        // user1 user2 user3 mint
        vm.startBroadcast(user1_private);
        c.mint(10);
        console2.log(c.balanceOf(user1_addr));
        vm.stopBroadcast();

        vm.startBroadcast(user2_private);
        c.mint(9);
        console2.log(c.balanceOf(user2_addr));
        vm.stopBroadcast();
        
        vm.startBroadcast(user3_private);
        c.mint(8);
        console2.log(c.balanceOf(user3_addr));
        vm.stopBroadcast();
        //user1 2 3 transfer -5 -4 -3
        vm.startBroadcast(user1_private);
        c.transfer(user2_addr, 5);
        console2.log(c.balanceOf(user1_addr)); // 5 
        console2.log(c.balanceOf(user2_addr)); // 14 
        vm.stopBroadcast();

        vm.startBroadcast(user2_private);
        c.transfer(user3_addr, 4);
        console2.log(c.balanceOf(user2_addr)); // 10
        console2.log(c.balanceOf(user3_addr)); // 12 
        vm.stopBroadcast();

        vm.startBroadcast(user3_private);
        c.transfer(user1_addr, 3);
        console2.log(c.balanceOf(user3_addr)); // 9 
        console2.log(c.balanceOf(user1_addr)); // 8 
        vm.stopBroadcast();

        //approve and send
        vm.startBroadcast(user1_private);
        c.approve(user2_addr, 3);
        console2.log(c.allowance(user1_addr, user2_addr)); // 3
        vm.stopBroadcast();

        vm.startBroadcast(user2_private);
        c.transferFrom(user1_addr, user3_addr, 2 );
        console2.log(c.balanceOf(user1_addr)); // 6 
        console2.log(c.balanceOf(user3_addr)); // 11 
        console2.log(c.allowance(user1_addr, user2_addr)); // 1
        c.transferFrom(user1_addr, user2_addr, c.allowance(user1_addr, user2_addr));
        console2.log(c.allowance(user1_addr, user2_addr)); // 0
        vm.stopBroadcast();


       
    }
}
