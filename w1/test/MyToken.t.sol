// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {MyToken} from "src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken myToken;
    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");

    function setUp() public {
        vm.startPrank(deployer);
        myToken = new MyToken();
        vm.stopPrank();
    }

    function testTransferAcrossMultipleEOA() external {
        // mint token first
        vm.startPrank(deployer);
        myToken.mint(deployer, 100 ether);
        vm.stopPrank();

        assertEq(myToken.balanceOf(deployer), 100 ether);

        vm.startPrank(user1);
        myToken.mint(user1, 10 ether);
        vm.stopPrank();

        assertEq(myToken.balanceOf(user1), 10 ether);

        vm.startPrank(user2);
        myToken.mint(user2, 9 ether);
        vm.stopPrank();

        assertEq(myToken.balanceOf(user2), 9 ether);

        vm.startPrank(user3);
        myToken.mint(user3, 8 ether);
        vm.stopPrank();

        assertEq(myToken.balanceOf(user3), 8 ether);

        // transfer tokens across eoa
        vm.startPrank(user1);
        myToken.transfer(user2, 5 ether);
        vm.stopPrank();

        assertEq(myToken.balanceOf(user1), 5 ether);
        assertEq(myToken.balanceOf(user2), 14 ether);

        vm.startPrank(user2);
        myToken.transfer(user3, 4 ether);
        vm.stopPrank();

        assertEq(myToken.balanceOf(user2), 10 ether);
        assertEq(myToken.balanceOf(user3), 12 ether);

        vm.startPrank(user3);
        myToken.transfer(user1, 3 ether);
        vm.stopPrank();

        assertEq(myToken.balanceOf(user1), 8 ether);
        assertEq(myToken.balanceOf(user3), 9 ether);

        vm.startPrank(user1);
        myToken.approve(user2, 3 ether);
        vm.stopPrank();

        vm.startPrank(user2);
        myToken.transferFrom(user1, user3, 2 ether);

        assertEq(myToken.balanceOf(user1), 6 ether);
        assertEq(myToken.balanceOf(user3), 11 ether);

        uint256 allowance = myToken.allowance(user1, user2);
        myToken.transferFrom(user1, user2, allowance);

        assertEq(myToken.balanceOf(user1), 5 ether);
        assertEq(myToken.balanceOf(user2), 11 ether);

        vm.stopPrank();
    }
}
