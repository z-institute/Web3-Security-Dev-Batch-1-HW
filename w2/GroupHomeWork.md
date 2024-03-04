## Group 2 Home Work

### Why the state variable \_totalSupply is set to private?

- \_totalSupply 設為內部變數，只能在合約內部調用，以避免讓外部程序直接調用，必須得用 totalSupply() 這個 getter 才能觀看，其所得到的 \_totalSupply，必須得等到 totalSupply() 這個函數執行完後回傳
- \_totalSupply 的值必須由 totalSupply() 來觀看，減少 Hacker 可能藉由在執行其它含有 \_totalSupply 的操作函數，像 \_mint, \_burn 的執行過程，對於 \_totalSupply 的監控，達成其入侵的目的
- 而且合約調用 totalSupply() 需花費 gas fee，而一般 EOA 調用不用 gas，如果是合約調用 public \_totalSupply 變數，則是不用 gas fee，如此一來，使用 totalSupply() 會增加駭客的攻擊成本
- 在合約攻擊事件中，快速取得變數值，對於攻擊合約程式邏輯而言，無須再從 function 再跳到另一個 function 去執行，等到完成後，再回到呼叫的 function 內，除了減少程式的大小外，更快取得變數值，完成程式邏輯，並減少可能的風險

### Why the state variable \_balances is set to private?

- \_balances 設為內部變數，只能在合約內部調用，以避免讓外部程序直接調用，必須得用 balanceOf(address) 這個 getter 才能觀看，其所得到的 \_balances，必須得等到 balanceOf(address) 這個函數執行完後回傳
- \_balances 的值必須由 balanceOf(address) 來觀看，減少 Hacker 可能藉由在執行其它含有 \_balance 的操作函數，像 \_mint, \_burn, \_transfer 的執行過程，對於 \_balances 的監控，達成其入侵的目的

### What is difference between \_msgSender() and msg.sender?

- 一般情況而言，這兩者沒有差異，但在 GSN (Gas Station Network)下，\_msgSender()的值就有不同，以下是 GSN 下的 \_msgSender() 的函數定義，也就是說 msg.sender 是合約的 payable receiver，要幫使用者付 Gas fee，必須要使用 \_msgSender() 才能達成

### Why use it here?

- 合約調用 transfer 函數時，因使用 \_msgSender()，確保其為合約最終端的 owner，而非當下調用合約的 msg.sender，以避免攻擊合約

### Why the state variable \_allowances is set to private?

- \_allowances 設為內部變數，只能在合約內部調用，以避免讓外部程序直接調用，必須得用 allowances() 這個 getter 才能觀看，其所得到的 \_allowances，必須得等到 allowances() 這個函數執行完後回傳
- \_allowances 的值必須由 allowances() 來觀看，減少 Hacker 可能藉由在執行其它含有 \_allowances 的操作函數，像 \_approve 的執行過程，對於 \_allowances 的監控，達成其入侵的目的
- \_allowances 關乎到授權 spencer 可以動用 token 的數量，一般 phishing 會引誘玩家 approve，使攻擊者可以動用玩家的 token，這時 \_allowances 的監控就很至關重要

### What is the potential risk of directly overwriting the old value of \_allowance? (Write a PoC to validate it)

- 直接覆寫 \_allowance，會造成 front-run 攻擊，在預期 \_allowance 調整前，先 transferFrom token，讓 \_allowance 減少，甚至歸零，之後覆寫 \_allowance，會得到新的 \_allowance 數量

```
  DaoToken daoToken;
  address public owner = address(0);
  address public alice = address(1);
  address public bob = address(2);
  address public carol = address(3);

  function setUp() public {
    vm.startPrank(owner);
    daoToken = new DaoToken();
    vm.stopPrank();
  }

  function testOverwriteAllowance() public {
    vm.prank(alice);
    daoToken.approve(bob, 1000);

    vm.prank(bob);
    daoToken.transferFrom(alice, carol, 1000);

    vm.prank(alice);
    daoToken.approve(bob, 100);

    console.log(daoToken.allowance(alice, bob)); // 100
    console.log(daoToken.balanceOf(carol)); // 1000
    // 實際上 bob 獲得 allowance 是 1100 token
  }
```

### What is an unchecked block?

- Solidity 0.8 版之前，針對 uint 的算術運算，都必須引用 OpenZeppelin 的 SafeMath，以避免 underflow 及 overflow
- Solidity 0.8 版之後，改進了 uint 的算術運算，所有運算必須符合 SafeMath 的機制，但也造成了 gas usage 的增加
- 在很多應用場景，其實是不會發生 underflow 及 overflow 的，所以設置了 unchecked block，免除了 SafeMath 的檢查，也省下了 gas usage

### Why use it here? (Write a Poc to validate it )

- 下段程式 unchecked 區塊，因為 fromBalance 是某個地址的 token 餘額，value 是扣除的值，在前一段 if (fromBalance < value) 已經完成可能造成 fromBalance - value 會 underflow 的判斷，所以就設置 unchecked，省下 gas usage

```
  function _update(address from, address to, uint256 value) internal virtual {
    if (from == address(0)) {
      _totalSupply += value;
    } else {
      uint256 fromBalance = _balances[from];
      if (fromBalance < value) {
        revert ERC20InsufficientBalance(from, fromBalance, value);
      }
      unchecked {
        // Overflow not possible: value <= fromBalance <= totalSupply.
        _balances[from] = fromBalance - value;
      }
    }
    ...
  }
```

### Zero address is invalid in ERC721, but not in ERC20 and ERC1155. Why?

- address(0) 對於 ERC20 及 ERC1155 而言，就是拿來做為特定用途，如 mint 及 burn 的發送人或接收人，mint 是從 address(0) 轉帳到接收人，burn 則是從發送人到 address(0)，如果直接引用 transfer(address(0), amount) 是會出現 ERC20InvalidReceiver revert，而 balanceOf(address(0)) 會出現 0
- 對於 ERC721 而言，每個 NFT token 是唯一並且隸屬於某一地址，而 address(0) 是 mint 的發送人及 burn 的接收人，性質等同回收，並非代能夠代表 NFT Owner 概念的地址，一旦 balanceOf(address(0)) 會出現 ERC721InvalidOwner revert

### The code size of an address greater than zero bytes is a contract. Does it mean the code size of an address equal zero bytes is a EOA? (Write a PoC to validate it)

```
  DaoToken daoToken;
  address public owner = address(0);
  address public hacker = address(1337);

  function setUp() public {
    vm.startPrank(owner);
    daoToken = new DaoToken();
    vm.stopPrank();
  }

  function testContractCodeLength() public {
    address contract_addr = address(daoToken);
    console.log(contract_addr.code.length); // Contract code length: 3532
    console.log(hacker.code.length);  // EOA code length: 0
  }
```

### What does the assembly block actually do?

- 直接對 EVM 做低階操作，像 memory/storage 存取 (mload, mstore, sload, sstore)、數字運算 (add, sub, mul...)、其它 EVM 底層操作...
- 低階操作可選用 gas usage 低的 opcode，進而優化整體合約的 gas usage
