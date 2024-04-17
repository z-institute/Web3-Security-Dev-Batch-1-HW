// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {SwordGame} from "src/hw/hw1.sol";
import {AttackHW1} from "src/example/attackHw1.sol";

contract exploitNFTTest is Test {
    SwordGame swordGame;
    AttackHW1 attackHW1;
    address public owner1 = address(1);
    address public hacker = address(1337);

    function setUp() public {
        vm.startPrank(owner1);
        swordGame = new SwordGame();
        attackHW1 = new AttackHW1(swordGame);
        vm.stopPrank();

        vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker);
        attackHW1.attack{value: 1 ether}();
        vm.stopPrank();
        assertEq(swordGame.balanceOf(hacker, 1), 10);
    }
}
