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

