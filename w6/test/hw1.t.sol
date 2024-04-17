// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {SwordGame} from "src/hw1.sol";
import {AttackSwordGame} from "src/attackHw1.sol";

contract exploitNFTTest is Test {
    SwordGame swordGame;
    AttackSwordGame attackSwordGame;
    address public owner = address(1);
    address public hacker = address(1337);

    function setUp() public {
        vm.startPrank(owner);
        swordGame = new SwordGame();
        attackSwordGame = new AttackSwordGame(address(swordGame));
        vm.stopPrank();

        vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker);
        vm.deal(address(attackSwordGame), 10 ether);
        attackSwordGame.attack{value: 1 ether}();
        vm.stopPrank();

        assertEq(swordGame.balanceOf(hacker, 1), 10);
    }
}
