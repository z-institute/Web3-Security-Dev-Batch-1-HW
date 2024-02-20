// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {
    Token token;
    address public deployer = vm.addr(1);
    address public user1 = vm.addr(2);
    address public user2 = vm.addr(3);
    address public user3 = vm.addr(4);

    function setUp() public {
        vm.startPrank(deployer);
        token = new Token();
        vm.stopPrank();
    }

    function test_TransferAcrossMultipleAccounts() public {
        vm.startPrank(user1);
        token.mint(user1, 10 * 10 ** 18);
        assertEq(token.balanceOf(user1), 10 * 10 ** 18);

        vm.startPrank(user2);
        token.mint(user2, 9 * 10 ** 18);
        assertEq(token.balanceOf(user2), 9 * 10 ** 18);

        vm.startPrank(user3);
        token.mint(user3, 8 * 10 ** 18);
        assertEq(token.balanceOf(user3), 8 * 10 ** 18);

        vm.startPrank(user1);
        token.transfer(user2, 5 * 10 ** 18);
        assertEq(token.balanceOf(user1), 5 * 10 ** 18);
        assertEq(token.balanceOf(user2), 14 * 10 ** 18);

        vm.startPrank(user2);
        token.transfer(user3, 4 * 10 ** 18);
        assertEq(token.balanceOf(user2), 10 * 10 ** 18);
        assertEq(token.balanceOf(user3), 12 * 10 ** 18);

        vm.startPrank(user3);
        token.transfer(user1, 3 * 10 ** 18);
        assertEq(token.balanceOf(user3), 9 * 10 ** 18);
        assertEq(token.balanceOf(user1), 8 * 10 ** 18);

        vm.startPrank(user1);
        token.approve(user2, 3 * 10 ** 18);
        assertEq(token.allowance(user1, user2), 3 * 10 ** 18);

        vm.startPrank(user2);
        token.transferFrom(user1, user3, 2 * 10 ** 18);
        assertEq(token.balanceOf(user1), 6 * 10 ** 18);
        assertEq(token.balanceOf(user3), 11 * 10 ** 18);
        assertEq(token.allowance(user1, user2), 10 ** 18);

        console2.log(token.balanceOf(user1)); // 6 * 10 ** 18
        console2.log(token.balanceOf(user2)); // 10 * 10 ** 18
        console2.log(token.allowance(user1, user2)); // 10 ** 18
        console2.log(user2); // 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69

        bytes4 selector = bytes4(keccak256("ERC20InsufficientAllowance(address,uint256,uint256)"));
        // console2.logBytes(abi.encodeWithSelector(selector, address(0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69), 1, 6));
        // vm.expectRevert(abi.encodeWithSelector(selector, 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69, 1, 6));
        vm.expectRevert(abi.encodeWithSelector(selector, user2, token.allowance(user1, user2), token.balanceOf(user1)));
        token.transferFrom(user1, user2, token.balanceOf(user1));
        vm.stopPrank();
    }

    function test_Mint() public {
        vm.startPrank(user1);
        token.mint(user1, 10 * 10 ** 18);
        assertEq(token.balanceOf(user1), 10 * 10 ** 18);
    }
}
