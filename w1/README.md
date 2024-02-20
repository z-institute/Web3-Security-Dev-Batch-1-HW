# Week1 for Web3-Security-Dev-Batch-1-HW

### 完成 mint(address to, uint256 amount) function
- src/Token.sol

### 完成對應的測試
- test/Token.t.sol
- 印出每個 function 使用多少 gas
  | src/Token.sol:Token contract |                 |       |        |       |         |
  |------------------------------|-----------------|-------|--------|-------|---------|
  | Deployment Cost              | Deployment Size |       |        |       |         |
  | 500301                       | 3320            |       |        |       |         |
  | Function Name                | min             | avg   | median | max   | # calls |
  | allowance                    | 814             | 814   | 814    | 814   | 4       |
  | approve                      | 24739           | 24739 | 24739  | 24739 | 1       |
  | balanceOf                    | 562             | 562   | 562    | 562   | 15      |
  | mint                         | 25167           | 26767 | 25167  | 29967 | 3       |
  | transfer                     | 3288            | 3288  | 3288   | 3288  | 3       |
  | transferFrom                 | 4162            | 4162  | 4162   | 4162  | 1       |
- 印出每個 test function 使用多少 gas ==> Read more [here](./test_function_gas.txt)
- expectRevert 之後的 token.transferFrom(user1, user2, token.balanceOf(user1)); 引發的 ERC20InsufficientAllowance 錯誤，forge 仍是沒 catch 到，拋出「call did not revert as expected」的提示

### 完成對應的測試