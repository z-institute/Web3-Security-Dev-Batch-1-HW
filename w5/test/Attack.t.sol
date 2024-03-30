// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {CryptoCurrencyStore} from "../src/CryptoCurrencyStore.sol";
import {AttackCryptoCurrencyStore} from "../src/AttackCryptoCurrencyStore.sol";

contract TokenTest is Test {
    CryptoCurrencyStore ccs;
    address public owner = address(0);
    address public hacker = address(1337);

    function setUp() public {
        vm.startPrank(owner);
        ccs = new CryptoCurrencyStore();
        vm.stopPrank();

        vm.deal(address(ccs), 3 ether);
        vm.deal(hacker, 1 ether);
        console2.log("Contract balance before attack", ccs.getBalance()); // 3 ether before attack
    }

    function testExploit() public {
        vm.startPrank(hacker);
        AttackCryptoCurrencyStore attack = new AttackCryptoCurrencyStore(address(ccs));
        attack.attack{value: 1 ether}();
        console2.log("Contract balance after attack", ccs.getBalance()); // 0 ether after attack
        vm.stopPrank();
    }
}
