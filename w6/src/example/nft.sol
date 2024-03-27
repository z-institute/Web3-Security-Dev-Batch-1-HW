// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
    uint256 private _tokenIds;

    address public owner;
    uint16 public maxSupply = 3;

    mapping(address => bool) private claimed;

    constructor() ERC721("Vulnerability NFT", "NFT") {
        owner = msg.sender;
        ++_tokenIds;
    }

    function mint() external returns (uint16) {
        require(!claimed[msg.sender], "already claimed");

        // Check tokenId
        uint16 tokenId = uint16(_tokenIds);
        require(tokenId <= maxSupply, "Reach max supply!");
        ++_tokenIds;

        // Mint NFT
        _safeMint(msg.sender, tokenId);
        claimed[msg.sender] = true;
        return tokenId;
    }
}
