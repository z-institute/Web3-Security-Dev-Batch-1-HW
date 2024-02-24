//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.20;

library Errors {
    error Exchange_Invalid_Reserves();
    error Exchange_Insufficient_Token_Amount();
    error Exchange_Insufficient_Eth_Amount();
    error Exchange_Insufficient_Output_Amount();
}
