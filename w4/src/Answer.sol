// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Answer {
    function answer() public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)));
    }
}
