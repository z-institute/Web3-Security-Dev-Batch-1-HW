//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.20;

interface IFactory {
    function getExchange(address _tokenAddress) external returns (address);
}
