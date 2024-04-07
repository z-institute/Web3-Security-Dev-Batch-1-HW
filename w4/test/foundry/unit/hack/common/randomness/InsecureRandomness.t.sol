// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";
import { Test, console } from "forge-std/Test.sol";
import { InsecureRandomness } from "contracts/hack/common/randomness/InsecureRandomness.sol";
import { InsecureRandomnessAttacker } from "contracts/hack/common/randomness/InsecureRandomness.sol";

contract insecureRandomnessTest is Test {
    InsecureRandomness game;
    InsecureRandomnessAttacker attack;
    address public someUser = address(0x123);
    address public attacker = address(0x456);

    function setUp() public {
        //setup game with 1 ether as reward
        game = new InsecureRandomness{ value: 1 ether }();
        attack = new InsecureRandomnessAttacker(game);
    }

    function testSuccessful() public {
        // A user  play the game
        vm.prank(someUser);
        //  user input a number and receive reward address
        game.guess(102, someUser);
        // user did not guess the right ans
        assertEq(address(someUser).balance, 0);
    }

    function testExploit() public payable {
        /**
         * CODE YOUR EXPLOIT HERE
         */
        vm.startPrank(attacker);
        attack.attack();
        /**
         * SUCCESS CONDITIONS
         */
        assertEq(address(attacker).balance, 1 ether);
    }
}
