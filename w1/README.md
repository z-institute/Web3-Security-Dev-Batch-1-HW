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
  [560726] TokenTest::setUp()
    ├─ [500301] → new Token@0xF2E246BB76DF876Cef8b38ae84130F4F55De395b
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf, value: 100000000000000000000 [1e20])
    │   └─ ← 3320 bytes of code
    └─ ← ()

  [181848] TokenTest::test_TransferAcrossMultipleAccounts()
    ├─ [29967] Token::mint(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 10000000000000000000 [1e19])
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 10000000000000000000 [1e19])
    │   └─ ← ()
    ├─ [562] Token::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 10000000000000000000 [1e19]
    ├─ [25167] Token::mint(0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69, 9000000000000000000 [9e18])
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69, value: 9000000000000000000 [9e18])
    │   └─ ← ()
    ├─ [562] Token::balanceOf(0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69) [staticcall]
    │   └─ ← 9000000000000000000 [9e18]
    ├─ [25167] Token::mint(0x1efF47bc3a10a45D4B230B5d10E37751FE6AA718, 8000000000000000000 [8e18])
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x1efF47bc3a10a45D4B230B5d10E37751FE6AA718, value: 8000000000000000000 [8e18])
    │   └─ ← ()
    ├─ [562] Token::balanceOf(0x1efF47bc3a10a45D4B230B5d10E37751FE6AA718) [staticcall]
    │   └─ ← 8000000000000000000 [8e18]
    ├─ [3288] Token::transfer(0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69, 5000000000000000000 [5e18])
    │   ├─ emit Transfer(from: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, to: 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69, value: 5000000000000000000 [5e18])
    │   └─ ← true
    ├─ [562] Token::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 5000000000000000000 [5e18]
    ├─ [562] Token::balanceOf(0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69) [staticcall]
    │   └─ ← 14000000000000000000 [1.4e19]
    ├─ [3288] Token::transfer(0x1efF47bc3a10a45D4B230B5d10E37751FE6AA718, 4000000000000000000 [4e18])
    │   ├─ emit Transfer(from: 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69, to: 0x1efF47bc3a10a45D4B230B5d10E37751FE6AA718, value: 4000000000000000000 [4e18])
    │   └─ ← true
    ├─ [562] Token::balanceOf(0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69) [staticcall]
    │   └─ ← 10000000000000000000 [1e19]
    ├─ [562] Token::balanceOf(0x1efF47bc3a10a45D4B230B5d10E37751FE6AA718) [staticcall]
    │   └─ ← 12000000000000000000 [1.2e19]
    ├─ [3288] Token::transfer(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 3000000000000000000 [3e18])
    │   ├─ emit Transfer(from: 0x1efF47bc3a10a45D4B230B5d10E37751FE6AA718, to: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 3000000000000000000 [3e18])
    │   └─ ← true
    ├─ [562] Token::balanceOf(0x1efF47bc3a10a45D4B230B5d10E37751FE6AA718) [staticcall]
    │   └─ ← 9000000000000000000 [9e18]
    ├─ [562] Token::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 8000000000000000000 [8e18]
    ├─ [24739] Token::approve(0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69, 3000000000000000000 [3e18])
    │   ├─ emit Approval(owner: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, spender: 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69, value: 3000000000000000000 [3e18])
    │   └─ ← true
    ├─ [814] Token::allowance(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69) [staticcall]
    │   └─ ← 3000000000000000000 [3e18]
    ├─ [4162] Token::transferFrom(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 0x1efF47bc3a10a45D4B230B5d10E37751FE6AA718, 2000000000000000000 [2e18])
    │   ├─ emit Transfer(from: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, to: 0x1efF47bc3a10a45D4B230B5d10E37751FE6AA718, value: 2000000000000000000 [2e18])
    │   └─ ← true
    ├─ [562] Token::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 6000000000000000000 [6e18]
    ├─ [562] Token::balanceOf(0x1efF47bc3a10a45D4B230B5d10E37751FE6AA718) [staticcall]
    │   └─ ← 11000000000000000000 [1.1e19]
    ├─ [814] Token::allowance(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69) [staticcall]
    │   └─ ← 1000000000000000000 [1e18]
    ├─ [562] Token::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 6000000000000000000 [6e18]
    ├─ [562] Token::balanceOf(0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69) [staticcall]
    │   └─ ← 10000000000000000000 [1e19]
    ├─ [814] Token::allowance(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69) [staticcall]
    │   └─ ← 1000000000000000000 [1e18]
    ├─ [814] Token::allowance(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69) [staticcall]
    │   └─ ← 1000000000000000000 [1e18]
    ├─ [562] Token::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 6000000000000000000 [6e18]
    ├─ [0] VM::expectRevert(ERC20InsufficientAllowance(0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69, 1000000000000000000 [1e18], 6000000000000000000 [6e18]))
    │   └─ ← ()
    ├─ [562] Token::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← 6000000000000000000 [6e18]
    └─ ← call did not revert as expected
- expectRevert 之後的 token.transferFrom(user1, user2, token.balanceOf(user1)); 引發的 ERC20InsufficientAllowance 錯誤，forge 仍是沒 catch 到，拋出「call did not revert as expected」的提示

### 完成對應的測試