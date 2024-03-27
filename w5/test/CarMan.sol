// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CarMan} from "../src/CarMan.sol";

contract CarManTest is Test {
    CarMan carMan;
    address DEPLOYER_ADDRESS;
    address[] public temp;
    address addrFirst = 0x3f17f1962B36e491b30A40b2405849e597Ba5FB5;
    address addrLast = 0xe30284D5FB0c6C26264da5F6d5D8fc2498C52421;

    function setUp() public {
        carMan = new CarMan(
            "CarMan_Metaverse", "CMM", "ipfs://QmYvJEw4LHBpaehH6mYZV9YXC372QSWL4BPFVJvUkKqRCg/", "ipfs://.../"
        );
        DEPLOYER_ADDRESS = carMan.owner();
        carMan.addController(DEPLOYER_ADDRESS); // deployer can addController
        carMan.setPreSalePause(false); // deployer/controller can setPreSalePause
        for (uint256 i = 0; i < 800; i++) {
            address randomish = address(uint160(uint256(keccak256(abi.encodePacked(i, blockhash(block.number))))));
            temp.push(randomish);
        }
        temp.push(DEPLOYER_ADDRESS);
        carMan.whitelistUsers(temp);
    }
    // A simple unit test
    // test that the contract is deployed with the correct owner

    // function testDeployerCanMint(uint256 x) public {
    //     assertEq(carMan.totalSupply(), 0); // nothing minted before
    //     if (x > carMan.maxMintAmount()) {
    //         carMan.preSaleMint(10);
    //         assertEq(carMan.totalSupply(), carMan.maxMintAmount());
    //     } else if (x > 0) {
    //         carMan.preSaleMint(x);
    //         assertEq(carMan.totalSupply(), x);
    //     }
    // }

    function testWLMintFirst() public {
        vm.startPrank(addrFirst);
        carMan.preSaleMint(10);
    }

    function testWLMintLast() public {
        vm.startPrank(addrLast);
        carMan.preSaleMint(10);
    }
}
