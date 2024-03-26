# Web3-Security-Dev-Batch-1-HW
## Homework 5

### Summary
這是一個台灣的項目合約，裡有不良的程式碼導致
### Vulnerability Detail
### Impact
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
  ，主要影響會導致使用者 mint 一個 token 時，會隨著越後面的人所使用的 gas fee 越高，因為每次 mint token 都會檢查是否在白名單中，而白名單中的地址會越來越多，導致 gas fee 越來越高。
### PoC

### Recommended Mitigation Steps



Use tools 4naly3er