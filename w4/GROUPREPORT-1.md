## Wintermute (2022.06)
Wintermute 是做市商
PS:造市者、或稱為造市商、做市商(英文：Market maker)，是指在市場中提供流動性的人，
大多是在衍生性商品的交易上有比較多。

### 起因
Optimism 團隊在向 Wintermute 發送 2000 萬個 OP 代幣時，送到錯誤地址，導致後續被盜

### 流程

- 5 月 27 日，Optimism 團隊在向 Wintermute 發送 2000 萬個 OP 代幣時，錯誤地將資產發送到第 2 層（Optimism）的 0x4f3a120E72C76c22ae802D129F599BFDbc31cb81 地址。

- Wintermute 提供的預期接收地址應該是第 1 層（以太坊）上的 0x4f3a120E72C76c22ae802D129F599BFDbc31cb81。而這個地址是 Gonsis 代理的多重簽名合約地址。


- 在 6 月 5 日部署了一個 Gnosis Safe: Proxy Factory 1.1.1 合約後，來自 Optimism 上的攻擊者 0x60B28637879B5a09D21B68040020FFbf7dbA5107 立即呼叫了 「createProxy」 在 Optimism 上的 0x4f3a120E72C76c22ae802D129F599BFDbc31cb81 部署了一個 Proxy 合約，並提取了全部 2000 萬個 OP 代幣。

- 攻擊者在 Optimism 團隊和 Wintermute 團隊之前成功完成了所有這些操作。

### 詳細

Optimism 團隊接下來要做的預期步驟是撤回發送到第 2 層（Optimism）上的 0x4f3a120E72C76c22ae802D129F599BFDbc31cb81 的代幣。

對此，已有成熟可行的解決方案。訣竅是呼叫「create2」在 Optimism 上的 0x4f3a120E72C76c22ae802D129F599BFDbc31cb81 部署相同的多重簽章合約。

當呼叫「create2」時，我們可以透過輸入專門設計的 salt 和 init_code 值來操作產生的合約位址。這樣我們就可以在Optimism上產生一個和以太坊上一模一樣的合約地址。

Basically, we can do it in two steps:
基本上，我們可以分兩步驟完成：


- 步驟1，使用相同的部署者位址和相同的隨機數在Optimism上部署Gnosis Safe: Proxy Factory 1.1.1合約，

- 第 2 步，使用與以太坊上相同的隨機數（作為鹽值）和相同的 init_code 調用“createProxy”，以在 Optimism 上與以太坊上相同的地址部署代理合約。

#### 參考
----
https://twitter.com/Optimism/status/1534631766576836608?ref_src=twsrc%5Etfw%7Ctwcamp%5Etweetembed%7Ctwterm%5E1534631766576836608%7Ctwgr%5Ee2512987c7a454215d57cd341ff9709331d97acc%7Ctwcon%5Es1_&ref_url=https%3A%2F%2Fwww.coindesk.com%2Ftech%2F2022%2F06%2F09%2F15m-of-optimism-tokens-stolen-by-an-attacker-after-wintermute-sent-wrong-wallet-address%2F


https://medium.com/@FairyproofT/analysis-solution-to-the-attack-on-optimism-by-fairyproof-95b09443dbf7