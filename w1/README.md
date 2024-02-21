# Web3-Security-Dev-Batch-1-HW

# h1Web3 security - week1 - hk

### 試著用 Foundry 部署一個標準的 ERC-20 到 Sepolia

1. 用 fountry 框架初始化專案
    ```shell
    forge init [dir_name]
    ```
    當要實作/引入其他 source，可以用 forge install 的 command
    hardhat import 是用＠，foundry 則沒有@
    ```shell
    forge install OpenZeppelin/openzeppelin-contracts
    ```
    編譯，可以先確認語法內容
    ```shell
    forge build
    ```
    https://github.com/sammijiangtw/SammiToken
2. run 測試內容，確認邏輯
    ```shell
    # 測試並打印
    forge test -vvvv
    ```
3. 部署到 Sepolia testnet
   etherscan-api-key 如果沒定義，會報錯沒辦法上鍊
   $SEPOLIA_RPC_URL 和 $ETHERSCAN_API_KEY 都在專案的 .env 文檔裡定義

    ```shell
    # 先loading環境
    source .env

    # 以script部署
    forge script [script_name] --rpc-url $SEPOLIA_RPC_URL --etherscan-api-key $ETHERSCAN_API_KEY --broadcast --verify -vvvvv
    ```

4. 部署的合約互動
   cast send:是用於需要交易的 command

    ```shell=
    # private key 的方式
     cast send <DEPLOYED_ADDRESS> --rpc-url=$SEPOLIA_RPC_URL <function> [function_ARGS] <YOUR_ADDRESS_HERE>  --private-key <private key>

     cast send <DEPLOYED_ADDRESS> --rpc-url=$SEPOLIA_RPC_URL "mint(address,uint256)" 0x 1 --private-key 0x

     # keystore
     cast send <DEPLOYED_ADDRESS> --rpc-url=$ <function> [function_ARGS] --keystore /Users/xinminjiang/.foundry/keystore/<file_name>
    ```

    cast call:不需要交易的話，例如讀取就可以用此 command

    ```shell=
    cast call <DEPLOYED_ADDRESS> <function> [function_ARGS] --rpc-url $SEPOLIA_RPC_URL

    cast call 0x "balanceOf(address)" 0x --rpc-url $SEPOLIA_RPC_URL
    ```

    ```shell=
    # 返回不是10進位的數字可以用cast轉
    cast to-dec <value>
    ```

### reference

https://learnblockchain.cn/docs/foundry/i18n/zh/reference/cast/cast-send.html
