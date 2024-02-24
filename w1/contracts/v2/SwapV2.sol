// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ISwapV2} from "../interfaces/ISwapV2.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract SwapV2 is ISwapV2, ERC20 {
    ERC20 _tokenA;
    ERC20 _tokenB;
    uint256 _reserveA;
    uint256 _reserveB;

    constructor(address tokenA, address tokenB) ERC20("LPToken", "LPT") {
        uint256 _size;
        assembly {
            _size := extcodesize(tokenA)
        }
        require(_size > 0, "SimpleSwap: TOKENA_IS_NOT_CONTRACT");
        assembly {
            _size := extcodesize(tokenB)
        }
        require(_size > 0, "SimpleSwap: TOKENB_IS_NOT_CONTRACT");
        require(tokenA != tokenB, "SimpleSwap: TOKENA_TOKENB_IDENTICAL_ADDRESS");
        // "smaller" address is always the tokenA. swap the order will be the same pool
        (address token0, address token1) = tokenA <= tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        _tokenA = ERC20(token0);
        _tokenB = ERC20(token1);
    }

    /* ------------------------------ *
     *          ISimpleSwap           *
     * ------------------------------ */
    /// @notice Swap tokenIn for tokenOut with amountIn
    /// @param tokenIn The address of the token to swap from
    /// @param tokenOut The address of the token to swap to
    /// @param amountIn The amount of tokenIn to swap
    /// @return amountOut The amount of tokenOut received
    function swap(address tokenIn, address tokenOut, uint256 amountIn) external returns (uint256 amountOut) {
        // gas saving
        ERC20 tokenA = _tokenA;
        ERC20 tokenB = _tokenB;
        uint256 reserveA = _reserveA;
        uint256 reserveB = _reserveB;

        require(tokenIn != tokenOut, "SimpleSwap: IDENTICAL_ADDRESS");
        require(tokenIn == address(tokenA) || tokenIn == address(tokenB), "SimpleSwap: INVALID_TOKEN_IN");
        require(tokenOut == address(tokenA) || tokenOut == address(tokenB), "SimpleSwap: INVALID_TOKEN_OUT");
        require(amountIn > 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");

        uint256 oldK = reserveA * reserveB;
        uint256 denominator;
        // compute amountOut and update reserve
        if (tokenIn == address(tokenA)) {
            denominator = (reserveA + amountIn);
            // user swap tokenA for tokenB
            // since the resolution is not enough and we need to keep the newK >= oldK.
            amountOut = reserveB - ((oldK - 1) / denominator + 1);
            // update reserve
            updateReserves(reserveA + amountIn, reserveB - amountOut);
        } else {
            // tokenIn == address(tokenB)
            denominator = (reserveB + amountIn);
            // user swap tokenB for tokenA
            // since the resolution is not enough and we need to keep the newK >= oldK.
            amountOut = reserveA - ((oldK - 1) / denominator + 1);
            // update reserve
            updateReserves(reserveA - amountOut, reserveB + amountIn);
        }

        // transfer from msg.sender tokenIn to pool
        ERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        // transfer tokenOut from pool to msg.sender
        ERC20(tokenOut).transfer(msg.sender, amountOut);

        // event Swap( address indexed sender, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);
        emit Swap(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
    }

    /// @notice Add liquidity to the pool
    /// @param amountAIn The amount of tokenA to add
    /// @param amountBIn The amount of tokenB to add
    /// @return amountA The actually amount of tokenA added
    /// @return amountB The actually amount of tokenB added
    /// @return liquidity The amount of liquidity minted
    function addLiquidity(uint256 amountAIn, uint256 amountBIn)
        external
        returns (uint256 amountA, uint256 amountB, uint256 liquidity)
    {
        require(amountAIn != 0 && amountBIn != 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");
        // gas saving
        uint256 reserveA = _reserveA;
        uint256 reserveB = _reserveB;
        // compute amountA and amountB
        if (reserveA == 0 && reserveB == 0) {
            // first one to add liquidity
            amountA = amountAIn;
            amountB = amountBIn;
        } else {
            // add liquidity according to portion of reserves
            amountB = (amountAIn * reserveB) / reserveA;
            amountA = amountAIn;
            if (amountB > amountBIn) {
                // not enough amountB input
                amountA = (amountBIn * reserveA) / reserveB;
                amountB = amountBIn;
            }
        }
        // set liquidity
        liquidity = Math.sqrt(amountA * amountB);

        // transfer tokenA and tokenB from msg.sender
        _tokenA.transferFrom(msg.sender, address(this), amountA);
        _tokenB.transferFrom(msg.sender, address(this), amountB);
        // mint LP tokens to msg.sender
        _mint(msg.sender, liquidity);

        // update reserves
        updateReserves(reserveA + amountA, reserveB + amountB);

        // Event AddLiquidity(address indexed sender, uint256 amountA, uint256 amountB, uint256 liquidity);
        emit AddLiquidity(msg.sender, amountA, amountB, liquidity);
    }

    /// @notice Remove liquidity from the pool
    /// @param liquidity The amount of liquidity to remove
    /// @return amountA The amount of tokenA received
    /// @return amountB The amount of tokenB received
    function removeLiquidity(uint256 liquidity) external returns (uint256 amountA, uint256 amountB) {
        require(liquidity > 0, "SimpleSwap: INSUFFICIENT_LIQUIDITY_BURNED");
        // gas saving
        uint256 reserveA = _reserveA;
        uint256 reserveB = _reserveB;
        // compute amountA and amountB by portion of liquidity and totalSupply of LP token
        amountA = (reserveA * liquidity) / totalSupply();
        amountB = (reserveB * liquidity) / totalSupply();

        // must use this.transferFrom, since in the transferFrom will set spender = msgSender()
        // 1. use this.transferFrom, the msgSender() will be this contract
        // 2. use transferFrom, the msgSender() will be the msg.sender call this function
        this.transferFrom(msg.sender, address(this), liquidity);
        // burn LP token
        _burn(address(this), liquidity);
        // transfer tokenA and tokenB to msg.sender
        _tokenA.transfer(msg.sender, amountA);
        _tokenB.transfer(msg.sender, amountB);

        // update reserves
        updateReserves(reserveA - amountA, reserveB - amountB);

        // event RemoveLiquidity(address indexed sender, uint256 amountA, uint256 amountB, uint256 liquidity);
        emit RemoveLiquidity(msg.sender, amountA, amountB, liquidity);
    }

    /// @notice Get the reserves of the pool
    /// @return reserveA The reserve of tokenA
    /// @return reserveB The reserve of tokenB
    function getReserves() external view returns (uint256, uint256) {
        return (_reserveA, _reserveB);
    }

    /// @notice Get the address of tokenA
    /// @return tokenA The address of tokenA
    function getTokenA() external view returns (address) {
        return address(_tokenA);
    }

    /// @notice Get the address of tokenB
    /// @return tokenB The address of tokenB
    function getTokenB() external view returns (address) {
        return address(_tokenB);
    }

    /* ------------------------------ *
     *       private function         *
     * ------------------------------ */
    function updateReserves(uint256 amountA, uint256 amountB) private {
        _reserveA = amountA;
        _reserveB = amountB;
    }
}
