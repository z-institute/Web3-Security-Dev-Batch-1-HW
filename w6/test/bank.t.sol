// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Bank} from "src/example/bank.sol";
import {AttackBank} from "src/example/attackBank.sol";

contract exploitBankTest is Test {
    Bank bank;
    address public owner = address(0);
    address public hacker = address(1337);

    function setUp() public {
        vm.startPrank(owner);
        bank = new Bank();
        vm.stopPrank();

        vm.deal(address(bank), 3 ether);
        vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker);
        AttackBank attackBank = new AttackBank(address(bank));
        attackBank.attack{value: 1 ether}();
        vm.stopPrank();
    }
}
