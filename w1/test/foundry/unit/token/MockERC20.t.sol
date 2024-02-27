// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "contracts/MockERC20.sol";
import "forge-std/console.sol";

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import {Utils} from "test/foundry/utils/Utils.sol";

contract MockERC20Test is Test,AccessControl {
    Utils internal utils;
    MockERC20 public mockToken;
    address internal deployer;
    address internal dev1;
    address internal dev2;
    address internal dev3;
    address payable[] internal users;

    // Set up the test environment before running tests
    function setUp() public {
        mockToken = new MockERC20("test name", "test symbol");
        utils = new Utils();
        users = utils.createUsers(4);
        deployer=address(this);
        dev1 = users[1];
        vm.label(dev1, "Developer1");
        dev2 = users[2];
        vm.label(dev2, "Developer2");
        dev3 = users[3];
        vm.label(dev3, "Developer3");
    }

    function test_Getter() external {
        assertEq(mockToken.name(), "test name");
        assertEq(mockToken.symbol(), "test symbol");
        assertEq(mockToken.decimals(), 18);
        assertEq(mockToken.totalSupply(), 0);
    }

   function testERC20_DeployerRoleAccess() public {
        // deployer was granted default role
        assertTrue(mockToken.hasRole(mockToken.ADMIN_ROLE(), address(this)));
        assertEq(mockToken.getRoleAdmin(mockToken.ADMIN_ROLE()), 0);
        uint256 mintAmount = 10000;
        vm.prank(deployer);
        mockToken.mint(deployer, mintAmount);
   }

    // Test the basic ERC20 functionality of the mock token contract
    function testERC20_Deployer_Mint_Functionality() public {
        uint256 mintAmount = 10000;
        vm.prank(deployer);
        mockToken.mint(deployer, mintAmount);
    }

    function test_setLimit_revertIfReachLimit() public {
        vm.prank(dev1);
        vm.expectRevert("EXCEEDS_LIMIT");
        mockToken.mint(dev1, 100);
    }

}
