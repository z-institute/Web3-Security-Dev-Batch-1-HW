// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";
import {MyToken} from "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public myToken;
    address admin = msg.sender;
    address user1 = vm.addr(1);
    address user2 = vm.addr(2);
    address user3 = vm.addr(3);

    function setUp() public {
        myToken = new MyToken();
    }

    function test_DefaultAdmin_Mint_100_Tokens() public {
        myToken.mint(admin, 100 ether);

        uint256 adminBalance = myToken.balanceOf(admin);
        assertEq(adminBalance, 100 ether);
    }

    function test_User_Cannot_Mint_More_then_10_Tokens(address user) public {
        vm.assume(user != admin);

        vm.startPrank(user);
        myToken.mint(user, 10 ether);
        vm.expectRevert("Cannot mint more than 10 tokens.");
        myToken.mint(user, 1 ether);
        vm.stopPrank();
    }

    function test_User1_Mint_10_Tokens() public {
        vm.prank(user1);
        myToken.mint(user1, 10 ether);

        uint256 user1Balance = myToken.balanceOf(user1);
        assertEq(user1Balance, 10 ether);
    }

    function test_User2_Mint_9_Tokens() public {
        vm.prank(user2);
        myToken.mint(user2, 9 ether);

        uint256 user2Balance = myToken.balanceOf(user2);
        assertEq(user2Balance, 9 ether);
    }

    function test_User3_Mint_8_Tokens() public {
        vm.prank(user3);
        myToken.mint(user3, 8 ether);

        uint256 user3Balance = myToken.balanceOf(user3);
        assertEq(user3Balance, 8 ether);
    }

    function test_User1_Transfer_5_Tokens_To_User2() public {
        vm.startPrank(user1);
        myToken.mint(user1, 5 ether);

        uint256 user1BalanceBefore = myToken.balanceOf(user1);
        uint256 user2BalanceBefore = myToken.balanceOf(user2);

        myToken.transfer(user2, 5 ether);

        uint256 user1BalanceAfter = myToken.balanceOf(user1);
        uint256 user2BalanceAfter = myToken.balanceOf(user2);

        assertEq(user1BalanceBefore - 5 ether, user1BalanceAfter);
        assertEq(user2BalanceBefore + 5 ether, user2BalanceAfter);
        vm.stopPrank();
    }

    function test_User2_Transfer_4_Tokens_To_User3() public {
        vm.startPrank(user2);
        myToken.mint(user2, 4 ether);

        uint256 user2BalanceBefore = myToken.balanceOf(user2);
        uint256 user3BalanceBefore = myToken.balanceOf(user3);

        myToken.transfer(user3, 4 ether);

        uint256 user2BalanceAfter = myToken.balanceOf(user2);
        uint256 user3BalanceAfter = myToken.balanceOf(user3);

        assertEq(user2BalanceBefore - 4 ether, user2BalanceAfter);
        assertEq(user3BalanceBefore + 4 ether, user3BalanceAfter);
        vm.stopPrank();
    }

    function test_User3_Transfer_3_Tokens_To_User1() public {
        vm.startPrank(user3);
        myToken.mint(user3, 3 ether);

        uint256 user3BalanceBefore = myToken.balanceOf(user3);
        uint256 user1BalanceBefore = myToken.balanceOf(user1);

        myToken.transfer(user1, 3 ether);

        uint256 user3BalanceAfter = myToken.balanceOf(user3);
        uint256 user1BalanceAfter = myToken.balanceOf(user1);

        assertEq(user3BalanceBefore - 3 ether, user3BalanceAfter);
        assertEq(user1BalanceBefore + 3 ether, user1BalanceAfter);
        vm.stopPrank();
    }

    function test_User1_Approve_3_Tokens_To_User2() public {
        vm.startPrank(user1);
        myToken.approve(user2, 3 ether);

        uint256 allowance = myToken.allowance(user1, user2);
        assertEq(allowance, 3 ether);
        vm.stopPrank();
    }

    function test_User2_TransferFrom_User1_2_Tokens_To_User3() public {
        vm.startPrank(user1);
        myToken.mint(user1, 3 ether);
        myToken.approve(user2, 3 ether);
        vm.stopPrank();

        uint256 allowance = myToken.allowance(user1, user2);
        assertEq(allowance, 3 ether);

        uint256 user1BalanceBefore = myToken.balanceOf(user1);
        uint256 user2BalanceBefore = myToken.balanceOf(user2);
        uint256 user3BalanceBefore = myToken.balanceOf(user3);

        vm.startPrank(user2);
        myToken.transferFrom(user1, user3, 2 ether);
        myToken.transferFrom(user1, user2, 1 ether);

        uint256 user1BalanceAfter = myToken.balanceOf(user1);
        uint256 user2BalanceAfter = myToken.balanceOf(user2);
        uint256 user3BalanceAfter = myToken.balanceOf(user3);

        assertEq(user1BalanceBefore - 3 ether, user1BalanceAfter);
        assertEq(user2BalanceBefore + 1 ether, user2BalanceAfter);
        assertEq(user3BalanceBefore + 2 ether, user3BalanceAfter);
        vm.stopPrank();
    }
}
