// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {ReadOnlyReentranceVul} from "src/example/readOnlyVul.sol";
import {AttackReadOnlyVul} from "src/example/attackReadOnlyVul.sol";

contract exploitReadOnlyReentrancyTest is Test {
  AttackReadOnlyVul public attackReadOnlyVul;
  ReadOnlyReentranceVul public victim;

  function setUp() public {
    victim = new ReadOnlyReentranceVul();
    attackReadOnlyVul = new AttackReadOnlyVul(address(victim));
  }

  function testPwn() public {
    attackReadOnlyVul.setup{value: 10 ether}();
    attackReadOnlyVul.pwn{value: 100000 ether}();
  }
}
