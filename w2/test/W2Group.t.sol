// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {DaoToken} from "src/DaoToken.sol";

contract W2Group is Test {
    DaoToken daoToken;
    address public owner = address(0);
    address public hacker = address(1337);

    address public alice = address(1);
    address public bob = address(2);
    address public carol = address(3);
    address public bobAnotherAcct = address(999);
    function setUp() public {
        vm.startPrank(owner);
        daoToken = new DaoToken();
        daoToken.mint(alice, 1000);
        vm.stopPrank();
    }
    //Q10: The code size of an address greater than zero bytes is a contract.Does it mean the code size of an address equal zero bytes is a EOA? (Write a PoC to validate it)
    function testContractCodeSize() public {
        address contractAddr = address(daoToken);
		uint length = contractAddr.code.length;

		if(length > 0){
			console.log("contract length>0", length);
		} else {
			console.log("contract length==0", length);
		}
    }

    function testEOACodeSize() public{
		uint length = owner.code.length;
        
		assertEq(length , 0);
	}
    //Q6: What is the potential risk of directly overwriting the old value of _allowance? (Write a PoC to validate it)
    function testOverwrite() public {
        vm.prank(alice);
        daoToken.approve(bob, 100);

        vm.prank(bob);
        daoToken.transferFrom(alice, bobAnotherAcct, 100);

        vm.prank(alice);
        daoToken.approve(bob, 50);

        vm.prank(bob);
        uint256 allowanceMoney = daoToken.allowance(alice, bob);
        uint256 balance = daoToken.balanceOf(bobAnotherAcct);
        assertEq(allowanceMoney , 50);
        assertEq(balance, 100);
    }
}
