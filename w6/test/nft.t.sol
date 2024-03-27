// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {NFT} from "src/example/nft.sol";
import {AttackNFT} from "src/example/attackNFT.sol";

contract exploitNFTTest is Test {
    NFT nft;
    address public owner = address(0);
    address public hacker = address(1337);

    function setUp() public {
        vm.startPrank(owner);
        nft = new NFT();
        vm.stopPrank();
    }

    function testExploit() public {
        vm.startPrank(hacker);
        AttackNFT attackNFT = new AttackNFT(address(nft));
        attackNFT.attack();
        vm.stopPrank();
    }
}
