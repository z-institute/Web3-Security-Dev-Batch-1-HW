// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {SwordGame} from "src/hw/hw1.sol";

contract exploitNFTTest is Test {
    SwordGame swordGame;
    address public owner = address(0);
    address public hacker = address(1337);

    function setUp() public {
        vm.startPrank(owner);
        swordGame = new SwordGame();
        vm.stopPrank();

        vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker);
        // add your solution here
        vm.stopPrank();

        assertEq(swordGame.balanceOf(hacker, 1), 10);
    }
}
