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
- 印出每個 test function 使用多少 gas  
  ==> 參考 test_function_gas.txt
- expectRevert 之後的 token.transferFrom(user1, user2, token.balanceOf(user1)); 引發的 ERC20InsufficientAllowance 錯誤，forge 仍是沒 catch 到，拋出「call did not revert as expected」的提示

### 完成測試後，利用 Foundry 將合約部署至 Sepolia testnet
- test/Token.s.sol
```
forge script script/Token.s.sol:TokenScript --rpc-url="https://eth-sepolia.g.alchemy.com/v2/your_alchemy_api_key" --broadcast --verify -vvvv --optimizer-runs 200
```

### 成功部署後，驗證鏈上的合約
- contract creation address: 0xaFfB198193e8681f58DB28DBBaf72be91699Fb73 [link](https://sepolia.etherscan.io/address/0xaFfB198193e8681f58DB28DBBaf72be91699Fb73#code)

### 將前面的測試情境，用 Foundry 發出對應的交易到剛剛部署在測試鏈上的合約
- 8 transactions: 0xaFfB198193e8681f58DB28DBBaf72be91699Fb73 [link](https://sepolia.etherscan.io/address/0xaFfB198193e8681f58DB28DBBaf72be91699Fb73)
- 3 Mints, 2 Transfers, 1 Approve, 1 Transfer From

### 熟悉 cast CLI 工具
- gas usage
  | src/Token.sol:Token contract | Simulation      | Sepolia deploy  |
  |------------------------------|-----------------|-----------------|
  | Contract creation            | 500301          | 604361          | 
  | Token::mint (x3)             | 29967           | 51599           |
  | Token::transfer (x2)         | 12888           | 34520           |
  | Token::approve               | 24739           | 46371           |
  | Token::transferFrom          | 18562           | 40562           |
- 上鏈後的 gas usage 比本地模擬的多，可能的原因如下:  
  1. 本地foundry 框架模擬較為單純，不若主網及測試網複雜，有諸多影響 gas usage 的外部變因  
  2. 本地 EVM 運行的版本和主網及測試網不同，也會影響 gas usage
  3. deploy 合約時所使用的參數，如 --optimizer-runs 200，也會多少影響 gas usage
- 驗證每個角色的 balance 如預期，除了  
  1. user2 將 user1 的 2 個 token 轉移到 user3 身上，並將剩餘的 token 轉移給自己
  2. 因 allowance 不足，會導致 ERC20InsufficientAllowance revert
- 將 user1 的 balance 分別用 Ether、Gwei 為單位表示
  1. cast call 0xaFfB198193e8681f58DB28DBBaf72be91699Fb73 "balanceOf(address)(uint256)" --rpc-url="https://eth-sepolia.g.alchemy.com/v2/your_alchemy_api_key" 0x0278137e8E2C38111297c9991815507eB16eaf25 取得 6000000000000000000
  2. cast to-unit 6000000000000000000 gwei 取得 6000000000
  3. cast to-unit 6000000000000000000 ether 取得 6