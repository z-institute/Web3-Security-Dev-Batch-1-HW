pragma solidity ^0.8.0;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NonReentrantBank is ReentrancyGuard {
    mapping(address => uint256) private balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function transfer(address _to, uint256 _amount) external {
        if (balances[msg.sender] >= _amount) {
            balances[_to] += _amount;
            balances[msg.sender] -= _amount;
        }
    }

    function withdrawAll() external nonReentrant {
        // Apply the noReentrant modifier
        uint256 balance = balances[msg.sender];
        require(balance > 0, "Insufficient balance");

        (bool success,) = msg.sender.call{value: balance}("");
        require(success, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
