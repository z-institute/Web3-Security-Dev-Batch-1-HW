// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console, stdError} from "forge-std/Test.sol";
import {Mytoken} from "../src/Mytoken.sol";

contract TokenERC20Test is Test {
    //variables
    Mytoken public token;
    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");

    function setUp() public {
        vm.prank(deployer);
        token = new Mytoken();
    }

    function testTransferAcrossMultipleAccount() public {
        //deployer as an owner mint 100 tokens
        vm.startPrank(deployer);
        console.log(token.balanceOf(deployer));
        token.mint(deployer, 100);
        console.log(token.owner());
        console.log(token.balanceOf(deployer));
        assertEq(token.balanceOf(deployer), 100);
        vm.stopPrank();
        //user1,2,3 mint 10,9,8 tokens
        vm.startPrank(user1);
        token.mint(10);
        assertEq(token.balanceOf(user1), 10);
        vm.stopPrank();

        vm.startPrank(user2);
        token.mint(9);
        assertEq(token.balanceOf(user2), 9);
        vm.stopPrank();

        vm.startPrank(user3);
        token.mint(8);
        assertEq(token.balanceOf(user3), 8);
        vm.stopPrank();
        //transfer between users
        vm.startPrank(user1);
        assertEq(token.transfer(user2, 5), true);
        assertEq(token.balanceOf(user1), 10 - 5);
        assertEq(token.balanceOf(user2), 9 + 5);
        vm.stopPrank();

        vm.startPrank(user2);
        assertEq(token.transfer(user3, 4), true);
        assertEq(token.balanceOf(user2), 14 - 4);
        assertEq(token.balanceOf(user3), 8 + 4);
        vm.stopPrank();

        vm.startPrank(user3);
        assertEq(token.transfer(user1, 3), true);
        assertEq(token.balanceOf(user3), 12 - 3);
        assertEq(token.balanceOf(user1), 5 + 3);
        vm.stopPrank();
        //user1 approve user2 to transfer 2 tokens
        vm.startPrank(user1);
        assertEq(token.approve(user2, 3), true);
        vm.stopPrank();
        //user2 use user1's allowance to transfer tokens to other user
        vm.startPrank(user2);
        assertEq(token.transferFrom(user1, user3, 2), true);
        assertEq(token.transferFrom(user1, user2, 1), true);
        vm.stopPrank();
    }
    //function test_transfer() public {
    //    vm.prank(deployer);
    //    assertEq(token.transfer(user1, 100), true);
    //    assertEq(token.balanceOf(deployer), 100 * (10 ** uint256(18)) - 100);
    //}
}
