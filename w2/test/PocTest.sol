// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/PocToken.sol";
import "../src/UncheckedMath.sol";

contract pocTest is Test {
    PocToken pocToken;
    UncheckedMath uncheckedMath;

    address public owner = address(0);
    address public alice = address(1);
    address public bob = address(2);

    function setUp() public {
        vm.startPrank(owner);
        pocToken = new PocToken();
        pocToken.mint(alice, 1000);
        vm.stopPrank();
    }

    function testPoc() public {
        vm.startPrank(alice);
        // Alice approve to bob.
        pocToken.approve(bob, 100);
        vm.stopPrank();

        uint256 alice_allowance = pocToken.allowance(alice, bob);
        console.log("Alice's allowance to Bob: %s", alice_allowance);
        assertEq(alice_allowance, 100);
        vm.startPrank(bob);
        // Bob transfer from Alice to Bob.
        pocToken.transferFrom(alice, bob, 100);
        uint256 bob_balance = pocToken.balanceOf(bob);
        console.log("Bob's balance: %s", bob_balance);
        vm.startPrank(alice);
        pocToken.approve(bob, 50);

        alice_allowance = pocToken.allowance(alice, bob);
        console.log("Alice's allowance to Bob: %s", alice_allowance);
        assertEq(alice_allowance, 50);
    }

    function testuncheckedMath() public {
        uncheckedMath = new UncheckedMath();
        uint8 x = 255;
        uint8 y = 5;
        // pass
        uncheckedMath.add(x, y);
        // no pass arithmetic underflow or overflow (0x11)
        vm.expectRevert(stdError.arithmeticError);
        uncheckedMath.addChecked(x, y);
    }

    function testCheckedGas() public {
        uncheckedMath = new UncheckedMath();
        uint8 x = 1;
        uint8 y = 2;
        // 131883 gas
        uncheckedMath.addChecked(x, y);
    }

    function testUncheckedGas() public {
        uncheckedMath = new UncheckedMath();
        uint8 x = 1;
        uint8 y = 2;
        // 131737 gas
        uncheckedMath.add(x, y);
    }

    function testContractCodeSize0() public {
        // 0x11
        //vm.expectRevert(stdError.contractCodeSize0);
        PocToken pocToken2;
        pocToken2 = new PocToken();
        uint256 size;
        uint256 size2;
        assembly {
            size := extcodesize(pocToken2)
        }

        console.log(bob);
        assembly {
            size2 := extcodesize(0x0000000000000000000000000000000000000002)
        }
        assertEq(size2, 0);
    }
}
