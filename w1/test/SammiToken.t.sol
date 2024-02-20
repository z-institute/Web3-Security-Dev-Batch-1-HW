// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SammiToken} from "../src/SammiToken.sol";

contract SammiTokenTest is Test {
    SammiToken public sammiToken;
    address public _deployer;

    function setUp() public {
        sammiToken = new SammiToken();
        _deployer = sammiToken.deployer();
    }

    function test_mint_deployer() public {
        sammiToken.mint(_deployer, 100);
        assertEq(sammiToken.balanceOf(_deployer), 100 * 10 ** 18);
    }

    function test_mint_user() public {
        uint256 eth = 10 ** uint256(sammiToken.decimals());

        address user1 = vm.addr(0x1111);
        address user2 = vm.addr(0x2222);
        address user3 = vm.addr(0x3333);

        //user mint
        sammiToken.mint(user1, 10);
        sammiToken.mint(user2, 9);
        sammiToken.mint(user3, 8);
        assertEq(sammiToken.balanceOf(user1), 10 * eth);
        assertEq(sammiToken.balanceOf(user2), 9 * eth);
        assertEq(sammiToken.balanceOf(user3), 8 * eth);

        //user transfer
        vm.prank(user1);
        sammiToken.transfer(user2, 5 * eth);
        assertEq(sammiToken.balanceOf(user1), 5 * eth);
        assertEq(sammiToken.balanceOf(user2), 14 * eth);

        vm.prank(user2);
        sammiToken.transfer(user3, 4 * eth);
        assertEq(sammiToken.balanceOf(user2), 10 * eth);
        assertEq(sammiToken.balanceOf(user3), 12 * eth);

        vm.prank(user3);
        sammiToken.transfer(user1, 3 * eth);
        assertEq(sammiToken.balanceOf(user1), 8 * eth);
        assertEq(sammiToken.balanceOf(user3), 9 * eth);

        //user approve
        vm.prank(user1);
        sammiToken.approve(user2, 3 * eth);
        assertEq(sammiToken.allowance(user1, user2), 3 * eth);

        vm.prank(user2);
        sammiToken.transferFrom(user1, user3, 2 * eth);
        assertEq(sammiToken.balanceOf(user1), 6 * eth);
        assertEq(sammiToken.balanceOf(user3), 11 * eth);

        vm.prank(user2);
        sammiToken.transferFrom(user1, user2, 1 * eth);
        assertEq(sammiToken.balanceOf(user1), 5 * eth);
        assertEq(sammiToken.balanceOf(user2), 11 * eth);
    }
}
