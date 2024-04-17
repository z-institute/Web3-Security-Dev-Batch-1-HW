// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
// import {DeployMyToken} from "../script/DeployMyToken.s.sol";
import {MyToken} from "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken myToken;

    address deployer = address(this);
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");

    function setUp() public {
        myToken = new MyToken();
    }
    // WH1-1

    function testMint() public {
        uint256 mintAmount = 20 ether;
        myToken.mint(address(this), mintAmount);
        assertEq(myToken.balanceOf(address(this)), mintAmount);
    }

    function testUser1OverMint() public {
        uint256 mintAmount = 20 ether;
        vm.prank(user1);
        vm.expectRevert(bytes("Exceeds limit"));
        myToken.mint(user1, mintAmount);
    }

    function testUser1NotOverMint() public {
        uint256 mintAmount = 1 ether;
        vm.prank(user1);
        myToken.mint(user1, mintAmount);
        assertEq(myToken.balanceOf(user1), mintAmount);
    }
    // WH1-2

    function testMultipleAccounts() public {
        // deployer mint 100 tokens for itself
        uint256 mintAmount = 100 ether;
        vm.startPrank(deployer);
        myToken.mint(deployer, mintAmount);
        assertEq(myToken.balanceOf(deployer), mintAmount);

        // user1, user2, user3 mint 10, 9, 8 tokens respectively
        vm.startPrank(user1);
        mintAmount = 10 ether;
        myToken.mint(user1, mintAmount);

        vm.startPrank(user2);
        mintAmount = 9 ether;
        myToken.mint(user2, mintAmount);

        assertEq(myToken.balanceOf(user2), mintAmount);

        vm.startPrank(user3);
        mintAmount = 8 ether;
        myToken.mint(user3, mintAmount);
        assertEq(myToken.balanceOf(user3), mintAmount);

        // user1 5 tokens to user2
        vm.startPrank(user1);
        uint256 transferAmount = 5 ether;
        myToken.transfer(user2, transferAmount);

        assertEq(myToken.balanceOf(user2), 14 ether);
        assertEq(myToken.balanceOf(user1), 5 ether);

        // user2 4 tokens to user3
        vm.startPrank(user2);
        transferAmount = 4 ether;
        myToken.transfer(user3, transferAmount);

        assertEq(myToken.balanceOf(user2), 10 ether);
        assertEq(myToken.balanceOf(user3), 12 ether);
        // user3 3 tokens to user1
        vm.startPrank(user3);
        transferAmount = 3 ether;
        myToken.transfer(user1, transferAmount);

        assertEq(myToken.balanceOf(user3), 9 ether);
        assertEq(myToken.balanceOf(user1), 8 ether);

        // user1 approve user2 to transfer his 3 tokens
        vm.startPrank(user1);
        myToken.approve(user2, 3 ether);
        assertEq(myToken.allowance(user1, user2), 3 ether);

        // user2 transfers 2 tokens of user1 to user3 and transfers the remaining tokens to itself
        vm.startPrank(user2);
        myToken.transferFrom(user1, user3, 2 ether);
        myToken.transferFrom(user1, user2, 1 ether);

        assertEq(myToken.balanceOf(user1), 5 ether);
        assertEq(myToken.balanceOf(user2), 11 ether);
        assertEq(myToken.balanceOf(user3), 11 ether);

        console2.log(myToken.balanceOf(deployer));
        console2.log(myToken.balanceOf(user1));
        console2.log(myToken.balanceOf(user2));
        console2.log(myToken.balanceOf(user3));

        vm.stopPrank();
    }
}
