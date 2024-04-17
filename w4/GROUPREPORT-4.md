## Other attacker vector


### Insufficient Gas Griefing 氣體不足

可以對接受資料並在另一個合約的子呼叫中使用資料的合約執行不足的gas惡意攻擊。如果子呼叫失敗，則要么恢復整個事務，要么繼續執行。

在中繼合約的情況下，執行交易的使用者（「轉發者」）可以透過使用足夠的 Gas 來有效地審查交易來執行交易，但不足以使子呼叫成功。

### 補救措施：

有兩種方法可以防止 Gas 不足：
- 只允許受信任的用戶中繼交易。

- 要求貨代提供足夠的gas。

References: 參考：
https://swcregistry.io/docs/SWC-126