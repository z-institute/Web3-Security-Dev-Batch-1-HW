# Web3-Security-Dev-Batch-1-HW

1. 完成 mint(address to, uint256 amount) function
   --> src/SammiToken.sol
2. 完成對應的測試
   --> https://app.warp.dev/block/gmyeJQyXNez0zRpfpa6sRx
3. 完成測試後，利用 Foundry 將合約部署至 sepolia testnet
   --> https://sepolia.etherscan.io/address/0x0e337c05460f8a5043e0aef8a4e3c9447235d88e
4. 成功部署後，驗證鏈上的合約
   --> /print_result/cast_interaction
5. 將前面的測試情境，用 Foundry 發出對應的交易到剛剛部署在測試鏈上的合約
   --> /print_result/cast_interaction
6. 熟悉 cast CLI 工具
   | src/SammiToken.sol:SammiToken contract | | | | | |
   |----------------------------------------|-----------------|-------|--------|-------|---------|
   | Deployment Cost | Deployment Size | | | | |
   | 572415 | 3024 | | | | |
   | Function Name | min | avg | median | max | # calls |
   | allowance | 836 | 836 | 836 | 836 | 1 |
   | approve | 24739 | 24739 | 24739 | 24739 | 1 |
   | balanceOf | 562 | 562 | 562 | 562 | 14 |
   | decimals | 266 | 266 | 266 | 266 | 1 |
   | deployer | 425 | 425 | 425 | 425 | 2 |
   | mint | 26210 | 39336 | 39263 | 52610 | 4 |
   | transfer | 3288 | 3288 | 3288 | 3288 | 3 |
   | transferFrom | 4162 | 4162 | 4162 | 4162 | 2 |
