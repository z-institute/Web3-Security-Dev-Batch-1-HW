## Group 2 Home Work

### MetaPoint 攻擊事件背景

- MetaPoint 是一個 BSC 鏈上的元宇宙平台，使用者可以在虛擬環境中參與各種活動，例如社交、玩遊戲、參與活動和從事商業活動。該平台擁有獨特的交易策略和更新的自動做市商（AMM）機制，讓玩家沉浸在虛擬世界中，同時與其分散的生態系統互動。
- 最近的駭客攻擊涉及對 MetaPoint 平台上的 POT 智能合約的利用。當用戶存入資產時，平台會自動建立一個新的合約來發送資金。駭客利用了這個過程，將存款轉移到他們自己的智能合約而不是主合約。
- 當用戶使用存款功能時，交易會創建一個新合約並將代幣存入該合約。問題是，該合約有一個名為「approve」的函數，該函數為該函數的呼叫者提供了存取權限。
- 2023 年 4 月 12 日，被攻擊，該專案損失超過 92 萬美元。

### 攻擊合約

- 攻擊交易 https://bscscan.com/address/0x0d1969a30bb4ba02e731862edbced5f5abba8373
- 攻擊合約 https://bscscan.com/address/0xc6e451c8fa3418b703121ac23e44803d143c5d5c
- 攻擊合約內交易 https://bscscan.com/tx/0xe18c4e6fb08b2618a7ae88b51c3741f8696ac5479d80310ed9bc68d852b11c13
- 攻擊函數 0x319b79c5, 0x3cc17c29

### MetaPoint 漏洞根本原因

- 用戶使用存款功能時，交易會創建一個新合約並將代幣存入該合約(Upgradeable 0x71a0c153F52cEfCf6d26253f67B10DaBEd5556Ff)，而該合約任何人均可外部呼叫其 approve，取得授權後，再 transfer 內部所有的 POT token，而透過 DEX 轉成 USD, WBNB 取走

```
  IApprove(address(depositContract)).approve();

  uint256 amount = IERC20(address(pot)).balanceOf(address(depositContract));
  IERC20(address(pot)).transferFrom(address(depositContract), address(this), amount);
  bscSwap(pot, usdt, IERC20(pot).balanceOf(address(this)));
  bscSwap(usdt, wbnb, IERC20(usdt).balanceOf(address(this)));

  // fn bscSwap => pancakeSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens
```

### MetaPoint 漏洞預防

- 簡單來說，新生成合約就是沒有對 approve 等功能設置存取控制，無論是單純用 Ownable library，或是 role-based 授權
- 很明顯的，這是個蠻初階的漏洞，也表示該合約有很大的可能性，沒有經過專業的 Audit 公司審計
- 在查找 Etherscan 交易的過程中，發現平台對於生成的合約並沒有開源，故很有可能是 Hacker 透過漏洞工具去交互，甚至有可能是內部科學家們流出，總之，一般白帽在沒有開源的前提下，幾乎不會去和合約交互，去找合約可能的漏洞 (純推論，有誤請指正)

### 參考

- CredShields report: https://blog.solidityscan.com/metapoint-hack-analysis-public-asset-transfer-approval-a0bd611e7557
- DeFiHackLas MetaPoint 攻擊 POC
  https://github.com/SunWeb3Sec/DeFiHackLabs/blob/main/src/test/MetaPoint_exp.sol
- 攻擊交易 https://bscscan.com/txs?a=0x0d1969a30bb4ba02e731862edbced5f5abba8373
- 攻擊合約內交易 https://bscscan.com/tx/0x04c2c81dbd17a17b5eb50ec72678071328a61afe2cf07350cbca9a14a978fba6
- 平台生成合約 https://bscscan.com/address/0x71a0c153f52cefcf6d26253f67b10dabed5556ff#code
- 任一筆生成後的新合約 https://bscscan.com/address/0x724DbEA8A0ec7070de448ef4AF3b95210BDC8DF6#internaltx
