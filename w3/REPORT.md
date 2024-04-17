### 目标： vm.expectRevert(stdError.assertionError); // 期望失败
### assert(poolBalance == balanceBefore); // 期望失败

`LenderPool.sol` depositTokens 是存入池子代幣。
`LenderPool.sol` flashLoan 是閃電貸。
----------------
說明 `flashLoan`

1. require(borrowAmount > 0, "Must borrow at least one token");
    確保借款數量必須大於 0。

2. uint256 balanceBefore = amazingToken.balanceOf(address(this));
   獲取了合約當前的代幣餘額。address(this) 是目前的池子。

3. require(balanceBefore >= borrowAmount, "Not enough tokens in pool");
    確保池子有足夠的代幣來提供閃電貸款。

4. assert(poolBalance == balanceBefore);
    確保 poolBalance（內部追蹤的代幣餘額）和實際的代幣餘額相同。`我們重點要攻破這裡`

5. amazingToken.transfer(msg.sender, borrowAmount);
    將借款數量的代幣從合約轉移到借款者（msg.sender）ex: someUser

6. IReceiver(msg.sender).receiveTokens(address(amazingToken), borrowAmount);
    調用借款者的 receiveTokens 函數，將代幣和數量作為參數。這通常用於通知借款者他們已經收到了代幣。

7. uint256 balanceAfter = amazingToken.balanceOf(address(this));：
    這行再次獲取了池子的代幣餘額。

8. require(balanceAfter >= balanceBefore, "Flash loan hasn't been paid back");
   這行確保了閃電貸款已經被還款。如果借款者沒有在 receiveTokens 函數中將代幣全數還回，則這行會拋出錯誤。

ps. 引用 chartGPT 的說明.. 加上自己修改的部分。

能注意到：
LenderPool：18 & 25-30 行
```
    uint256 public poolBalance;

    function depositTokens(uint256 amount) external nonReentrant {
        require(amount > 0, "Must deposit at least one token");
        // Transfer token from sender. Sender must have first approved them.
        amazingToken.transferFrom(msg.sender, address(this), amount);
        poolBalance = poolBalance + amount;
    }
```
會發現 `depositTokens` 會將代幣存入池子，並且更新 `poolBalance`，而 `poolBalance` 是合約裡面的全域變數。

就可以猜想到一開始代幣注入到池子裡使用`depositTokens` 正常沒有在呼叫 `depositTokens` 的狀況下，`poolBalance` 就會固定不變。

assert(poolBalance == balanceBefore); 那只要讓他不等於就好了。

uint256 balanceBefore = amazingToken.balanceOf(address(this)); 
這行就是獲取目前池子的代幣餘額。

#### 執行攻擊....

hack 擁有項目代幣直接交易.....任意數字... 這樣就可以讓 `poolBalance` 不等於 `balanceBefore`。
