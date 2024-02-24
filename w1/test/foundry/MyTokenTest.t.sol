// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "contracts/MyToken.sol";
import "forge-std/console.sol";

contract MyTokenTest is Test {
    MyToken myToken;
    address internal owner;
    address internal dev;
    address payable[] internal users;

    // Set up the test environment before running tests
    function setUp() public {
        // Deploy the token implementation
        MyToken implementation = new MyToken();
        users = utils.createUsers(2);
        owner = users[0];
        vm.label(owner, "Owner");
        dev = users[1];
        vm.label(dev, "Developer");
        // Emit the owner address for debugging purposes
        emit log_address(owner);
    }

    // Test the basic ERC20 functionality of the MyToken contract
    function testERC20Functionality() public {
        // Impersonate the owner to call mint function
        vm.prank(owner);
        // Mint tokens to address(2) and assert the balance
        myToken.mint(address(2), 1000);
        assertEq(myToken.balanceOf(address(2)), 1000);
    }

}
