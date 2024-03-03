// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract UncheckedMath {
    function addChecked(uint8 x, uint8 y) external pure returns (uint8) {
        // 22291 gas
        return x + y;
    }

    function add(uint8 x, uint8 y) external pure returns (uint8) {
        // 22291 gas
        // return x + y;

        // 22103 gas
        unchecked {
            return x + y;
        }
    }

    function sub(uint8 x, uint8 y) external pure returns (uint8) {
        // 22329 gas
        // return x - y;

        // 22147 gas
        unchecked {
            return x - y;
        }
    }

    function sumOfCubes(uint8 x, uint8 y) external pure returns (uint8) {
        // Wrap complex math logic inside unchecked
        unchecked {
            uint8 x3 = x * x * x;
            uint8 y3 = y * y * y;

            return x3 + y3;
        }
    }
}
