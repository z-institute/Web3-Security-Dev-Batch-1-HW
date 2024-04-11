// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {AmazingToken} from "src/AmazingToken.sol";
import {LenderPool} from "src/LenderPool.sol";

contract LenderTest is Test {

    // Pool has 1000000 ETH in balance
    uint TOKENS_IN_POOL = 1000000 ether;

    AmazingToken token;
    LenderPool pool;

    address payable attacker =  payable(address(0x456));

    function setUp() public  {
        // setup contracts
        token = new AmazingToken();
        pool = new LenderPool(address(token));


        token.transfer(address(pool), TOKENS_IN_POOL);

        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);
        assertEq(token.balanceOf(attacker), 0);
    }
     function testExploit() public {
        /** CODE YOUR EXPLOIT HERE */

         /** SUCCESS CONDITIONS */
        // Attacker has taken all tokens from the pool
        assertEq(token.balanceOf(attacker), TOKENS_IN_POOL);
        assertEq(token.balanceOf(address(pool)), 0);
    }

}
