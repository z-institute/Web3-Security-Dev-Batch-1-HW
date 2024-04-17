<<<<<<< HEAD
# Homework 5

### Summary
這是一個台灣的項目合約，不良的程式碼習慣導致
### Vulnerability Detail
  `isWhitelisted()` 運用不當
  ```solidity
  function isWhitelisted(address _user) public view returns (bool) {
    for (uint i = 0; i < whitelistedAddresses.length; i++) {
      if (whitelistedAddresses[i] == _user) {
          return true;
      }
    }
    return false;
  }
  ```
### Impact
  主要影響會導致使用者 mint 一個 token 時檢查是否在白名單中，而白名單中的地址會越來越多，代表佔用區塊連資源越多，導致每次查找都使得 gas 越來越高，使用者給不夠的 gas會導致 mint 失敗(交易結束）。

### PoC
1. 有兩個人 Bob 和 Alice ，兩個人都在白名單中，一個在白名單的最前面，一個在白名單的最後面。
2. Bob 使用 mint 消耗較少的 gas
3. Alice 使用 mint 消耗較多的 gas

```
[PASS] testWLMintFirst() (gas: 34657)
[PASS] testWLMintLast() (gas: 2076890)
```

### Recommended Mitigation Steps
1. 使用 mapping 來取代 array

```solidity
//address[] whitelistedAddresses;
mapping(address => bool) public whitelistedAddresses;

```
2.判斷是否在白名單中修改
```solidity
function isWhitelisted(address _user) public view returns (bool) {
    return whitelistedAddresses[_user];
}
// or
if(isWhitelisted[msg.sender] == true)
```

### Reference
 - Use tools 4naly3er The  [Report](./REPORT.md)

  - https://medium.com/@ChiHaoLu/how-to-test-the-smart-contract-of-iparking-nft-with-foundry-bc8bdbe6a359
=======
# Web3-Security-Dev-Batch-1-HW
w7
>>>>>>> main
