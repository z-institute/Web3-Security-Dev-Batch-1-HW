// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SwordGame is ERC1155, Ownable {
    uint16 public maxSupplyForTokenId = 10;

    mapping(address => bool) private claimed;
    mapping(uint256 => uint256) private totalSupplyForTokenId;

    constructor() ERC1155("sword") Ownable(msg.sender) {}

    function setURI(string memory _newuri) public onlyOwner {
        _setURI(_newuri);
    }

    function mint(uint256 tokenId) external payable returns(uint256) {
	    require(msg.value == 1 ether, "not enough eth");
        require(!claimed[msg.sender], "already claimed");
        require(totalSupplyForTokenId[tokenId] <= maxSupplyForTokenId, "reach max supply");

    	totalSupplyForTokenId[tokenId]++;
		_mint(msg.sender, tokenId, 1, "");
    	claimed[msg.sender] = true;

        return totalSupplyForTokenId[tokenId];
	}
}
