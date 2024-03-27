// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {NonReentrantBank} from "src/hw/hw2.sol";

contract exploitNonReentrantBankTest is Test {
    NonReentrantBank nonReentrantBank;
    address public owner = address(0);
    address public hacker = address(1337);

    function setUp() public {
        vm.startPrank(owner);
        nonReentrantBank = new NonReentrantBank();
        vm.stopPrank();

        vm.deal(address(nonReentrantBank), 10 ether);
        vm.deal(hacker, 1 ether);
    }

    function testExploit() external {
        vm.startPrank(hacker);
        // add your solution here
        vm.stopPrank();

        assertEq(address(hacker).balance, 11 ether);
    }
}
