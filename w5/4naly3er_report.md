# 4naly3er Report

## Gas Optimizations

|                 | Issue                                                                                               | Instances |
| --------------- | :-------------------------------------------------------------------------------------------------- | :-------: |
| [GAS-1](#GAS-1) | `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings) |     1     |
| [GAS-2](#GAS-2) | Using bools for storage incurs overhead                                                             |     1     |
| [GAS-3](#GAS-3) | For Operations that will not overflow, you could use unchecked                                      |     7     |
| [GAS-4](#GAS-4) | Use Custom Errors instead of Revert Strings to save Gas                                             |     2     |
| [GAS-5](#GAS-5) | Use != 0 instead of > 0 for unsigned integer comparison                                             |     1     |

### <a name="GAS-1"></a>[GAS-1] `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings)

This saves **16 gas per instance.**

_Instances (1)_:

```solidity
File: src/CryptoCurrencyStore.sol

17:         balances[msg.sender] += msg.value; //存款

```

### <a name="GAS-2"></a>[GAS-2] Using bools for storage incurs overhead

Use uint256(1) and uint256(2) for true/false to avoid a Gwarmaccess (100 gas), and to avoid Gsset (20000 gas) when changing from ‘false’ to ‘true’, after having been ‘true’ in the past. See [source](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/58f635312aa21f947cae5f8578638a85aa2519f5/contracts/security/ReentrancyGuard.sol#L23-L27).

_Instances (1)_:

```solidity
File: src/CryptoCurrencyStore.sol

7:     bool public lockedState;

```

### <a name="GAS-3"></a>[GAS-3] For Operations that will not overflow, you could use unchecked

_Instances (7)_:

```solidity
File: src/CryptoCurrencyStore.sol

10:         require(!lockedState, "Block re-entrancy");

17:         balances[msg.sender] += msg.value; //存款

21:         uint256 userBalance = balances[msg.sender]; //取得使用者存款資金

22:         require(userBalance > 0); //檢查使用者的存款資金是否大於0

24:         (bool sent,) = msg.sender.call{value: userBalance}(""); //這段會觸發攻擊者的fallback

25:         require(sent, "Failed to send Ether"); //sent如為false代表使用者取款失敗

27:         balances[msg.sender] = 0; //資金領取完畢，將餘額設置為0。

```

### <a name="GAS-4"></a>[GAS-4] Use Custom Errors instead of Revert Strings to save Gas

Custom errors are available from solidity version 0.8.4. Custom errors save [**~50 gas**](https://gist.github.com/IllIllI000/ad1bd0d29a0101b25e57c293b4b0c746) each time they're hit by [avoiding having to allocate and store the revert string](https://blog.soliditylang.org/2021/04/21/custom-errors/#errors-in-depth). Not defining the strings also save deployment gas

Additionally, custom errors can be used inside and outside of contracts (including interfaces and libraries).

Source: <https://blog.soliditylang.org/2021/04/21/custom-errors/>:

> Starting from [Solidity v0.8.4](https://github.com/ethereum/solidity/releases/tag/v0.8.4), there is a convenient and gas-efficient way to explain to users why an operation failed through the use of custom errors. Until now, you could already use strings to give more information about failures (e.g., `revert("Insufficient funds.");`), but they are rather expensive, especially when it comes to deploy cost, and it is difficult to use dynamic information in them.

Consider replacing **all revert strings** with custom errors in the solution, and particularly those that have multiple occurrences:

_Instances (2)_:

```solidity
File: src/CryptoCurrencyStore.sol

10:         require(!lockedState, "Block re-entrancy");

25:         require(sent, "Failed to send Ether"); //sent如為false代表使用者取款失敗

```

### <a name="GAS-5"></a>[GAS-5] Use != 0 instead of > 0 for unsigned integer comparison

_Instances (1)_:

```solidity
File: src/CryptoCurrencyStore.sol

22:         require(userBalance > 0); //檢查使用者的存款資金是否大於0

```

## Non Critical Issues

|               | Issue                                                                               | Instances |
| ------------- | :---------------------------------------------------------------------------------- | :-------: |
| [NC-1](#NC-1) | Functions should not be longer than 50 lines                                        |     2     |
| [NC-2](#NC-2) | NatSpec is completely non-existent on functions that should have them               |     2     |
| [NC-3](#NC-3) | Consider using named mappings                                                       |     1     |
| [NC-4](#NC-4) | `require()` / `revert()` statements should have descriptive reason strings          |     1     |
| [NC-5](#NC-5) | `public` functions not called by the contract should be declared `external` instead |     4     |

### <a name="NC-1"></a>[NC-1] Functions should not be longer than 50 lines

Overly complex code can make understanding functionality more difficult, try to further modularize your code to ensure readability

_Instances (2)_:

```solidity
File: src/CryptoCurrencyStore.sol

30:     function getBalance() public view returns (uint256) {

34:     function getContractAddress() public view returns (address) {

```

### <a name="NC-2"></a>[NC-2] NatSpec is completely non-existent on functions that should have them

Public and external functions that aren't view or pure should have NatSpec comments

_Instances (2)_:

```solidity
File: src/CryptoCurrencyStore.sol

16:     function deposit() public payable {

20:     function withdraw() public {

```

### <a name="NC-3"></a>[NC-3] Consider using named mappings

Consider moving to solidity version 0.8.18 or later, and using [named mappings](https://ethereum.stackexchange.com/questions/51629/how-to-name-the-arguments-in-mapping/145555#145555) to make it easier to understand the purpose of each mapping

_Instances (1)_:

```solidity
File: src/CryptoCurrencyStore.sol

5:     mapping(address => uint256) public balances;

```

### <a name="NC-4"></a>[NC-4] `require()` / `revert()` statements should have descriptive reason strings

_Instances (1)_:

```solidity
File: src/CryptoCurrencyStore.sol

22:         require(userBalance > 0); //檢查使用者的存款資金是否大於0

```

### <a name="NC-5"></a>[NC-5] `public` functions not called by the contract should be declared `external` instead

_Instances (4)_:

```solidity
File: src/CryptoCurrencyStore.sol

16:     function deposit() public payable {

20:     function withdraw() public {

34:     function getContractAddress() public view returns (address) {

38:

```

## Low Issues

|             | Issue                                                                | Instances |
| ----------- | :------------------------------------------------------------------- | :-------: |
| [L-1](#L-1) | External call recipient may consume all transaction gas              |     1     |
| [L-2](#L-2) | Fallback lacking `payable`                                           |     1     |
| [L-3](#L-3) | Solidity version 0.8.20+ may not work on other chains due to `PUSH0` |     1     |

### <a name="L-1"></a>[L-1] External call recipient may consume all transaction gas

There is no limit specified on the amount of gas used, so the recipient can use up all of the transaction's gas, causing it to revert. Use `addr.call{gas: <amount>}("")` or [this](https://github.com/nomad-xyz/ExcessivelySafeCall) library instead.

_Instances (1)_:

```solidity
File: src/CryptoCurrencyStore.sol

24:         (bool sent,) = msg.sender.call{value: userBalance}(""); //這段會觸發攻擊者的fallback

```

### <a name="L-2"></a>[L-2] Fallback lacking `payable`

_Instances (1)_:

```solidity
File: src/CryptoCurrencyStore.sol

24:         (bool sent,) = msg.sender.call{value: userBalance}(""); //這段會觸發攻擊者的fallback

```

### <a name="L-3"></a>[L-3] Solidity version 0.8.20+ may not work on other chains due to `PUSH0`

The compiler for Solidity 0.8.20 switches the default target EVM version to [Shanghai](https://blog.soliditylang.org/2023/05/10/solidity-0.8.20-release-announcement/#important-note), which includes the new `PUSH0` op code. This op code may not yet be implemented on all L2s, so deployment on these chains will fail. To work around this issue, use an earlier [EVM](https://docs.soliditylang.org/en/v0.8.20/using-the-compiler.html?ref=zaryabs.com#setting-the-evm-version-to-target) [version](https://book.getfoundry.sh/reference/config/solidity-compiler#evm_version). While the project itself may or may not compile with 0.8.20, other projects with which it integrates, or which extend this project may, and those projects will have problems deploying these contracts/libraries.

_Instances (1)_:

```solidity
File: src/CryptoCurrencyStore.sol

2: pragma solidity ^0.8.18;

```
