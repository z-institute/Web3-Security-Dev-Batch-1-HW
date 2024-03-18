## Group 2 Home Work

### Wintermute 攻擊事件背景

- Optimism 基金會為了支援 Wintermute 的流動性，分別發送兩筆交易，並在 Wintermute 確認後才發送下一筆。Optimism 表示，但隨後 Wintermute 發現他們無法取得這些代幣，因為他們提供的地址是以太坊的多簽地址 (底層鏈)，而他們還沒有將其部署到 Optimism (L2)。
- 因此，Wintermute 啟動了一項還原操作，試圖將以太坊的多簽地址合約部署至 Optimism 上的相同地址。接著不幸的事情發生了。Optimism 表示，攻擊者找到機會部署該多簽合約到 L2，並用不同的起始參數，取得兩千萬的 OP 代幣的擁有權。該地址已經賣掉一百萬個 OP 代幣。
- Optimism 認為，如果現在進行網路升級，將可以停止尚未被賣出的 OP 代幣的轉移，但他們不會做到這一步。因為 Optimism 是個無須許可的網路，不應受到干涉。

### BlockSec 反駁 Librehash 內部員工洩露的猜測

- Wintermute 項目可能在知道後，進一步採取行動撤銷管理員權限，並迴避權限攻擊，更拿出 Etherscan 交易細節，鏈上數據顯示， Wintermute 在意識到駭客攻擊後已經刪除了管理員權限。
- 因為駭客可以透過一直監控 Wintermute 的交易活動來實現，這在技術上並非不合理，例如鏈上的 MEV 機器人，它們持續監控交易來獲取利潤。

### Wintermute 漏洞根本原因

- Profanity 生成地址的方式並不安全，可以透過 GPU 在 50 天內暴力計算出錢包私鑰 (該地址開頭有七個零)，導致私鑰外流

### Wintermute 漏洞預防

- 地址生成的方式很多，可以使用 MetaMask、Exodus 等專業的錢包生成

### 參考

- BlockSec 反駁 Librehash https://www.blocktempo.com/cyber-sleuth-alleges-160m-wintermute-hack-could-be-inside-job/

### Front-run

- 公共確定了記憶體池中的目標交易，並且機器人試圖透過提交略高的 gas 價格在交易前立即被挖掘。

### MEV (礦工可提取價值) bot

- 礦工可提取價值(MEV)是指礦工可以透過在他們生產的區塊中包含、重新排序、插入或忽略交易來獲得的額外利潤。雖然贏得區塊的過程相當民主，但獲勝的區塊生產者對可以包含在區塊中的交易有很大的控制權。
- 以太坊交易被包含在一個區塊中之前，它會先進入公共記憶體池，這是一個可公開存取的暫存區。這也是 MEV 機器人搜尋可用於捕獲某些 MEV 的交易的地方，例如透過套利市場或清算新的抵押不足的貸款。對於優先考慮的策略，以越來越高的 gas 價格相互競標，以在所謂的優先 gas 拍賣(PGA) 中捕獲 MEV。
- 假設有一個大的 Uniswap 訂單在記憶體池中購買 SNX / WETH。MEV 機器人將立即在 Uniswap 大訂單後面進行交易，以利用 Uniswap 池中的價格滑點與另一個 AMM 池（如 SushiSwap）中的 SNX/WETH 價格進行套利。這被認為是良性或積極的 MEV，因為它有益於生態系統。
- 礦工作為鏈上內容的最終守門人，甚至相對於 MEV 機器人也有一張王牌。擁有「廣義搶跑」機器人的礦工可以複製 MEV 機器人的套利交易並將其替換為自己的，從而為自己攫取套利的利潤。廣義搶跑交易被視為惡性 MEV 交易，或破壞生態系統穩定的交易。

- MEV 策略可分為 front-running, back-running, sandwiching, uncle bandit

### 攻擊向量

- Time bandit (時間)
  1.front-running (搶在某筆大額 UniSwap 之前)
  2.back-running (價格預言機更新之後，提交清算訂單)
  3.sandwiching (front-run 及 back-run 組合)
- Uncle bandit (空間)
  透過 叔塊 中的交易用於捕獲 MEV

- 參考 https://zhuanlan.zhihu.com/p/380722461
