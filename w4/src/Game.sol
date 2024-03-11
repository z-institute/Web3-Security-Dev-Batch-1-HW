// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Game {
    constructor() payable {}

    function guess(uint256 _guess, address _receiver) public {
        uint256 answer = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)));

        if (_guess == answer) {
            (bool sent,) = _receiver.call{value: address(this).balance}("");
            require(sent, "Failed to send Ether");
        }
    }

    receive() external payable {}
}
