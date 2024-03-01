# Web3-Security-Dev-Batch-1-HW

### Build or Compile

Build the contracts:

```sh
forge build
```

### Coverage

Get a test coverage report:

```sh
forge coverage
```

To get local HTMl reports:

```
make foundry-report
```

For this to work, you need to have [lcov](https://github.com/linux-test-project/lcov) installed.

### Clean

Delete the build artifacts and cache directories:

```sh
forge clean
```

### Deploy

Deploy to Anvil:

```sh
# Spin up an anvil local node
$ anvil

# On another terminal
$ forge script scripts/foundry/DeployLock.s.sol:DeployLock \
  --fork-url localhost \
  --broadcast \
  -vvvv
```

### Test Usage

```sh
test:forge
```

### Gas Usage

Gas reports give you an overview of how much Forge thinks the individual functions in your contracts will consume in gas.

```sh
gas-report:forge
```
<img width="1424" alt="Screenshot 2024-03-01 at 1 05 21 AM" src="https://github.com/z-institute/Web3-Security-Dev-Batch-1-HW/assets/56249189/0144ba70-ae8c-4f8e-adcc-b6627626e2af">

### Gas Snapshot

Gas snapshots give you an overview of how much each test consumes in gas.

```sh
test:gas-snapshot
```
<img width="1410" alt="Screenshot 2024-03-01 at 1 01 35 AM" src="https://github.com/z-institute/Web3-Security-Dev-Batch-1-HW/assets/56249189/894a0fc4-3342-4f01-98c4-3804849f39d9">

### Onchain Deployments & Verifications (Sepolia)

```sh
forge script scripts/foundry/deployToken.s.sol --broadcast --verify --account testAccount --rpc-url sepolia
```
<img width="1538" alt="image" src="https://github.com/z-institute/Web3-Security-Dev-Batch-1-HW/assets/56249189/bc4f1282-6851-4b22-9259-d4bd71e260b1">

<img width="1529" alt="image" src="https://github.com/z-institute/Web3-Security-Dev-Batch-1-HW/assets/56249189/15464208-e364-47a6-9d1a-491a4dae1af4">

### Cast Interactions 

Gas estimation (local,sepolia comparison)

<img width="1346" alt="Screenshot 2024-03-01 at 6 49 29 PM" src="https://github.com/z-institute/Web3-Security-Dev-Batch-1-HW/assets/56249189/75c8746b-1f8b-4756-b342-fa78b50106bd">

On-chain mint function test tx snapshot (sepolia) :
<img width="1375" alt="Screenshot 2024-03-01 at 6 58 06 PM" src="https://github.com/z-institute/Web3-Security-Dev-Batch-1-HW/assets/56249189/87860fc5-580e-4a3e-8010-49424788c3ea">

caller balance (after)(wei)
<img width="1349" alt="Screenshot 2024-03-01 at 6 59 45 PM" src="https://github.com/z-institute/Web3-Security-Dev-Batch-1-HW/assets/56249189/1581eca9-b980-48b9-85ce-5c71372b0b33">
caller balance (after)(wei->eth)
<img width="1355" alt="Screenshot 2024-03-01 at 7 01 50 PM" src="https://github.com/z-institute/Web3-Security-Dev-Batch-1-HW/assets/56249189/dccee981-bb48-4cfe-91b3-f635ecd20d79">

approve trans tx :
<img width="1079" alt="Screenshot 2024-03-01 at 7 13 16 PM" src="https://github.com/z-institute/Web3-Security-Dev-Batch-1-HW/assets/56249189/57019114-71dc-41e4-9073-aaf11be47d1c">

transfer from tx :
<img width="1204" alt="Screenshot 2024-03-01 at 7 18 42 PM" src="https://github.com/z-institute/Web3-Security-Dev-Batch-1-HW/assets/56249189/c686576c-0a1e-4b8a-bb36-4d8cf8f01f6d">




