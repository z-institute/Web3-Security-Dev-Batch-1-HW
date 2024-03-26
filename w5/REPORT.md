# Report


## Gas Optimizations


| |Issue|Instances|
|-|:-|:-:|
| [GAS-1](#GAS-1) | Don't use `_msgSender()` if not supporting EIP-2771 | 10 |
| [GAS-2](#GAS-2) | `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings) | 2 |
| [GAS-3](#GAS-3) | Use assembly to check for `address(0)` | 8 |
| [GAS-4](#GAS-4) | Comparing to a Boolean constant | 3 |
| [GAS-5](#GAS-5) | Using bools for storage incurs overhead | 7 |
| [GAS-6](#GAS-6) | Cache array length outside of loop | 2 |
| [GAS-7](#GAS-7) | Use calldata instead of memory for function arguments that do not get mutated | 6 |
| [GAS-8](#GAS-8) | For Operations that will not overflow, you could use unchecked | 49 |
| [GAS-9](#GAS-9) | Use Custom Errors instead of Revert Strings to save Gas | 71 |
| [GAS-10](#GAS-10) | Avoid contract existence checks by using low level calls | 4 |
| [GAS-11](#GAS-11) | Stack variable used as a cheaper cache for a state variable is only used once | 1 |
| [GAS-12](#GAS-12) | State variables only set in the constructor should be declared `immutable` | 1 |
| [GAS-13](#GAS-13) | Functions guaranteed to revert when called by normal users can be marked `payable` | 5 |
| [GAS-14](#GAS-14) | `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`) | 7 |
| [GAS-15](#GAS-15) | Splitting require() statements that use && saves gas | 3 |
| [GAS-16](#GAS-16) | Increments/decrements can be unchecked in for-loops | 7 |
| [GAS-17](#GAS-17) | Use != 0 instead of > 0 for unsigned integer comparison | 11 |
| [GAS-18](#GAS-18) | `internal` functions not called by the contract should be removed | 2 |
### <a name="GAS-1"></a>[GAS-1] Don't use `_msgSender()` if not supporting EIP-2771
Use `msg.sender` if the code does not implement [EIP-2771 trusted forwarder](https://eips.ethereum.org/EIPS/eip-2771) support

*Instances (10)*:
```solidity
File: example/CarMan.sol

588:     function _msgSender() internal view virtual returns (address) {

703:             _msgSender() == owner || isApprovedForAll(owner, _msgSender()),

723:         require(operator != _msgSender(), "ERC721: approve to caller");

725:         _operatorApprovals[_msgSender()][operator] = approved;

726:         emit ApprovalForAll(_msgSender(), operator, approved);

745:         require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

770:         require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

963:             try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {

1188:         _setOwner(_msgSender());

1202:         require(owner() == _msgSender(), "Ownable: caller is not the owner");

```

### <a name="GAS-2"></a>[GAS-2] `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings)
This saves **16 gas per instance.**

*Instances (2)*:
```solidity
File: example/CarMan.sol

875:         _balances[to] += 1;

930:         _balances[to] += 1;

```

### <a name="GAS-3"></a>[GAS-3] Use assembly to check for `address(0)`
*Saves 6 gas per instance*

*Instances (8)*:
```solidity
File: example/CarMan.sol

665:     function name() public view virtual override returns (string memory) {

679:     function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

824:         return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));

891:     function _burn(uint256 tokenId) internal virtual {

942:         _tokenApprovals[tokenId] = to;

1092:      * @param to address representing the new owner of the given token ID

1095:     function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

1241:   uint256 public cost = 0.5 ether;

```

### <a name="GAS-4"></a>[GAS-4] Comparing to a Boolean constant
Comparing to a constant (`true` or `false`) is a bit more expensive than directly checking the returned boolean value.

Consider using `if(directValue)` instead of `if(directValue == true)` and `if(!directValue)` instead of `if(directValue == false)`

*Instances (3)*:
```solidity
File: example/CarMan.sol

1316:         if(onlyWhitelisted == true) {

1341:         if(onlyWhitelisted == true) {

1381:     if(revealed == false) {

```

### <a name="GAS-5"></a>[GAS-5] Using bools for storage incurs overhead
Use uint256(1) and uint256(2) for true/false to avoid a Gwarmaccess (100 gas), and to avoid Gsset (20000 gas) when changing from ‘false’ to ‘true’, after having been ‘true’ in the past. See [source](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/58f635312aa21f947cae5f8578638a85aa2519f5/contracts/security/ReentrancyGuard.sol#L23-L27).

*Instances (7)*:
```solidity
File: example/CarMan.sol

625:     mapping(address => mapping(address => bool)) private _operatorApprovals;

1251:   bool public publicSalePaused = true;

1252:   bool public preSalePaused = true;

1253:   bool public vipSalePaused = true;

1255:   bool public revealed = false;

1256:   bool public onlyWhitelisted = true;

1263:   mapping(address => bool) controllers;

```

### <a name="GAS-6"></a>[GAS-6] Cache array length outside of loop
If not cached, the solidity compiler will always read the length of the array during each iteration. That is, if it is a storage array, this is an extra sload operation (100 additional extra gas for each iteration except for the first) and if it is a memory array, this is an extra mload operation (3 additional gas for each iteration except for the first).

*Instances (2)*:
```solidity
File: example/CarMan.sol

1356:     for (uint i = 0; i < whitelistedAddresses.length; i++) {

1477:     for (uint256 i = 0; i < _accounts.length; ++i) {

```

### <a name="GAS-7"></a>[GAS-7] Use calldata instead of memory for function arguments that do not get mutated
When a function with a `memory` array is called externally, the `abi.decode()` step has to use a for-loop to copy each index of the `calldata` to the `memory` index. Each iteration of this for-loop costs at least 60 gas (i.e. `60 * <mem_array>.length`). Using `calldata` directly bypasses this loop. 

If the array is passed to an `internal` function which passes the array to another internal function where the array is modified and therefore `memory` is used in the `external` call, it's still more gas-efficient to use `calldata` when the `external` function uses modifiers, since the modifiers may prevent the internal functions from being called. Structs have the same overhead as an array of length one. 

 *Saves 60 gas per instance*

*Instances (6)*:
```solidity
File: example/CarMan.sol

780:      * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.

1460:     notRevealedUri = _notRevealedURI;

1465:     preSalePaused = _state;

1473:   function setVIPMintAmount(address[] memory _accounts, uint256[] memory _amounts) public {

1485:   }

1487:   function setOnlyWhitelisted(bool _state) public {

```

### <a name="GAS-8"></a>[GAS-8] For Operations that will not overflow, you could use unchecked

*Instances (49)*:
```solidity
File: example/CarMan.sol

255:             digits++;

256:             temp /= 10;

260:             digits -= 1;

261:             buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));

262:             value /= 10;

277:             length++;

287:         bytes memory buffer = new bytes(2 * length + 2);

290:         for (uint256 i = 2 * length + 1; i > 1; --i) {

380:         return functionCall(target, data, "Address: low-level call failed");

413:         return functionCallWithValue(target, data, value, "Address: low-level call with value failed");

429:         require(isContract(target), "Address: call to non-contract");

442:         return functionStaticCall(target, data, "Address: low-level static call failed");

456:         require(isContract(target), "Address: static call to non-contract");

469:         return functionDelegateCall(target, data, "Address: low-level delegate call failed");

483:         require(isContract(target), "Address: delegate call to non-contract");

875:         _balances[to] += 1;

899:         _balances[owner] -= 1;

929:         _balances[from] -= 1;

930:         _balances[to] += 1;

1122:         uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;

1129:             _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token

1130:             _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

1147:         uint256 lastTokenIndex = _allTokens.length - 1;

1155:         _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token

1156:         _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

1289:     require(supply + _mintAmount <= currentPhaseMintMaxAmount, "reach current Phase NFT limit");

1290:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1296:     require(ownerMintedCount + _mintAmount <= vipMintCount, "max VIP Mint Amount exceeded");

1297:     require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");

1299:     for (uint256 i = 1; i <= _mintAmount; i++) {

1300:         addressMintedBalance[msg.sender]++;

1301:       _safeMint(msg.sender, supply + i);

1312:     require(supply + _mintAmount <= currentPhaseMintMaxAmount, "reach current Phase NFT limit");

1313:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1319:             require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");

1321:         require(msg.value >= cost * _mintAmount, "insufficient funds");

1324:     for (uint256 i = 1; i <= _mintAmount; i++) {

1325:         addressMintedBalance[msg.sender]++;

1326:       _safeMint(msg.sender, supply + i);

1337:     require(supply + _mintAmount <= currentPhaseMintMaxAmount, "reach current Phase NFT limit");

1338:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1344:             require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");

1346:         require(msg.value >= cost * _mintAmount, "insufficient funds");

1349:     for (uint256 i = 1; i <= _mintAmount; i++) {

1350:         addressMintedBalance[msg.sender]++;

1351:       _safeMint(msg.sender, supply + i);

1356:     for (uint i = 0; i < whitelistedAddresses.length; i++) {

1368:     for (uint256 i; i < ownerTokenCount; i++) {

1477:     for (uint256 i = 0; i < _accounts.length; ++i) {

```

### <a name="GAS-9"></a>[GAS-9] Use Custom Errors instead of Revert Strings to save Gas
Custom errors are available from solidity version 0.8.4. Custom errors save [**~50 gas**](https://gist.github.com/IllIllI000/ad1bd0d29a0101b25e57c293b4b0c746) each time they're hit by [avoiding having to allocate and store the revert string](https://blog.soliditylang.org/2021/04/21/custom-errors/#errors-in-depth). Not defining the strings also save deployment gas

Additionally, custom errors can be used inside and outside of contracts (including interfaces and libraries).

Source: <https://blog.soliditylang.org/2021/04/21/custom-errors/>:

> Starting from [Solidity v0.8.4](https://github.com/ethereum/solidity/releases/tag/v0.8.4), there is a convenient and gas-efficient way to explain to users why an operation failed through the use of custom errors. Until now, you could already use strings to give more information about failures (e.g., `revert("Insufficient funds.");`), but they are rather expensive, especially when it comes to deploy cost, and it is difficult to use dynamic information in them.

Consider replacing **all revert strings** with custom errors in the solution, and particularly those that have multiple occurrences:

*Instances (71)*:
```solidity
File: example/CarMan.sol

294:         require(value == 0, "Strings: hex length insufficient");

355:         require(address(this).balance >= amount, "Address: insufficient balance");

358:         require(success, "Address: unable to send value, recipient may have reverted");

428:         require(address(this).balance >= value, "Address: insufficient balance for call");

429:         require(isContract(target), "Address: call to non-contract");

456:         require(isContract(target), "Address: static call to non-contract");

483:         require(isContract(target), "Address: delegate call to non-contract");

649:         require(owner != address(0), "ERC721: balance query for the zero address");

658:         require(owner != address(0), "ERC721: owner query for nonexistent token");

680:         require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

700:         require(to != owner, "ERC721: approval to current owner");

714:         require(_exists(tokenId), "ERC721: approved query for nonexistent token");

723:         require(operator != _msgSender(), "ERC721: approve to caller");

745:         require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

770:         require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

799:         require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");

822:         require(_exists(tokenId), "ERC721: operator query for nonexistent token");

870:         require(to != address(0), "ERC721: mint to the zero address");

871:         require(!_exists(tokenId), "ERC721: token already minted");

921:         require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");

922:         require(to != address(0), "ERC721: transfer to the zero address");

967:                     revert("ERC721: transfer to non ERC721Receiver implementer");

1037:         require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");

1052:         require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");

1202:         require(owner() == _msgSender(), "Ownable: caller is not the owner");

1222:         require(newOwner != address(0), "Ownable: new owner is the zero address");

1283:     require(_mintAmount > 0, "Mint Amount should be bigger than 0");

1284:     require((!vipSalePaused)&&(vipSaleStart <= block.timestamp), "Not Reach VIP Sale Time");

1287:     require(_mintAmount > 0, "need to mint at least 1 NFT");

1288:     require(_mintAmount <= maxMintAmount, "max mint amount per session exceeded");

1289:     require(supply + _mintAmount <= currentPhaseMintMaxAmount, "reach current Phase NFT limit");

1290:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1292:     require(vipMintAmount[msg.sender] != 0, "user is not VIP");

1296:     require(ownerMintedCount + _mintAmount <= vipMintCount, "max VIP Mint Amount exceeded");

1297:     require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");

1306:     require(_mintAmount > 0, "Mint Amount should be bigger than 0");

1307:     require((!preSalePaused)&&(preSaleStart <= block.timestamp), "Not Reach Pre Sale Time");

1310:     require(_mintAmount > 0, "need to mint at least 1 NFT");

1311:     require(_mintAmount <= maxMintAmount, "max mint amount per session exceeded");

1312:     require(supply + _mintAmount <= currentPhaseMintMaxAmount, "reach current Phase NFT limit");

1313:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1317:             require(isWhitelisted(msg.sender), "user is not whitelisted");

1319:             require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");

1321:         require(msg.value >= cost * _mintAmount, "insufficient funds");

1331:     require(_mintAmount > 0, "Mint Amount should be bigger than 0");

1332:     require((!publicSalePaused)&&(publicSaleStart <= block.timestamp), "Not Reach Public Sale Time");

1335:     require(_mintAmount > 0, "need to mint at least 1 NFT");

1336:     require(_mintAmount <= maxMintAmount, "max mint amount per session exceeded");

1337:     require(supply + _mintAmount <= currentPhaseMintMaxAmount, "reach current Phase NFT limit");

1338:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1342:             require(isWhitelisted(msg.sender), "user is not whitelisted");

1344:             require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");

1346:         require(msg.value >= cost * _mintAmount, "insufficient funds");

1409:     require(controllers[msg.sender], "Only controllers can operate this function");

1414:     require(controllers[msg.sender], "Only controllers can operate this function");

1419:     require(controllers[msg.sender], "Only controllers can operate this function");

1424:     require(controllers[msg.sender], "Only controllers can operate this function");

1429:     require(controllers[msg.sender], "Only controllers can operate this function");

1434:     require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");

1444:     require(controllers[msg.sender], "Only controllers can operate this function");

1449:     require(controllers[msg.sender], "Only controllers can operate this function");

1454:     require(controllers[msg.sender], "Only controllers can operate this function");

1459:     require(controllers[msg.sender], "Only controllers can operate this function");

1464:     require(controllers[msg.sender], "Only controllers can operate this function");

1469:     require(controllers[msg.sender], "Only controllers can operate this function");

1474:     require(controllers[msg.sender], "Only controllers can operate this function");

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");

1483:     require(controllers[msg.sender], "Only controllers can operate this function");

1488:     require(controllers[msg.sender], "Only controllers can operate this function");

1493:     require(controllers[msg.sender], "Only controllers can operate this function");

```

### <a name="GAS-10"></a>[GAS-10] Avoid contract existence checks by using low level calls
Prior to 0.8.10 the compiler inserted extra code, including `EXTCODESIZE` (**100 gas**), to check for contract existence for external function calls. In more recent solidity versions, the compiler will not insert these checks if the external call has a return value. Similar behavior can be achieved in earlier versions by using low-level calls, since low level calls never check for contract existence

*Instances (4)*:
```solidity
File: example/CarMan.sol

485:         (bool success, bytes memory returndata) = target.delegatecall(data);

1037:         require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");

1096:         uint256 length = ERC721.balanceOf(to);

1122:         uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;

```

### <a name="GAS-11"></a>[GAS-11] Stack variable used as a cheaper cache for a state variable is only used once
If the variable is only accessed once, it's cheaper to use the state variable directly that one time, and save the **3 gas** the extra stack assignment would spend

*Instances (1)*:
```solidity
File: example/CarMan.sol

1245:   uint256 public currentPhaseMintMaxAmount = 110;

```

### <a name="GAS-12"></a>[GAS-12] State variables only set in the constructor should be declared `immutable`
Variables only set in the constructor and never edited afterwards should be marked as immutable, as it would avoid the expensive storage-writing operation in the constructor (around **20 000 gas** per variable) and replace the expensive storage-reading operations (around **2100 gas** per reading) to a less expensive value reading (**3 gas**)

*Instances (1)*:
```solidity
File: example/CarMan.sol

648:     function balanceOf(address owner) public view virtual override returns (uint256) {

```

### <a name="GAS-13"></a>[GAS-13] Functions guaranteed to revert when called by normal users can be marked `payable`
If a function modifier such as `onlyOwner` is used, the function will revert if a normal user tries to pay the function. Marking the function as `payable` will lower the gas cost for legitimate callers because the compiler will not include checks for whether a payment was provided.

*Instances (5)*:
```solidity
File: example/CarMan.sol

1213:     function renounceOwnership() public virtual onlyOwner {

1221:     function transferOwnership(address newOwner) public virtual onlyOwner {

1504:   function addController(address controller) external onlyOwner {

1512:   function removeController(address controller) external onlyOwner {

1516:   function withdraw() public onlyOwner {

```

### <a name="GAS-14"></a>[GAS-14] `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`)
Pre-increments and pre-decrements are cheaper.

For a `uint256 i` variable, the following is true with the Optimizer enabled at 10k:

**Increment:**

- `i += 1` is the most expensive form
- `i++` costs 6 gas less than `i += 1`
- `++i` costs 5 gas less than `i++` (11 gas less than `i += 1`)

**Decrement:**

- `i -= 1` is the most expensive form
- `i--` costs 11 gas less than `i -= 1`
- `--i` costs 5 gas less than `i--` (16 gas less than `i -= 1`)

Note that post-increments (or post-decrements) return the old value before incrementing or decrementing, hence the name *post-increment*:

```solidity
uint i = 1;  
uint j = 2;
require(j == i++, "This will be false as i is incremented after the comparison");
```
  
However, pre-increments (or pre-decrements) return the new value:
  
```solidity
uint i = 1;  
uint j = 2;
require(j == ++i, "This will be true as i is incremented before the comparison");
```

In the pre-increment case, the compiler has to create a temporary variable (when used) for returning `1` instead of `2`.

Consider using pre-increments and pre-decrements where they are relevant (meaning: not where post-increments/decrements logic are relevant).

*Saves 5 gas per instance*

*Instances (7)*:
```solidity
File: example/CarMan.sol

255:             digits++;

277:             length++;

1299:     for (uint256 i = 1; i <= _mintAmount; i++) {

1324:     for (uint256 i = 1; i <= _mintAmount; i++) {

1349:     for (uint256 i = 1; i <= _mintAmount; i++) {

1356:     for (uint i = 0; i < whitelistedAddresses.length; i++) {

1368:     for (uint256 i; i < ownerTokenCount; i++) {

```

### <a name="GAS-15"></a>[GAS-15] Splitting require() statements that use && saves gas

*Instances (3)*:
```solidity
File: example/CarMan.sol

1284:     require((!vipSalePaused)&&(vipSaleStart <= block.timestamp), "Not Reach VIP Sale Time");

1307:     require((!preSalePaused)&&(preSaleStart <= block.timestamp), "Not Reach Pre Sale Time");

1332:     require((!publicSalePaused)&&(publicSaleStart <= block.timestamp), "Not Reach Public Sale Time");

```

### <a name="GAS-16"></a>[GAS-16] Increments/decrements can be unchecked in for-loops
In Solidity 0.8+, there's a default overflow check on unsigned integers. It's possible to uncheck this in for-loops and save some gas at each iteration, but at the cost of some code readability, as this uncheck cannot be made inline.

[ethereum/solidity#10695](https://github.com/ethereum/solidity/issues/10695)

The change would be:

```diff
- for (uint256 i; i < numIterations; i++) {
+ for (uint256 i; i < numIterations;) {
 // ...  
+   unchecked { ++i; }
}  
```

These save around **25 gas saved** per instance.

The same can be applied with decrements (which should use `break` when `i == 0`).

The risk of overflow is non-existent for `uint256`.

*Instances (7)*:
```solidity
File: example/CarMan.sol

290:         for (uint256 i = 2 * length + 1; i > 1; --i) {

1299:     for (uint256 i = 1; i <= _mintAmount; i++) {

1324:     for (uint256 i = 1; i <= _mintAmount; i++) {

1349:     for (uint256 i = 1; i <= _mintAmount; i++) {

1356:     for (uint i = 0; i < whitelistedAddresses.length; i++) {

1368:     for (uint256 i; i < ownerTokenCount; i++) {

1477:     for (uint256 i = 0; i < _accounts.length; ++i) {

```

### <a name="GAS-17"></a>[GAS-17] Use != 0 instead of > 0 for unsigned integer comparison

*Instances (11)*:
```solidity
File: example/CarMan.sol

335:         return size > 0;

504:             if (returndata.length > 0) {

683:         return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";

1233: pragma solidity >=0.7.0 <0.9.0;

1283:     require(_mintAmount > 0, "Mint Amount should be bigger than 0");

1287:     require(_mintAmount > 0, "need to mint at least 1 NFT");

1306:     require(_mintAmount > 0, "Mint Amount should be bigger than 0");

1310:     require(_mintAmount > 0, "need to mint at least 1 NFT");

1331:     require(_mintAmount > 0, "Mint Amount should be bigger than 0");

1335:     require(_mintAmount > 0, "need to mint at least 1 NFT");

1386:     return bytes(currentBaseURI).length > 0

```

### <a name="GAS-18"></a>[GAS-18] `internal` functions not called by the contract should be removed
If the functions are required by an interface, the contract should inherit from that interface and use the `override` keyword

*Instances (2)*:
```solidity
File: example/CarMan.sol

259:         while (value != 0) {

366:      * If `target` reverts with a revert reason, it is bubbled up by this

```


## Non Critical Issues


| |Issue|Instances|
|-|:-|:-:|
| [NC-1](#NC-1) | Missing checks for `address(0)` when assigning values to address state variables | 1 |
| [NC-2](#NC-2) | Array indices should be referenced via `enum`s rather than via numeric literals | 2 |
| [NC-3](#NC-3) | Use `string.concat()` or `bytes.concat()` instead of `abi.encodePacked` | 2 |
| [NC-4](#NC-4) | `constant`s should be defined rather than using magic numbers | 14 |
| [NC-5](#NC-5) | Control structures do not follow the Solidity Style Guide | 7 |
| [NC-6](#NC-6) | Consider disabling `renounceOwnership()` | 1 |
| [NC-7](#NC-7) | Duplicated `require()`/`revert()` Checks Should Be Refactored To A Modifier Or Function | 44 |
| [NC-8](#NC-8) | Events that mark critical parameter changes should contain both the old and the new value | 1 |
| [NC-9](#NC-9) | Function ordering does not follow the Solidity style guide | 1 |
| [NC-10](#NC-10) | Functions should not be longer than 50 lines | 81 |
| [NC-11](#NC-11) | Change int to int256 | 11 |
| [NC-12](#NC-12) | Change uint to uint256 | 1 |
| [NC-13](#NC-13) | Interfaces should be defined in separate files from their usage | 5 |
| [NC-14](#NC-14) | Lack of checks in setters | 16 |
| [NC-15](#NC-15) | Missing Event for critical parameters change | 128 |
| [NC-16](#NC-16) | NatSpec is completely non-existent on functions that should have them | 168 |
| [NC-17](#NC-17) | Incomplete NatSpec: `@param` is missing on actually documented functions | 48 |
| [NC-18](#NC-18) | Incomplete NatSpec: `@return` is missing on actually documented functions | 1 |
| [NC-19](#NC-19) | Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor | 22 |
| [NC-20](#NC-20) | Consider using named mappings | 10 |
| [NC-21](#NC-21) | `require()` / `revert()` statements should have descriptive reason strings | 1 |
| [NC-22](#NC-22) | Avoid the use of sensitive terms | 14 |
| [NC-23](#NC-23) | Contract does not follow the Solidity style guide's suggested layout ordering | 1 |
| [NC-24](#NC-24) | Use Underscores for Number Literals (add an underscore every 3 digits) | 4 |
| [NC-25](#NC-25) | Internal and private variables and functions names should begin with an underscore | 18 |
| [NC-26](#NC-26) | Event is missing `indexed` fields | 1 |
| [NC-27](#NC-27) | `public` functions not called by the contract should be declared `external` instead | 26 |
| [NC-28](#NC-28) | Variables need not be initialized to zero | 3 |
### <a name="NC-1"></a>[NC-1] Missing checks for `address(0)` when assigning values to address state variables

*Instances (1)*:
```solidity
File: example/CarMan.sol

1247:   uint32 public publicSaleStart = 1647136800;

```

### <a name="NC-2"></a>[NC-2] Array indices should be referenced via `enum`s rather than via numeric literals

*Instances (2)*:
```solidity
File: example/CarMan.sol

311:      *

313:      * ====

```

### <a name="NC-3"></a>[NC-3] Use `string.concat()` or `bytes.concat()` instead of `abi.encodePacked`
Solidity version 0.8.4 introduces `bytes.concat()` (vs `abi.encodePacked(<bytes>,<bytes>)`)

Solidity version 0.8.12 introduces `string.concat()` (vs `abi.encodePacked(<str>,<str>), which catches concatenation errors (in the event of a `bytes` data mixed in the concatenation)`)

*Instances (2)*:
```solidity
File: example/CarMan.sol

683:         return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";

1387:         ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))

```

### <a name="NC-4"></a>[NC-4] `constant`s should be defined rather than using magic numbers
Even [assembly](https://github.com/code-423n4/2022-05-opensea-seaport/blob/9d7ce4d08bf3c3010304a0476a785c70c0e90ae7/contracts/lib/TokenTransferrer.sol#L35-L39) can benefit from using readable constants instead of hex/numeric literals

*Instances (14)*:
```solidity
File: example/CarMan.sol

256:             temp /= 10;

261:             buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));

262:             value /= 10;

278:             temp >>= 8;

287:         bytes memory buffer = new bytes(2 * length + 2);

290:         for (uint256 i = 2 * length + 1; i > 1; --i) {

292:             value >>= 4;

1242:   uint256 public maxSupply = 2000;

1243:   uint256 public maxMintAmount = 10;

1244:   uint256 public nftPerAddressLimit = 10;

1245:   uint256 public currentPhaseMintMaxAmount = 110;

1247:   uint32 public publicSaleStart = 1647136800;

1248:   uint32 public preSaleStart = 1646964000;

1249:   uint32 public vipSaleStart = 1646618400;

```

### <a name="NC-5"></a>[NC-5] Control structures do not follow the Solidity Style Guide
See the [control structures](https://docs.soliditylang.org/en/latest/style-guide.html#control-structures) section of the Solidity Style Guide

*Instances (7)*:
```solidity
File: example/CarMan.sol

432:         return verifyCallResult(success, returndata, errorMessage);

459:         return verifyCallResult(success, returndata, errorMessage);

486:         return verifyCallResult(success, returndata, errorMessage);

495:     function verifyCallResult(

1316:         if(onlyWhitelisted == true) {

1341:         if(onlyWhitelisted == true) {

1381:     if(revealed == false) {

```

### <a name="NC-6"></a>[NC-6] Consider disabling `renounceOwnership()`
If the plan for your project does not include eventually giving up all ownership control, consider overwriting OpenZeppelin's `Ownable`'s `renounceOwnership()` function in order to disable it.

*Instances (1)*:
```solidity
File: example/CarMan.sol

1235: contract CarMan is ERC721Enumerable, Ownable {

```

### <a name="NC-7"></a>[NC-7] Duplicated `require()`/`revert()` Checks Should Be Refactored To A Modifier Or Function

*Instances (44)*:
```solidity
File: example/CarMan.sol

691:     function _baseURI() internal view virtual returns (string memory) {

766:         address to,

780:      * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.

811:         return _owners[tokenId] != address(0);

869:     function _mint(address to, uint256 tokenId) internal virtual {

1292:     require(vipMintAmount[msg.sender] != 0, "user is not VIP");

1296:     require(ownerMintedCount + _mintAmount <= vipMintCount, "max VIP Mint Amount exceeded");

1297:     require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");

1300:         addressMintedBalance[msg.sender]++;

1310:     require(_mintAmount > 0, "need to mint at least 1 NFT");

1315:     if (msg.sender != owner()) {

1318:             uint256 ownerMintedCount = addressMintedBalance[msg.sender];

1319:             require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");

1321:         require(msg.value >= cost * _mintAmount, "insufficient funds");

1324:     for (uint256 i = 1; i <= _mintAmount; i++) {

1330:   function publicSaleMint(uint256 _mintAmount) public payable {

1332:     require((!publicSalePaused)&&(publicSaleStart <= block.timestamp), "Not Reach Public Sale Time");

1335:     require(_mintAmount > 0, "need to mint at least 1 NFT");

1340:     if (msg.sender != owner()) {

1343:             uint256 ownerMintedCount = addressMintedBalance[msg.sender];

1344:             require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");

1346:         require(msg.value >= cost * _mintAmount, "insufficient funds");

1349:     for (uint256 i = 1; i <= _mintAmount; i++) {

1355:   function isWhitelisted(address _user) public view returns (bool) {

1358:           return true;

1364:   function walletOfOwner(address _owner) public view returns (uint256[] memory)

1395:   function preSaleIsActive() public view returns (bool) {

1424:     require(controllers[msg.sender], "Only controllers can operate this function");

1428:   function setcurrentPhaseMintMaxAmount(uint256 _newPhaseAmount) public {

1433:   function setPublicSaleStart(uint32 timestamp) public {

1438:   function setPreSaleStart(uint32 timestamp) public {

1443:   function setVIPSaleStart(uint32 timestamp) public {

1448:   function setBaseURI(string memory _newBaseURI) public {

1453:   function setBaseExtension(string memory _newBaseExtension) public {

1458:   function setNotRevealedURI(string memory _notRevealedURI) public {

1463:   function setPreSalePause(bool _state) public {

1468:   function setVIPSalePause(bool _state) public {

1473:   function setVIPMintAmount(address[] memory _accounts, uint256[] memory _amounts) public {

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");

1482:   function setPublicSalePause(bool _state) public {

1488:     require(controllers[msg.sender], "Only controllers can operate this function");

1498:   //only owner

1505:     controllers[controller] = true;

1512:   function removeController(address controller) external onlyOwner {

```

### <a name="NC-8"></a>[NC-8] Events that mark critical parameter changes should contain both the old and the new value
This should especially be done if the new value is not required to be different from the old value

*Instances (1)*:
```solidity
File: example/CarMan.sol

736:     /**
          * @dev See {IERC721-transferFrom}.
          */
         function transferFrom(
             address from,
             address to,
             uint256 tokenId
         ) public virtual override {
             //solhint-disable-next-line max-line-length

```

### <a name="NC-9"></a>[NC-9] Function ordering does not follow the Solidity style guide
According to the [Solidity style guide](https://docs.soliditylang.org/en/v0.8.17/style-guide.html#order-of-functions), functions should be laid out in the following order :`constructor()`, `receive()`, `fallback()`, `external`, `public`, `internal`, `private`, but the cases below do not follow this pattern

*Instances (1)*:
```solidity
File: example/CarMan.sol

1: 
   Current order:
   external supportsInterface
   external balanceOf
   external ownerOf
   external safeTransferFrom
   external transferFrom
   external approve
   external getApproved
   external setApprovalForAll
   external isApprovedForAll
   external safeTransferFrom
   external totalSupply
   external tokenOfOwnerByIndex
   external tokenByIndex
   public supportsInterface
   internal toString
   internal toHexString
   internal toHexString
   internal isContract
   internal sendValue
   internal functionCall
   internal functionCall
   internal functionCallWithValue
   internal functionCallWithValue
   internal functionStaticCall
   internal functionStaticCall
   internal functionDelegateCall
   internal functionDelegateCall
   internal verifyCallResult
   external name
   external symbol
   external tokenURI
   external onERC721Received
   internal _msgSender
   internal _msgData
   public supportsInterface
   public balanceOf
   public ownerOf
   public name
   public symbol
   public tokenURI
   internal _baseURI
   public approve
   public getApproved
   public setApprovalForAll
   public isApprovedForAll
   public transferFrom
   public safeTransferFrom
   public safeTransferFrom
   internal _safeTransfer
   internal _exists
   internal _isApprovedOrOwner
   internal _safeMint
   internal _safeMint
   internal _mint
   internal _burn
   internal _transfer
   internal _approve
   private _checkOnERC721Received
   internal _beforeTokenTransfer
   public supportsInterface
   public tokenOfOwnerByIndex
   public totalSupply
   public tokenByIndex
   internal _beforeTokenTransfer
   private _addTokenToOwnerEnumeration
   private _addTokenToAllTokensEnumeration
   private _removeTokenFromOwnerEnumeration
   private _removeTokenFromAllTokensEnumeration
   public owner
   public renounceOwnership
   public transferOwnership
   private _setOwner
   internal _baseURI
   public vipSaleMint
   public preSaleMint
   public publicSaleMint
   public isWhitelisted
   public walletOfOwner
   public tokenURI
   public publicSaleIsActive
   public preSaleIsActive
   public vipSaleIsActive
   public checkVIPMintAmount
   public reveal
   public setNftPerAddressLimit
   public setCost
   public setmaxMintAmount
   public setcurrentPhaseMintMaxAmount
   public setPublicSaleStart
   public setPreSaleStart
   public setVIPSaleStart
   public setBaseURI
   public setBaseExtension
   public setNotRevealedURI
   public setPreSalePause
   public setVIPSalePause
   public setVIPMintAmount
   public setPublicSalePause
   public setOnlyWhitelisted
   public whitelistUsers
   external addController
   external removeController
   public withdraw
   
   Suggested order:
   external supportsInterface
   external balanceOf
   external ownerOf
   external safeTransferFrom
   external transferFrom
   external approve
   external getApproved
   external setApprovalForAll
   external isApprovedForAll
   external safeTransferFrom
   external totalSupply
   external tokenOfOwnerByIndex
   external tokenByIndex
   external name
   external symbol
   external tokenURI
   external onERC721Received
   external addController
   external removeController
   public supportsInterface
   public supportsInterface
   public balanceOf
   public ownerOf
   public name
   public symbol
   public tokenURI
   public approve
   public getApproved
   public setApprovalForAll
   public isApprovedForAll
   public transferFrom
   public safeTransferFrom
   public safeTransferFrom
   public supportsInterface
   public tokenOfOwnerByIndex
   public totalSupply
   public tokenByIndex
   public owner
   public renounceOwnership
   public transferOwnership
   public vipSaleMint
   public preSaleMint
   public publicSaleMint
   public isWhitelisted
   public walletOfOwner
   public tokenURI
   public publicSaleIsActive
   public preSaleIsActive
   public vipSaleIsActive
   public checkVIPMintAmount
   public reveal
   public setNftPerAddressLimit
   public setCost
   public setmaxMintAmount
   public setcurrentPhaseMintMaxAmount
   public setPublicSaleStart
   public setPreSaleStart
   public setVIPSaleStart
   public setBaseURI
   public setBaseExtension
   public setNotRevealedURI
   public setPreSalePause
   public setVIPSalePause
   public setVIPMintAmount
   public setPublicSalePause
   public setOnlyWhitelisted
   public whitelistUsers
   public withdraw
   internal toString
   internal toHexString
   internal toHexString
   internal isContract
   internal sendValue
   internal functionCall
   internal functionCall
   internal functionCallWithValue
   internal functionCallWithValue
   internal functionStaticCall
   internal functionStaticCall
   internal functionDelegateCall
   internal functionDelegateCall
   internal verifyCallResult
   internal _msgSender
   internal _msgData
   internal _baseURI
   internal _safeTransfer
   internal _exists
   internal _isApprovedOrOwner
   internal _safeMint
   internal _safeMint
   internal _mint
   internal _burn
   internal _transfer
   internal _approve
   internal _beforeTokenTransfer
   internal _beforeTokenTransfer
   internal _baseURI
   private _checkOnERC721Received
   private _addTokenToOwnerEnumeration
   private _addTokenToAllTokensEnumeration
   private _removeTokenFromOwnerEnumeration
   private _removeTokenFromAllTokensEnumeration
   private _setOwner

```

### <a name="NC-10"></a>[NC-10] Functions should not be longer than 50 lines
Overly complex code can make understanding functionality more difficult, try to further modularize your code to ensure readability 

*Instances (81)*:
```solidity
File: example/CarMan.sol

36:     function supportsInterface(bytes4 interfaceId) external view returns (bool);

63:     function balanceOf(address owner) external view returns (uint256 balance);

72:     function ownerOf(uint256 tokenId) external view returns (address owner);

127:     function approve(address to, uint256 tokenId) external;

136:     function getApproved(uint256 tokenId) external view returns (address operator);

148:     function setApprovalForAll(address operator, bool _approved) external;

155:     function isApprovedForAll(address owner, address operator) external view returns (bool);

189:     function totalSupply() external view returns (uint256);

195:     function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

201:     function tokenByIndex(uint256 index) external view returns (uint256);

225:     function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

245:     function toString(uint256 value) internal pure returns (string memory) {

270:     function toHexString(uint256 value) internal pure returns (string memory) {

286:     function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

326:     function isContract(address account) internal view returns (bool) {

354:     function sendValue(address payable recipient, uint256 amount) internal {

379:     function functionCall(address target, bytes memory data) internal returns (bytes memory) {

380:         return functionCall(target, data, "Address: low-level call failed");

394:         return functionCallWithValue(target, data, 0, errorMessage);

413:         return functionCallWithValue(target, data, value, "Address: low-level call with value failed");

441:     function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

442:         return functionStaticCall(target, data, "Address: low-level static call failed");

468:     function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

469:         return functionDelegateCall(target, data, "Address: low-level delegate call failed");

533:     function name() external view returns (string memory);

538:     function symbol() external view returns (string memory);

543:     function tokenURI(uint256 tokenId) external view returns (string memory);

588:     function _msgSender() internal view virtual returns (address) {

592:     function _msgData() internal view virtual returns (bytes calldata) {

638:     function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

648:     function balanceOf(address owner) public view virtual override returns (uint256) {

656:     function ownerOf(uint256 tokenId) public view virtual override returns (address) {

665:     function name() public view virtual override returns (string memory) {

672:     function symbol() public view virtual override returns (string memory) {

679:     function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

691:     function _baseURI() internal view virtual returns (string memory) {

698:     function approve(address to, uint256 tokenId) public virtual override {

713:     function getApproved(uint256 tokenId) public view virtual override returns (address) {

722:     function setApprovalForAll(address operator, bool approved) public virtual override {

732:     function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

810:     function _exists(uint256 tokenId) internal view virtual returns (bool) {

821:     function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

837:     function _safeMint(address to, uint256 tokenId) internal virtual {

869:     function _mint(address to, uint256 tokenId) internal virtual {

891:     function _burn(uint256 tokenId) internal virtual {

941:     function _approve(address to, uint256 tokenId) internal virtual {

1029:     function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {

1036:     function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {

1044:     function totalSupply() public view virtual override returns (uint256) {

1051:     function tokenByIndex(uint256 index) public view virtual override returns (uint256) {

1095:     function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

1105:     function _addTokenToAllTokensEnumeration(uint256 tokenId) private {

1118:     function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

1143:     function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

1194:     function owner() public view virtual returns (address) {

1213:     function renounceOwnership() public virtual onlyOwner {

1221:     function transferOwnership(address newOwner) public virtual onlyOwner {

1277:   function _baseURI() internal view virtual override returns (string memory) {

1282:   function vipSaleMint(uint256 _mintAmount) public {

1305:   function preSaleMint(uint256 _mintAmount) public payable {

1330:   function publicSaleMint(uint256 _mintAmount) public payable {

1355:   function isWhitelisted(address _user) public view returns (bool) {

1364:   function walletOfOwner(address _owner) public view returns (uint256[] memory)

1374:   function tokenURI(uint256 tokenId) public view virtual override returns (string memory)

1391:   function publicSaleIsActive() public view returns (bool) {

1395:   function preSaleIsActive() public view returns (bool) {

1399:   function vipSaleIsActive() public view returns (bool) {

1403:   function checkVIPMintAmount(address _account) public view returns (uint256) {

1413:   function setNftPerAddressLimit(uint256 _limit) public {

1423:   function setmaxMintAmount(uint256 _newmaxMintAmount) public {

1428:   function setcurrentPhaseMintMaxAmount(uint256 _newPhaseAmount) public {

1433:   function setPublicSaleStart(uint32 timestamp) public {

1438:   function setPreSaleStart(uint32 timestamp) public {

1443:   function setVIPSaleStart(uint32 timestamp) public {

1448:   function setBaseURI(string memory _newBaseURI) public {

1453:   function setBaseExtension(string memory _newBaseExtension) public {

1458:   function setNotRevealedURI(string memory _notRevealedURI) public {

1473:   function setVIPMintAmount(address[] memory _accounts, uint256[] memory _amounts) public {

1492:   function whitelistUsers(address[] calldata _users) public {

1504:   function addController(address controller) external onlyOwner {

1512:   function removeController(address controller) external onlyOwner {

```

### <a name="NC-11"></a>[NC-11] Change int to int256
Throughout the code base, some variables are declared as `int`. To favor explicitness, consider changing all instances of `int` to `int256`

*Instances (11)*:
```solidity
File: example/CarMan.sol

870:         require(to != address(0), "ERC721: mint to the zero address");

1283:     require(_mintAmount > 0, "Mint Amount should be bigger than 0");

1287:     require(_mintAmount > 0, "need to mint at least 1 NFT");

1288:     require(_mintAmount <= maxMintAmount, "max mint amount per session exceeded");

1296:     require(ownerMintedCount + _mintAmount <= vipMintCount, "max VIP Mint Amount exceeded");

1306:     require(_mintAmount > 0, "Mint Amount should be bigger than 0");

1310:     require(_mintAmount > 0, "need to mint at least 1 NFT");

1311:     require(_mintAmount <= maxMintAmount, "max mint amount per session exceeded");

1331:     require(_mintAmount > 0, "Mint Amount should be bigger than 0");

1335:     require(_mintAmount > 0, "need to mint at least 1 NFT");

1336:     require(_mintAmount <= maxMintAmount, "max mint amount per session exceeded");

```

### <a name="NC-12"></a>[NC-12] Change uint to uint256
Throughout the code base, some variables are declared as `uint`. To favor explicitness, consider changing all instances of `uint` to `uint256`

*Instances (1)*:
```solidity
File: example/CarMan.sol

1356:     for (uint i = 0; i < whitelistedAddresses.length; i++) {

```

### <a name="NC-13"></a>[NC-13] Interfaces should be defined in separate files from their usage
The interfaces below should be defined in separate files, so that it's easier for future projects to import them, and to avoid duplication later on if they need to be used elsewhere in the project

*Instances (5)*:
```solidity
File: example/CarMan.sol

40: pragma solidity ^0.8.0;

57:      */

198:      * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.

546: // File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol

567:     function onERC721Received(

```

### <a name="NC-14"></a>[NC-14] Lack of checks in setters
Be it sanity checks (like checks against `0`-values) or initial setting checks: it's best for Setter functions to have them

*Instances (16)*:
```solidity
File: example/CarMan.sol

164:      * - `tokenId` token must exist and be owned by `from`.

164:      * - `tokenId` token must exist and be owned by `from`.

164:      * - `tokenId` token must exist and be owned by `from`.

164:      * - `tokenId` token must exist and be owned by `from`.

164:      * - `tokenId` token must exist and be owned by `from`.

164:      * - `tokenId` token must exist and be owned by `from`.

164:      * - `tokenId` token must exist and be owned by `from`.

164:      * - `tokenId` token must exist and be owned by `from`.

1244:   uint256 public nftPerAddressLimit = 10;
        uint256 public currentPhaseMintMaxAmount = 110;
      
        uint32 public publicSaleStart = 1647136800;
        uint32 public preSaleStart = 1646964000;

1244:   uint256 public nftPerAddressLimit = 10;
        uint256 public currentPhaseMintMaxAmount = 110;
      
        uint32 public publicSaleStart = 1647136800;
        uint32 public preSaleStart = 1646964000;

1244:   uint256 public nftPerAddressLimit = 10;
        uint256 public currentPhaseMintMaxAmount = 110;
      
        uint32 public publicSaleStart = 1647136800;
        uint32 public preSaleStart = 1646964000;

1244:   uint256 public nftPerAddressLimit = 10;
        uint256 public currentPhaseMintMaxAmount = 110;
      
        uint32 public publicSaleStart = 1647136800;
        uint32 public preSaleStart = 1646964000;

1244:   uint256 public nftPerAddressLimit = 10;
        uint256 public currentPhaseMintMaxAmount = 110;
      
        uint32 public publicSaleStart = 1647136800;
        uint32 public preSaleStart = 1646964000;

1244:   uint256 public nftPerAddressLimit = 10;
        uint256 public currentPhaseMintMaxAmount = 110;
      
        uint32 public publicSaleStart = 1647136800;
        uint32 public preSaleStart = 1646964000;

1244:   uint256 public nftPerAddressLimit = 10;
        uint256 public currentPhaseMintMaxAmount = 110;
      
        uint32 public publicSaleStart = 1647136800;
        uint32 public preSaleStart = 1646964000;

1244:   uint256 public nftPerAddressLimit = 10;
        uint256 public currentPhaseMintMaxAmount = 110;
      
        uint32 public publicSaleStart = 1647136800;
        uint32 public preSaleStart = 1646964000;

```

### <a name="NC-15"></a>[NC-15] Missing Event for critical parameters change
Events help non-contract tools to track changes, and events prevent users from being surprised by changes.

*Instances (128)*:
```solidity
File: example/CarMan.sol

164:      * - `tokenId` token must exist and be owned by `from`.

164:      * - `tokenId` token must exist and be owned by `from`.

164:      * - `tokenId` token must exist and be owned by `from`.

164:      * - `tokenId` token must exist and be owned by `from`.

164:      * - `tokenId` token must exist and be owned by `from`.

164:      * - `tokenId` token must exist and be owned by `from`.

164:      * - `tokenId` token must exist and be owned by `from`.

164:      * - `tokenId` token must exist and be owned by `from`.

1426:   }
      
        function setcurrentPhaseMintMaxAmount(uint256 _newPhaseAmount) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1426:   }
      
        function setcurrentPhaseMintMaxAmount(uint256 _newPhaseAmount) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1426:   }
      
        function setcurrentPhaseMintMaxAmount(uint256 _newPhaseAmount) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1426:   }
      
        function setcurrentPhaseMintMaxAmount(uint256 _newPhaseAmount) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1426:   }
      
        function setcurrentPhaseMintMaxAmount(uint256 _newPhaseAmount) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1426:   }
      
        function setcurrentPhaseMintMaxAmount(uint256 _newPhaseAmount) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1426:   }
      
        function setcurrentPhaseMintMaxAmount(uint256 _newPhaseAmount) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1426:   }
      
        function setcurrentPhaseMintMaxAmount(uint256 _newPhaseAmount) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;
        }
      
        function setPublicSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;
        }
      
        function setPublicSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;
        }
      
        function setPublicSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;
        }
      
        function setPublicSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;
        }
      
        function setPublicSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;
        }
      
        function setPublicSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;
        }
      
        function setPublicSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;
        }
      
        function setPublicSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1434:     require(controllers[msg.sender], "Only controllers can operate this function");
          publicSaleStart = timestamp;
        }
        
        function setPreSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1434:     require(controllers[msg.sender], "Only controllers can operate this function");
          publicSaleStart = timestamp;
        }
        
        function setPreSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1434:     require(controllers[msg.sender], "Only controllers can operate this function");
          publicSaleStart = timestamp;
        }
        
        function setPreSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1434:     require(controllers[msg.sender], "Only controllers can operate this function");
          publicSaleStart = timestamp;
        }
        
        function setPreSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1434:     require(controllers[msg.sender], "Only controllers can operate this function");
          publicSaleStart = timestamp;
        }
        
        function setPreSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1434:     require(controllers[msg.sender], "Only controllers can operate this function");
          publicSaleStart = timestamp;
        }
        
        function setPreSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1434:     require(controllers[msg.sender], "Only controllers can operate this function");
          publicSaleStart = timestamp;
        }
        
        function setPreSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1434:     require(controllers[msg.sender], "Only controllers can operate this function");
          publicSaleStart = timestamp;
        }
        
        function setPreSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");
          preSaleStart = timestamp;
        } 
      
        function setVIPSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");
          preSaleStart = timestamp;
        } 
      
        function setVIPSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");
          preSaleStart = timestamp;
        } 
      
        function setVIPSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");
          preSaleStart = timestamp;
        } 
      
        function setVIPSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");
          preSaleStart = timestamp;
        } 
      
        function setVIPSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");
          preSaleStart = timestamp;
        } 
      
        function setVIPSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");
          preSaleStart = timestamp;
        } 
      
        function setVIPSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");
          preSaleStart = timestamp;
        } 
      
        function setVIPSaleStart(uint32 timestamp) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1447: 
        function setBaseURI(string memory _newBaseURI) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1447: 
        function setBaseURI(string memory _newBaseURI) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1447: 
        function setBaseURI(string memory _newBaseURI) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1447: 
        function setBaseURI(string memory _newBaseURI) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1447: 
        function setBaseURI(string memory _newBaseURI) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1447: 
        function setBaseURI(string memory _newBaseURI) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1447: 
        function setBaseURI(string memory _newBaseURI) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1447: 
        function setBaseURI(string memory _newBaseURI) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1453:   function setBaseExtension(string memory _newBaseExtension) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1453:   function setBaseExtension(string memory _newBaseExtension) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1453:   function setBaseExtension(string memory _newBaseExtension) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1453:   function setBaseExtension(string memory _newBaseExtension) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1453:   function setBaseExtension(string memory _newBaseExtension) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1453:   function setBaseExtension(string memory _newBaseExtension) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1453:   function setBaseExtension(string memory _newBaseExtension) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1453:   function setBaseExtension(string memory _newBaseExtension) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1455:     baseExtension = _newBaseExtension;
        }
        
        function setNotRevealedURI(string memory _notRevealedURI) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1455:     baseExtension = _newBaseExtension;
        }
        
        function setNotRevealedURI(string memory _notRevealedURI) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1455:     baseExtension = _newBaseExtension;
        }
        
        function setNotRevealedURI(string memory _notRevealedURI) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1455:     baseExtension = _newBaseExtension;
        }
        
        function setNotRevealedURI(string memory _notRevealedURI) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1455:     baseExtension = _newBaseExtension;
        }
        
        function setNotRevealedURI(string memory _notRevealedURI) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1455:     baseExtension = _newBaseExtension;
        }
        
        function setNotRevealedURI(string memory _notRevealedURI) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1455:     baseExtension = _newBaseExtension;
        }
        
        function setNotRevealedURI(string memory _notRevealedURI) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1455:     baseExtension = _newBaseExtension;
        }
        
        function setNotRevealedURI(string memory _notRevealedURI) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1460:     notRevealedUri = _notRevealedURI;
        }
      
        function setPreSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1460:     notRevealedUri = _notRevealedURI;
        }
      
        function setPreSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1460:     notRevealedUri = _notRevealedURI;
        }
      
        function setPreSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1460:     notRevealedUri = _notRevealedURI;
        }
      
        function setPreSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1460:     notRevealedUri = _notRevealedURI;
        }
      
        function setPreSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1460:     notRevealedUri = _notRevealedURI;
        }
      
        function setPreSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1460:     notRevealedUri = _notRevealedURI;
        }
      
        function setPreSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1460:     notRevealedUri = _notRevealedURI;
        }
      
        function setPreSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1465:     preSalePaused = _state;
        }
      
        function setVIPSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1465:     preSalePaused = _state;
        }
      
        function setVIPSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1465:     preSalePaused = _state;
        }
      
        function setVIPSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1465:     preSalePaused = _state;
        }
      
        function setVIPSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1465:     preSalePaused = _state;
        }
      
        function setVIPSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1465:     preSalePaused = _state;
        }
      
        function setVIPSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1465:     preSalePaused = _state;
        }
      
        function setVIPSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1465:     preSalePaused = _state;
        }
      
        function setVIPSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1472: 
        function setVIPMintAmount(address[] memory _accounts, uint256[] memory _amounts) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1472: 
        function setVIPMintAmount(address[] memory _accounts, uint256[] memory _amounts) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1472: 
        function setVIPMintAmount(address[] memory _accounts, uint256[] memory _amounts) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1472: 
        function setVIPMintAmount(address[] memory _accounts, uint256[] memory _amounts) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1472: 
        function setVIPMintAmount(address[] memory _accounts, uint256[] memory _amounts) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1472: 
        function setVIPMintAmount(address[] memory _accounts, uint256[] memory _amounts) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1472: 
        function setVIPMintAmount(address[] memory _accounts, uint256[] memory _amounts) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1472: 
        function setVIPMintAmount(address[] memory _accounts, uint256[] memory _amounts) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");
      
          for (uint256 i = 0; i < _accounts.length; ++i) {
            vipMintAmount[_accounts[i]]=_amounts[i];

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");
      
          for (uint256 i = 0; i < _accounts.length; ++i) {
            vipMintAmount[_accounts[i]]=_amounts[i];

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");
      
          for (uint256 i = 0; i < _accounts.length; ++i) {
            vipMintAmount[_accounts[i]]=_amounts[i];

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");
      
          for (uint256 i = 0; i < _accounts.length; ++i) {
            vipMintAmount[_accounts[i]]=_amounts[i];

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");
      
          for (uint256 i = 0; i < _accounts.length; ++i) {
            vipMintAmount[_accounts[i]]=_amounts[i];

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");
      
          for (uint256 i = 0; i < _accounts.length; ++i) {
            vipMintAmount[_accounts[i]]=_amounts[i];

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");
      
          for (uint256 i = 0; i < _accounts.length; ++i) {
            vipMintAmount[_accounts[i]]=_amounts[i];

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");
      
          for (uint256 i = 0; i < _accounts.length; ++i) {
            vipMintAmount[_accounts[i]]=_amounts[i];

1478:       vipMintAmount[_accounts[i]]=_amounts[i];
          }
        }
      
        function setPublicSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1478:       vipMintAmount[_accounts[i]]=_amounts[i];
          }
        }
      
        function setPublicSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1478:       vipMintAmount[_accounts[i]]=_amounts[i];
          }
        }
      
        function setPublicSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1478:       vipMintAmount[_accounts[i]]=_amounts[i];
          }
        }
      
        function setPublicSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1478:       vipMintAmount[_accounts[i]]=_amounts[i];
          }
        }
      
        function setPublicSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1478:       vipMintAmount[_accounts[i]]=_amounts[i];
          }
        }
      
        function setPublicSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1478:       vipMintAmount[_accounts[i]]=_amounts[i];
          }
        }
      
        function setPublicSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1478:       vipMintAmount[_accounts[i]]=_amounts[i];
          }
        }
      
        function setPublicSalePause(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1484:     publicSalePaused = _state;
        }
        
        function setOnlyWhitelisted(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");
          onlyWhitelisted = _state;
        }
        
        function whitelistUsers(address[] calldata _users) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1484:     publicSalePaused = _state;
        }
        
        function setOnlyWhitelisted(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");
          onlyWhitelisted = _state;
        }
        
        function whitelistUsers(address[] calldata _users) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1484:     publicSalePaused = _state;
        }
        
        function setOnlyWhitelisted(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");
          onlyWhitelisted = _state;
        }
        
        function whitelistUsers(address[] calldata _users) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1484:     publicSalePaused = _state;
        }
        
        function setOnlyWhitelisted(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");
          onlyWhitelisted = _state;
        }
        
        function whitelistUsers(address[] calldata _users) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1484:     publicSalePaused = _state;
        }
        
        function setOnlyWhitelisted(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");
          onlyWhitelisted = _state;
        }
        
        function whitelistUsers(address[] calldata _users) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1484:     publicSalePaused = _state;
        }
        
        function setOnlyWhitelisted(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");
          onlyWhitelisted = _state;
        }
        
        function whitelistUsers(address[] calldata _users) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1484:     publicSalePaused = _state;
        }
        
        function setOnlyWhitelisted(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");
          onlyWhitelisted = _state;
        }
        
        function whitelistUsers(address[] calldata _users) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1484:     publicSalePaused = _state;
        }
        
        function setOnlyWhitelisted(bool _state) public {
          require(controllers[msg.sender], "Only controllers can operate this function");
          onlyWhitelisted = _state;
        }
        
        function whitelistUsers(address[] calldata _users) public {
          require(controllers[msg.sender], "Only controllers can operate this function");

1495:     whitelistedAddresses = _users;
        }
      
        //only owner
       
         /**
         * enables an address for management
         * @param controller the address to enable

1495:     whitelistedAddresses = _users;
        }
      
        //only owner
       
         /**
         * enables an address for management
         * @param controller the address to enable

1495:     whitelistedAddresses = _users;
        }
      
        //only owner
       
         /**
         * enables an address for management
         * @param controller the address to enable

1495:     whitelistedAddresses = _users;
        }
      
        //only owner
       
         /**
         * enables an address for management
         * @param controller the address to enable

1495:     whitelistedAddresses = _users;
        }
      
        //only owner
       
         /**
         * enables an address for management
         * @param controller the address to enable

1495:     whitelistedAddresses = _users;
        }
      
        //only owner
       
         /**
         * enables an address for management
         * @param controller the address to enable

1495:     whitelistedAddresses = _users;
        }
      
        //only owner
       
         /**
         * enables an address for management
         * @param controller the address to enable

1495:     whitelistedAddresses = _users;
        }
      
        //only owner
       
         /**
         * enables an address for management
         * @param controller the address to enable

1504:   function addController(address controller) external onlyOwner {
          controllers[controller] = true;
        }
      
        /**
         * disables an address for management

1504:   function addController(address controller) external onlyOwner {
          controllers[controller] = true;
        }
      
        /**
         * disables an address for management

1504:   function addController(address controller) external onlyOwner {
          controllers[controller] = true;
        }
      
        /**
         * disables an address for management

1504:   function addController(address controller) external onlyOwner {
          controllers[controller] = true;
        }
      
        /**
         * disables an address for management

1504:   function addController(address controller) external onlyOwner {
          controllers[controller] = true;
        }
      
        /**
         * disables an address for management

1504:   function addController(address controller) external onlyOwner {
          controllers[controller] = true;
        }
      
        /**
         * disables an address for management

1504:   function addController(address controller) external onlyOwner {
          controllers[controller] = true;
        }
      
        /**
         * disables an address for management

1504:   function addController(address controller) external onlyOwner {
          controllers[controller] = true;
        }
      
        /**
         * disables an address for management

```

### <a name="NC-16"></a>[NC-16] NatSpec is completely non-existent on functions that should have them
Public and external functions that aren't view or pure should have NatSpec comments

*Instances (168)*:
```solidity
File: example/CarMan.sol

1290:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1290:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1290:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1290:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1290:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1290:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1290:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1290:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1313:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1313:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1313:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1313:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1313:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1313:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1313:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1313:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1338:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1338:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1338:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1338:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1338:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1338:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1338:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1338:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1423:   function setmaxMintAmount(uint256 _newmaxMintAmount) public {

1423:   function setmaxMintAmount(uint256 _newmaxMintAmount) public {

1423:   function setmaxMintAmount(uint256 _newmaxMintAmount) public {

1423:   function setmaxMintAmount(uint256 _newmaxMintAmount) public {

1423:   function setmaxMintAmount(uint256 _newmaxMintAmount) public {

1423:   function setmaxMintAmount(uint256 _newmaxMintAmount) public {

1423:   function setmaxMintAmount(uint256 _newmaxMintAmount) public {

1423:   function setmaxMintAmount(uint256 _newmaxMintAmount) public {

1426:   }

1426:   }

1426:   }

1426:   }

1426:   }

1426:   }

1426:   }

1426:   }

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;

1434:     require(controllers[msg.sender], "Only controllers can operate this function");

1434:     require(controllers[msg.sender], "Only controllers can operate this function");

1434:     require(controllers[msg.sender], "Only controllers can operate this function");

1434:     require(controllers[msg.sender], "Only controllers can operate this function");

1434:     require(controllers[msg.sender], "Only controllers can operate this function");

1434:     require(controllers[msg.sender], "Only controllers can operate this function");

1434:     require(controllers[msg.sender], "Only controllers can operate this function");

1434:     require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");

1447: 

1447: 

1447: 

1447: 

1447: 

1447: 

1447: 

1447: 

1453:   function setBaseExtension(string memory _newBaseExtension) public {

1453:   function setBaseExtension(string memory _newBaseExtension) public {

1453:   function setBaseExtension(string memory _newBaseExtension) public {

1453:   function setBaseExtension(string memory _newBaseExtension) public {

1453:   function setBaseExtension(string memory _newBaseExtension) public {

1453:   function setBaseExtension(string memory _newBaseExtension) public {

1453:   function setBaseExtension(string memory _newBaseExtension) public {

1453:   function setBaseExtension(string memory _newBaseExtension) public {

1455:     baseExtension = _newBaseExtension;

1455:     baseExtension = _newBaseExtension;

1455:     baseExtension = _newBaseExtension;

1455:     baseExtension = _newBaseExtension;

1455:     baseExtension = _newBaseExtension;

1455:     baseExtension = _newBaseExtension;

1455:     baseExtension = _newBaseExtension;

1455:     baseExtension = _newBaseExtension;

1460:     notRevealedUri = _notRevealedURI;

1460:     notRevealedUri = _notRevealedURI;

1460:     notRevealedUri = _notRevealedURI;

1460:     notRevealedUri = _notRevealedURI;

1460:     notRevealedUri = _notRevealedURI;

1460:     notRevealedUri = _notRevealedURI;

1460:     notRevealedUri = _notRevealedURI;

1460:     notRevealedUri = _notRevealedURI;

1465:     preSalePaused = _state;

1465:     preSalePaused = _state;

1465:     preSalePaused = _state;

1465:     preSalePaused = _state;

1465:     preSalePaused = _state;

1465:     preSalePaused = _state;

1465:     preSalePaused = _state;

1465:     preSalePaused = _state;

1472: 

1472: 

1472: 

1472: 

1472: 

1472: 

1472: 

1472: 

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");

1478:       vipMintAmount[_accounts[i]]=_amounts[i];

1478:       vipMintAmount[_accounts[i]]=_amounts[i];

1478:       vipMintAmount[_accounts[i]]=_amounts[i];

1478:       vipMintAmount[_accounts[i]]=_amounts[i];

1478:       vipMintAmount[_accounts[i]]=_amounts[i];

1478:       vipMintAmount[_accounts[i]]=_amounts[i];

1478:       vipMintAmount[_accounts[i]]=_amounts[i];

1478:       vipMintAmount[_accounts[i]]=_amounts[i];

1484:     publicSalePaused = _state;

1484:     publicSalePaused = _state;

1484:     publicSalePaused = _state;

1484:     publicSalePaused = _state;

1484:     publicSalePaused = _state;

1484:     publicSalePaused = _state;

1484:     publicSalePaused = _state;

1484:     publicSalePaused = _state;

1495:     whitelistedAddresses = _users;

1495:     whitelistedAddresses = _users;

1495:     whitelistedAddresses = _users;

1495:     whitelistedAddresses = _users;

1495:     whitelistedAddresses = _users;

1495:     whitelistedAddresses = _users;

1495:     whitelistedAddresses = _users;

1495:     whitelistedAddresses = _users;

1504:   function addController(address controller) external onlyOwner {

1504:   function addController(address controller) external onlyOwner {

1504:   function addController(address controller) external onlyOwner {

1504:   function addController(address controller) external onlyOwner {

1504:   function addController(address controller) external onlyOwner {

1504:   function addController(address controller) external onlyOwner {

1504:   function addController(address controller) external onlyOwner {

1504:   function addController(address controller) external onlyOwner {

1510:    * @param controller the address to disbale

1510:    * @param controller the address to disbale

1510:    * @param controller the address to disbale

1510:    * @param controller the address to disbale

1510:    * @param controller the address to disbale

1510:    * @param controller the address to disbale

1510:    * @param controller the address to disbale

1510:    * @param controller the address to disbale

1520: }

1520: }

1520: }

1520: }

1520: }

1520: }

1520: }

1520: }

```

### <a name="NC-17"></a>[NC-17] Incomplete NatSpec: `@param` is missing on actually documented functions
The following functions are missing `@param` NatSpec comments.

*Instances (48)*:
```solidity
File: example/CarMan.sol

84:      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
         *
         * Emits a {Transfer} event.
         */
        function safeTransferFrom(
            address from,
            address to,
            uint256 tokenId
        ) external;
    
        /**
         * @dev Transfers `tokenId` token from `from` to `to`.
         *
         * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
         *
         * Requirements:
         *
         * - `from` cannot be the zero address.
         * - `to` cannot be the zero address.
         * - `tokenId` token must be owned by `from`.
         * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
         *
         * Emits a {Transfer} event.

84:      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
         *
         * Emits a {Transfer} event.
         */
        function safeTransferFrom(
            address from,
            address to,
            uint256 tokenId
        ) external;
    
        /**
         * @dev Transfers `tokenId` token from `from` to `to`.
         *
         * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
         *
         * Requirements:
         *
         * - `from` cannot be the zero address.
         * - `to` cannot be the zero address.
         * - `tokenId` token must be owned by `from`.
         * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
         *
         * Emits a {Transfer} event.

84:      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
         *
         * Emits a {Transfer} event.
         */
        function safeTransferFrom(
            address from,
            address to,
            uint256 tokenId
        ) external;
    
        /**
         * @dev Transfers `tokenId` token from `from` to `to`.
         *
         * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
         *
         * Requirements:
         *
         * - `from` cannot be the zero address.
         * - `to` cannot be the zero address.
         * - `tokenId` token must be owned by `from`.
         * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
         *
         * Emits a {Transfer} event.

84:      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
         *
         * Emits a {Transfer} event.
         */
        function safeTransferFrom(
            address from,
            address to,
            uint256 tokenId
        ) external;
    
        /**
         * @dev Transfers `tokenId` token from `from` to `to`.
         *
         * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
         *
         * Requirements:
         *
         * - `from` cannot be the zero address.
         * - `to` cannot be the zero address.
         * - `tokenId` token must be owned by `from`.
         * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
         *
         * Emits a {Transfer} event.

84:      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
         *
         * Emits a {Transfer} event.
         */
        function safeTransferFrom(
            address from,
            address to,
            uint256 tokenId
        ) external;
    
        /**
         * @dev Transfers `tokenId` token from `from` to `to`.
         *
         * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
         *
         * Requirements:
         *
         * - `from` cannot be the zero address.
         * - `to` cannot be the zero address.
         * - `tokenId` token must be owned by `from`.
         * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
         *
         * Emits a {Transfer} event.

84:      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
         *
         * Emits a {Transfer} event.
         */
        function safeTransferFrom(
            address from,
            address to,
            uint256 tokenId
        ) external;
    
        /**
         * @dev Transfers `tokenId` token from `from` to `to`.
         *
         * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
         *
         * Requirements:
         *
         * - `from` cannot be the zero address.
         * - `to` cannot be the zero address.
         * - `tokenId` token must be owned by `from`.
         * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
         *
         * Emits a {Transfer} event.

84:      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
         *
         * Emits a {Transfer} event.
         */
        function safeTransferFrom(
            address from,
            address to,
            uint256 tokenId
        ) external;
    
        /**
         * @dev Transfers `tokenId` token from `from` to `to`.
         *
         * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
         *
         * Requirements:
         *
         * - `from` cannot be the zero address.
         * - `to` cannot be the zero address.
         * - `tokenId` token must be owned by `from`.
         * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
         *
         * Emits a {Transfer} event.

84:      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
         *
         * Emits a {Transfer} event.
         */
        function safeTransferFrom(
            address from,
            address to,
            uint256 tokenId
        ) external;
    
        /**
         * @dev Transfers `tokenId` token from `from` to `to`.
         *
         * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
         *
         * Requirements:
         *
         * - `from` cannot be the zero address.
         * - `to` cannot be the zero address.
         * - `tokenId` token must be owned by `from`.
         * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
         *
         * Emits a {Transfer} event.

108:     function transferFrom(
             address from,
             address to,
             uint256 tokenId
         ) external;
     
         /**
          * @dev Gives permission to `to` to transfer `tokenId` token to another account.
          * The approval is cleared when the token is transferred.
          *
          * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
          *
          * Requirements:
          *
          * - The caller must own the token or be an approved operator.
          * - `tokenId` must exist.
          *
          * Emits an {Approval} event.
          */
         function approve(address to, uint256 tokenId) external;

108:     function transferFrom(
             address from,
             address to,
             uint256 tokenId
         ) external;
     
         /**
          * @dev Gives permission to `to` to transfer `tokenId` token to another account.
          * The approval is cleared when the token is transferred.
          *
          * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
          *
          * Requirements:
          *
          * - The caller must own the token or be an approved operator.
          * - `tokenId` must exist.
          *
          * Emits an {Approval} event.
          */
         function approve(address to, uint256 tokenId) external;

108:     function transferFrom(
             address from,
             address to,
             uint256 tokenId
         ) external;
     
         /**
          * @dev Gives permission to `to` to transfer `tokenId` token to another account.
          * The approval is cleared when the token is transferred.
          *
          * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
          *
          * Requirements:
          *
          * - The caller must own the token or be an approved operator.
          * - `tokenId` must exist.
          *
          * Emits an {Approval} event.
          */
         function approve(address to, uint256 tokenId) external;

108:     function transferFrom(
             address from,
             address to,
             uint256 tokenId
         ) external;
     
         /**
          * @dev Gives permission to `to` to transfer `tokenId` token to another account.
          * The approval is cleared when the token is transferred.
          *
          * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
          *
          * Requirements:
          *
          * - The caller must own the token or be an approved operator.
          * - `tokenId` must exist.
          *
          * Emits an {Approval} event.
          */
         function approve(address to, uint256 tokenId) external;

108:     function transferFrom(
             address from,
             address to,
             uint256 tokenId
         ) external;
     
         /**
          * @dev Gives permission to `to` to transfer `tokenId` token to another account.
          * The approval is cleared when the token is transferred.
          *
          * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
          *
          * Requirements:
          *
          * - The caller must own the token or be an approved operator.
          * - `tokenId` must exist.
          *
          * Emits an {Approval} event.
          */
         function approve(address to, uint256 tokenId) external;

108:     function transferFrom(
             address from,
             address to,
             uint256 tokenId
         ) external;
     
         /**
          * @dev Gives permission to `to` to transfer `tokenId` token to another account.
          * The approval is cleared when the token is transferred.
          *
          * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
          *
          * Requirements:
          *
          * - The caller must own the token or be an approved operator.
          * - `tokenId` must exist.
          *
          * Emits an {Approval} event.
          */
         function approve(address to, uint256 tokenId) external;

108:     function transferFrom(
             address from,
             address to,
             uint256 tokenId
         ) external;
     
         /**
          * @dev Gives permission to `to` to transfer `tokenId` token to another account.
          * The approval is cleared when the token is transferred.
          *
          * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
          *
          * Requirements:
          *
          * - The caller must own the token or be an approved operator.
          * - `tokenId` must exist.
          *
          * Emits an {Approval} event.
          */
         function approve(address to, uint256 tokenId) external;

108:     function transferFrom(
             address from,
             address to,
             uint256 tokenId
         ) external;
     
         /**
          * @dev Gives permission to `to` to transfer `tokenId` token to another account.
          * The approval is cleared when the token is transferred.
          *
          * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
          *
          * Requirements:
          *
          * - The caller must own the token or be an approved operator.
          * - `tokenId` must exist.
          *
          * Emits an {Approval} event.
          */
         function approve(address to, uint256 tokenId) external;

130:      * @dev Returns the account approved for `tokenId` token.
          *
          * Requirements:
          *
          * - `tokenId` must exist.
          */
         function getApproved(uint256 tokenId) external view returns (address operator);
     
         /**
          * @dev Approve or remove `operator` as an operator for the caller.
          * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
          *
          * Requirements:
          *
          * - The `operator` cannot be the caller.
          *

130:      * @dev Returns the account approved for `tokenId` token.
          *
          * Requirements:
          *
          * - `tokenId` must exist.
          */
         function getApproved(uint256 tokenId) external view returns (address operator);
     
         /**
          * @dev Approve or remove `operator` as an operator for the caller.
          * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
          *
          * Requirements:
          *
          * - The `operator` cannot be the caller.
          *

130:      * @dev Returns the account approved for `tokenId` token.
          *
          * Requirements:
          *
          * - `tokenId` must exist.
          */
         function getApproved(uint256 tokenId) external view returns (address operator);
     
         /**
          * @dev Approve or remove `operator` as an operator for the caller.
          * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
          *
          * Requirements:
          *
          * - The `operator` cannot be the caller.
          *

130:      * @dev Returns the account approved for `tokenId` token.
          *
          * Requirements:
          *
          * - `tokenId` must exist.
          */
         function getApproved(uint256 tokenId) external view returns (address operator);
     
         /**
          * @dev Approve or remove `operator` as an operator for the caller.
          * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
          *
          * Requirements:
          *
          * - The `operator` cannot be the caller.
          *

130:      * @dev Returns the account approved for `tokenId` token.
          *
          * Requirements:
          *
          * - `tokenId` must exist.
          */
         function getApproved(uint256 tokenId) external view returns (address operator);
     
         /**
          * @dev Approve or remove `operator` as an operator for the caller.
          * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
          *
          * Requirements:
          *
          * - The `operator` cannot be the caller.
          *

130:      * @dev Returns the account approved for `tokenId` token.
          *
          * Requirements:
          *
          * - `tokenId` must exist.
          */
         function getApproved(uint256 tokenId) external view returns (address operator);
     
         /**
          * @dev Approve or remove `operator` as an operator for the caller.
          * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
          *
          * Requirements:
          *
          * - The `operator` cannot be the caller.
          *

130:      * @dev Returns the account approved for `tokenId` token.
          *
          * Requirements:
          *
          * - `tokenId` must exist.
          */
         function getApproved(uint256 tokenId) external view returns (address operator);
     
         /**
          * @dev Approve or remove `operator` as an operator for the caller.
          * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
          *
          * Requirements:
          *
          * - The `operator` cannot be the caller.
          *

130:      * @dev Returns the account approved for `tokenId` token.
          *
          * Requirements:
          *
          * - `tokenId` must exist.
          */
         function getApproved(uint256 tokenId) external view returns (address operator);
     
         /**
          * @dev Approve or remove `operator` as an operator for the caller.
          * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
          *
          * Requirements:
          *
          * - The `operator` cannot be the caller.
          *

154:      */
         function isApprovedForAll(address owner, address operator) external view returns (bool);
     
         /**
          * @dev Safely transfers `tokenId` token from `from` to `to`.
          *
          * Requirements:
          *
          * - `from` cannot be the zero address.
          * - `to` cannot be the zero address.
          * - `tokenId` token must exist and be owned by `from`.
          * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.

154:      */
         function isApprovedForAll(address owner, address operator) external view returns (bool);
     
         /**
          * @dev Safely transfers `tokenId` token from `from` to `to`.
          *
          * Requirements:
          *
          * - `from` cannot be the zero address.
          * - `to` cannot be the zero address.
          * - `tokenId` token must exist and be owned by `from`.
          * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.

154:      */
         function isApprovedForAll(address owner, address operator) external view returns (bool);
     
         /**
          * @dev Safely transfers `tokenId` token from `from` to `to`.
          *
          * Requirements:
          *
          * - `from` cannot be the zero address.
          * - `to` cannot be the zero address.
          * - `tokenId` token must exist and be owned by `from`.
          * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.

154:      */
         function isApprovedForAll(address owner, address operator) external view returns (bool);
     
         /**
          * @dev Safely transfers `tokenId` token from `from` to `to`.
          *
          * Requirements:
          *
          * - `from` cannot be the zero address.
          * - `to` cannot be the zero address.
          * - `tokenId` token must exist and be owned by `from`.
          * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.

154:      */
         function isApprovedForAll(address owner, address operator) external view returns (bool);
     
         /**
          * @dev Safely transfers `tokenId` token from `from` to `to`.
          *
          * Requirements:
          *
          * - `from` cannot be the zero address.
          * - `to` cannot be the zero address.
          * - `tokenId` token must exist and be owned by `from`.
          * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.

154:      */
         function isApprovedForAll(address owner, address operator) external view returns (bool);
     
         /**
          * @dev Safely transfers `tokenId` token from `from` to `to`.
          *
          * Requirements:
          *
          * - `from` cannot be the zero address.
          * - `to` cannot be the zero address.
          * - `tokenId` token must exist and be owned by `from`.
          * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.

154:      */
         function isApprovedForAll(address owner, address operator) external view returns (bool);
     
         /**
          * @dev Safely transfers `tokenId` token from `from` to `to`.
          *
          * Requirements:
          *
          * - `from` cannot be the zero address.
          * - `to` cannot be the zero address.
          * - `tokenId` token must exist and be owned by `from`.
          * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.

154:      */
         function isApprovedForAll(address owner, address operator) external view returns (bool);
     
         /**
          * @dev Safely transfers `tokenId` token from `from` to `to`.
          *
          * Requirements:
          *
          * - `from` cannot be the zero address.
          * - `to` cannot be the zero address.
          * - `tokenId` token must exist and be owned by `from`.
          * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.

168:      * Emits a {Transfer} event.
          */
         function safeTransferFrom(
             address from,
             address to,
             uint256 tokenId,
             bytes calldata data
         ) external;
     }
     
     
     // File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol
     pragma solidity ^0.8.0;
     /**
      * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
      * @dev See https://eips.ethereum.org/EIPS/eip-721
      */
     interface IERC721Enumerable is IERC721 {
         /**
          * @dev Returns the total amount of tokens stored by the contract.
          */
         function totalSupply() external view returns (uint256);
     
         /**
          * @dev Returns a token ID owned by `owner` at a given `index` of its token list.

168:      * Emits a {Transfer} event.
          */
         function safeTransferFrom(
             address from,
             address to,
             uint256 tokenId,
             bytes calldata data
         ) external;
     }
     
     
     // File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol
     pragma solidity ^0.8.0;
     /**
      * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
      * @dev See https://eips.ethereum.org/EIPS/eip-721
      */
     interface IERC721Enumerable is IERC721 {
         /**
          * @dev Returns the total amount of tokens stored by the contract.
          */
         function totalSupply() external view returns (uint256);
     
         /**
          * @dev Returns a token ID owned by `owner` at a given `index` of its token list.

168:      * Emits a {Transfer} event.
          */
         function safeTransferFrom(
             address from,
             address to,
             uint256 tokenId,
             bytes calldata data
         ) external;
     }
     
     
     // File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol
     pragma solidity ^0.8.0;
     /**
      * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
      * @dev See https://eips.ethereum.org/EIPS/eip-721
      */
     interface IERC721Enumerable is IERC721 {
         /**
          * @dev Returns the total amount of tokens stored by the contract.
          */
         function totalSupply() external view returns (uint256);
     
         /**
          * @dev Returns a token ID owned by `owner` at a given `index` of its token list.

168:      * Emits a {Transfer} event.
          */
         function safeTransferFrom(
             address from,
             address to,
             uint256 tokenId,
             bytes calldata data
         ) external;
     }
     
     
     // File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol
     pragma solidity ^0.8.0;
     /**
      * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
      * @dev See https://eips.ethereum.org/EIPS/eip-721
      */
     interface IERC721Enumerable is IERC721 {
         /**
          * @dev Returns the total amount of tokens stored by the contract.
          */
         function totalSupply() external view returns (uint256);
     
         /**
          * @dev Returns a token ID owned by `owner` at a given `index` of its token list.

168:      * Emits a {Transfer} event.
          */
         function safeTransferFrom(
             address from,
             address to,
             uint256 tokenId,
             bytes calldata data
         ) external;
     }
     
     
     // File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol
     pragma solidity ^0.8.0;
     /**
      * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
      * @dev See https://eips.ethereum.org/EIPS/eip-721
      */
     interface IERC721Enumerable is IERC721 {
         /**
          * @dev Returns the total amount of tokens stored by the contract.
          */
         function totalSupply() external view returns (uint256);
     
         /**
          * @dev Returns a token ID owned by `owner` at a given `index` of its token list.

168:      * Emits a {Transfer} event.
          */
         function safeTransferFrom(
             address from,
             address to,
             uint256 tokenId,
             bytes calldata data
         ) external;
     }
     
     
     // File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol
     pragma solidity ^0.8.0;
     /**
      * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
      * @dev See https://eips.ethereum.org/EIPS/eip-721
      */
     interface IERC721Enumerable is IERC721 {
         /**
          * @dev Returns the total amount of tokens stored by the contract.
          */
         function totalSupply() external view returns (uint256);
     
         /**
          * @dev Returns a token ID owned by `owner` at a given `index` of its token list.

168:      * Emits a {Transfer} event.
          */
         function safeTransferFrom(
             address from,
             address to,
             uint256 tokenId,
             bytes calldata data
         ) external;
     }
     
     
     // File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol
     pragma solidity ^0.8.0;
     /**
      * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
      * @dev See https://eips.ethereum.org/EIPS/eip-721
      */
     interface IERC721Enumerable is IERC721 {
         /**
          * @dev Returns the total amount of tokens stored by the contract.
          */
         function totalSupply() external view returns (uint256);
     
         /**
          * @dev Returns a token ID owned by `owner` at a given `index` of its token list.

168:      * Emits a {Transfer} event.
          */
         function safeTransferFrom(
             address from,
             address to,
             uint256 tokenId,
             bytes calldata data
         ) external;
     }
     
     
     // File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol
     pragma solidity ^0.8.0;
     /**
      * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
      * @dev See https://eips.ethereum.org/EIPS/eip-721
      */
     interface IERC721Enumerable is IERC721 {
         /**
          * @dev Returns the total amount of tokens stored by the contract.
          */
         function totalSupply() external view returns (uint256);
     
         /**
          * @dev Returns a token ID owned by `owner` at a given `index` of its token list.

568:         address operator,
             address from,
             uint256 tokenId,
             bytes calldata data
         ) external returns (bytes4);
     }
     
     // File: @openzeppelin/contracts/utils/Context.sol
     pragma solidity ^0.8.0;
     /**
      * @dev Provides information about the current execution context, including the
      * sender of the transaction and its data. While these are generally available
      * via msg.sender and msg.data, they should not be accessed in such a direct
      * manner, since when dealing with meta-transactions the account sending and
      * paying for execution may not be the actual sender (as far as an application
      * is concerned).

568:         address operator,
             address from,
             uint256 tokenId,
             bytes calldata data
         ) external returns (bytes4);
     }
     
     // File: @openzeppelin/contracts/utils/Context.sol
     pragma solidity ^0.8.0;
     /**
      * @dev Provides information about the current execution context, including the
      * sender of the transaction and its data. While these are generally available
      * via msg.sender and msg.data, they should not be accessed in such a direct
      * manner, since when dealing with meta-transactions the account sending and
      * paying for execution may not be the actual sender (as far as an application
      * is concerned).

568:         address operator,
             address from,
             uint256 tokenId,
             bytes calldata data
         ) external returns (bytes4);
     }
     
     // File: @openzeppelin/contracts/utils/Context.sol
     pragma solidity ^0.8.0;
     /**
      * @dev Provides information about the current execution context, including the
      * sender of the transaction and its data. While these are generally available
      * via msg.sender and msg.data, they should not be accessed in such a direct
      * manner, since when dealing with meta-transactions the account sending and
      * paying for execution may not be the actual sender (as far as an application
      * is concerned).

568:         address operator,
             address from,
             uint256 tokenId,
             bytes calldata data
         ) external returns (bytes4);
     }
     
     // File: @openzeppelin/contracts/utils/Context.sol
     pragma solidity ^0.8.0;
     /**
      * @dev Provides information about the current execution context, including the
      * sender of the transaction and its data. While these are generally available
      * via msg.sender and msg.data, they should not be accessed in such a direct
      * manner, since when dealing with meta-transactions the account sending and
      * paying for execution may not be the actual sender (as far as an application
      * is concerned).

568:         address operator,
             address from,
             uint256 tokenId,
             bytes calldata data
         ) external returns (bytes4);
     }
     
     // File: @openzeppelin/contracts/utils/Context.sol
     pragma solidity ^0.8.0;
     /**
      * @dev Provides information about the current execution context, including the
      * sender of the transaction and its data. While these are generally available
      * via msg.sender and msg.data, they should not be accessed in such a direct
      * manner, since when dealing with meta-transactions the account sending and
      * paying for execution may not be the actual sender (as far as an application
      * is concerned).

568:         address operator,
             address from,
             uint256 tokenId,
             bytes calldata data
         ) external returns (bytes4);
     }
     
     // File: @openzeppelin/contracts/utils/Context.sol
     pragma solidity ^0.8.0;
     /**
      * @dev Provides information about the current execution context, including the
      * sender of the transaction and its data. While these are generally available
      * via msg.sender and msg.data, they should not be accessed in such a direct
      * manner, since when dealing with meta-transactions the account sending and
      * paying for execution may not be the actual sender (as far as an application
      * is concerned).

568:         address operator,
             address from,
             uint256 tokenId,
             bytes calldata data
         ) external returns (bytes4);
     }
     
     // File: @openzeppelin/contracts/utils/Context.sol
     pragma solidity ^0.8.0;
     /**
      * @dev Provides information about the current execution context, including the
      * sender of the transaction and its data. While these are generally available
      * via msg.sender and msg.data, they should not be accessed in such a direct
      * manner, since when dealing with meta-transactions the account sending and
      * paying for execution may not be the actual sender (as far as an application
      * is concerned).

568:         address operator,
             address from,
             uint256 tokenId,
             bytes calldata data
         ) external returns (bytes4);
     }
     
     // File: @openzeppelin/contracts/utils/Context.sol
     pragma solidity ^0.8.0;
     /**
      * @dev Provides information about the current execution context, including the
      * sender of the transaction and its data. While these are generally available
      * via msg.sender and msg.data, they should not be accessed in such a direct
      * manner, since when dealing with meta-transactions the account sending and
      * paying for execution may not be the actual sender (as far as an application
      * is concerned).

```

### <a name="NC-18"></a>[NC-18] Incomplete NatSpec: `@return` is missing on actually documented functions
The following functions are missing `@return` NatSpec comments.

*Instances (1)*:
```solidity
File: example/CarMan.sol

568:         address operator,
             address from,
             uint256 tokenId,
             bytes calldata data
         ) external returns (bytes4);
     }
     
     // File: @openzeppelin/contracts/utils/Context.sol
     pragma solidity ^0.8.0;
     /**
      * @dev Provides information about the current execution context, including the
      * sender of the transaction and its data. While these are generally available
      * via msg.sender and msg.data, they should not be accessed in such a direct
      * manner, since when dealing with meta-transactions the account sending and
      * paying for execution may not be the actual sender (as far as an application
      * is concerned).
      *
      * This contract is only required for intermediate, library-like contracts.

```

### <a name="NC-19"></a>[NC-19] Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor
If a function is supposed to be access-controlled, a `modifier` should be used instead of a `require/if` statement for more readability.

*Instances (22)*:
```solidity
File: example/CarMan.sol

1292:     require(vipMintAmount[msg.sender] != 0, "user is not VIP");

1315:     if (msg.sender != owner()) {

1317:             require(isWhitelisted(msg.sender), "user is not whitelisted");

1340:     if (msg.sender != owner()) {

1342:             require(isWhitelisted(msg.sender), "user is not whitelisted");

1409:     require(controllers[msg.sender], "Only controllers can operate this function");

1414:     require(controllers[msg.sender], "Only controllers can operate this function");

1419:     require(controllers[msg.sender], "Only controllers can operate this function");

1424:     require(controllers[msg.sender], "Only controllers can operate this function");

1429:     require(controllers[msg.sender], "Only controllers can operate this function");

1434:     require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");

1444:     require(controllers[msg.sender], "Only controllers can operate this function");

1449:     require(controllers[msg.sender], "Only controllers can operate this function");

1454:     require(controllers[msg.sender], "Only controllers can operate this function");

1459:     require(controllers[msg.sender], "Only controllers can operate this function");

1464:     require(controllers[msg.sender], "Only controllers can operate this function");

1469:     require(controllers[msg.sender], "Only controllers can operate this function");

1474:     require(controllers[msg.sender], "Only controllers can operate this function");

1483:     require(controllers[msg.sender], "Only controllers can operate this function");

1488:     require(controllers[msg.sender], "Only controllers can operate this function");

1493:     require(controllers[msg.sender], "Only controllers can operate this function");

```

### <a name="NC-20"></a>[NC-20] Consider using named mappings
Consider moving to solidity version 0.8.18 or later, and using [named mappings](https://ethereum.stackexchange.com/questions/51629/how-to-name-the-arguments-in-mapping/145555#145555) to make it easier to understand the purpose of each mapping

*Instances (10)*:
```solidity
File: example/CarMan.sol

616:     mapping(uint256 => address) private _owners;

619:     mapping(address => uint256) private _balances;

622:     mapping(uint256 => address) private _tokenApprovals;

625:     mapping(address => mapping(address => bool)) private _operatorApprovals;

1015:     mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

1018:     mapping(uint256 => uint256) private _ownedTokensIndex;

1024:     mapping(uint256 => uint256) private _allTokensIndex;

1259:   mapping(address => uint256) addressMintedBalance;

1260:   mapping(address => uint256) vipMintAmount;

1263:   mapping(address => bool) controllers;

```

### <a name="NC-21"></a>[NC-21] `require()` / `revert()` statements should have descriptive reason strings

*Instances (1)*:
```solidity
File: example/CarMan.sol

1520: }

```

### <a name="NC-22"></a>[NC-22] Avoid the use of sensitive terms
Use [alternative variants](https://www.zdnet.com/article/mysql-drops-master-slave-and-blacklist-whitelist-terminology/), e.g. allowlist/denylist instead of whitelist/blacklist

*Instances (14)*:
```solidity
File: example/CarMan.sol

1256:   bool public onlyWhitelisted = true;

1257:   address[] whitelistedAddresses;

1316:         if(onlyWhitelisted == true) {

1317:             require(isWhitelisted(msg.sender), "user is not whitelisted");

1341:         if(onlyWhitelisted == true) {

1342:             require(isWhitelisted(msg.sender), "user is not whitelisted");

1355:   function isWhitelisted(address _user) public view returns (bool) {

1356:     for (uint i = 0; i < whitelistedAddresses.length; i++) {

1357:       if (whitelistedAddresses[i] == _user) {

1487:   function setOnlyWhitelisted(bool _state) public {

1489:     onlyWhitelisted = _state;

1492:   function whitelistUsers(address[] calldata _users) public {

1494:     delete whitelistedAddresses;

1495:     whitelistedAddresses = _users;

```

### <a name="NC-23"></a>[NC-23] Contract does not follow the Solidity style guide's suggested layout ordering
The [style guide](https://docs.soliditylang.org/en/v0.8.16/style-guide.html#order-of-layout) says that, within a contract, the ordering should be:

1) Type declarations
2) State variables
3) Events
4) Modifiers
5) Functions

However, the contract(s) below do not follow this ordering

*Instances (1)*:
```solidity
File: example/CarMan.sol

1: 
   Current order:
   FunctionDefinition.supportsInterface
   EventDefinition.Transfer
   EventDefinition.Approval
   EventDefinition.ApprovalForAll
   FunctionDefinition.balanceOf
   FunctionDefinition.ownerOf
   FunctionDefinition.safeTransferFrom
   FunctionDefinition.transferFrom
   FunctionDefinition.approve
   FunctionDefinition.getApproved
   FunctionDefinition.setApprovalForAll
   FunctionDefinition.isApprovedForAll
   FunctionDefinition.safeTransferFrom
   FunctionDefinition.totalSupply
   FunctionDefinition.tokenOfOwnerByIndex
   FunctionDefinition.tokenByIndex
   FunctionDefinition.supportsInterface
   VariableDeclaration._HEX_SYMBOLS
   FunctionDefinition.toString
   FunctionDefinition.toHexString
   FunctionDefinition.toHexString
   FunctionDefinition.isContract
   FunctionDefinition.sendValue
   FunctionDefinition.functionCall
   FunctionDefinition.functionCall
   FunctionDefinition.functionCallWithValue
   FunctionDefinition.functionCallWithValue
   FunctionDefinition.functionStaticCall
   FunctionDefinition.functionStaticCall
   FunctionDefinition.functionDelegateCall
   FunctionDefinition.functionDelegateCall
   FunctionDefinition.verifyCallResult
   FunctionDefinition.name
   FunctionDefinition.symbol
   FunctionDefinition.tokenURI
   FunctionDefinition.onERC721Received
   FunctionDefinition._msgSender
   FunctionDefinition._msgData
   UsingForDirective.Address
   UsingForDirective.Strings
   VariableDeclaration._name
   VariableDeclaration._symbol
   VariableDeclaration._owners
   VariableDeclaration._balances
   VariableDeclaration._tokenApprovals
   VariableDeclaration._operatorApprovals
   FunctionDefinition.constructor
   FunctionDefinition.supportsInterface
   FunctionDefinition.balanceOf
   FunctionDefinition.ownerOf
   FunctionDefinition.name
   FunctionDefinition.symbol
   FunctionDefinition.tokenURI
   FunctionDefinition._baseURI
   FunctionDefinition.approve
   FunctionDefinition.getApproved
   FunctionDefinition.setApprovalForAll
   FunctionDefinition.isApprovedForAll
   FunctionDefinition.transferFrom
   FunctionDefinition.safeTransferFrom
   FunctionDefinition.safeTransferFrom
   FunctionDefinition._safeTransfer
   FunctionDefinition._exists
   FunctionDefinition._isApprovedOrOwner
   FunctionDefinition._safeMint
   FunctionDefinition._safeMint
   FunctionDefinition._mint
   FunctionDefinition._burn
   FunctionDefinition._transfer
   FunctionDefinition._approve
   FunctionDefinition._checkOnERC721Received
   FunctionDefinition._beforeTokenTransfer
   VariableDeclaration._ownedTokens
   VariableDeclaration._ownedTokensIndex
   VariableDeclaration._allTokens
   VariableDeclaration._allTokensIndex
   FunctionDefinition.supportsInterface
   FunctionDefinition.tokenOfOwnerByIndex
   FunctionDefinition.totalSupply
   FunctionDefinition.tokenByIndex
   FunctionDefinition._beforeTokenTransfer
   FunctionDefinition._addTokenToOwnerEnumeration
   FunctionDefinition._addTokenToAllTokensEnumeration
   FunctionDefinition._removeTokenFromOwnerEnumeration
   FunctionDefinition._removeTokenFromAllTokensEnumeration
   VariableDeclaration._owner
   EventDefinition.OwnershipTransferred
   FunctionDefinition.constructor
   FunctionDefinition.owner
   ModifierDefinition.onlyOwner
   FunctionDefinition.renounceOwnership
   FunctionDefinition.transferOwnership
   FunctionDefinition._setOwner
   UsingForDirective.Strings
   VariableDeclaration.baseURI
   VariableDeclaration.baseExtension
   VariableDeclaration.notRevealedUri
   VariableDeclaration.cost
   VariableDeclaration.maxSupply
   VariableDeclaration.maxMintAmount
   VariableDeclaration.nftPerAddressLimit
   VariableDeclaration.currentPhaseMintMaxAmount
   VariableDeclaration.publicSaleStart
   VariableDeclaration.preSaleStart
   VariableDeclaration.vipSaleStart
   VariableDeclaration.publicSalePaused
   VariableDeclaration.preSalePaused
   VariableDeclaration.vipSalePaused
   VariableDeclaration.revealed
   VariableDeclaration.onlyWhitelisted
   VariableDeclaration.whitelistedAddresses
   VariableDeclaration.addressMintedBalance
   VariableDeclaration.vipMintAmount
   VariableDeclaration.controllers
   FunctionDefinition.constructor
   FunctionDefinition._baseURI
   FunctionDefinition.vipSaleMint
   FunctionDefinition.preSaleMint
   FunctionDefinition.publicSaleMint
   FunctionDefinition.isWhitelisted
   FunctionDefinition.walletOfOwner
   FunctionDefinition.tokenURI
   FunctionDefinition.publicSaleIsActive
   FunctionDefinition.preSaleIsActive
   FunctionDefinition.vipSaleIsActive
   FunctionDefinition.checkVIPMintAmount
   FunctionDefinition.reveal
   FunctionDefinition.setNftPerAddressLimit
   FunctionDefinition.setCost
   FunctionDefinition.setmaxMintAmount
   FunctionDefinition.setcurrentPhaseMintMaxAmount
   FunctionDefinition.setPublicSaleStart
   FunctionDefinition.setPreSaleStart
   FunctionDefinition.setVIPSaleStart
   FunctionDefinition.setBaseURI
   FunctionDefinition.setBaseExtension
   FunctionDefinition.setNotRevealedURI
   FunctionDefinition.setPreSalePause
   FunctionDefinition.setVIPSalePause
   FunctionDefinition.setVIPMintAmount
   FunctionDefinition.setPublicSalePause
   FunctionDefinition.setOnlyWhitelisted
   FunctionDefinition.whitelistUsers
   FunctionDefinition.addController
   FunctionDefinition.removeController
   FunctionDefinition.withdraw
   
   Suggested order:
   UsingForDirective.Address
   UsingForDirective.Strings
   UsingForDirective.Strings
   VariableDeclaration._HEX_SYMBOLS
   VariableDeclaration._name
   VariableDeclaration._symbol
   VariableDeclaration._owners
   VariableDeclaration._balances
   VariableDeclaration._tokenApprovals
   VariableDeclaration._operatorApprovals
   VariableDeclaration._ownedTokens
   VariableDeclaration._ownedTokensIndex
   VariableDeclaration._allTokens
   VariableDeclaration._allTokensIndex
   VariableDeclaration._owner
   VariableDeclaration.baseURI
   VariableDeclaration.baseExtension
   VariableDeclaration.notRevealedUri
   VariableDeclaration.cost
   VariableDeclaration.maxSupply
   VariableDeclaration.maxMintAmount
   VariableDeclaration.nftPerAddressLimit
   VariableDeclaration.currentPhaseMintMaxAmount
   VariableDeclaration.publicSaleStart
   VariableDeclaration.preSaleStart
   VariableDeclaration.vipSaleStart
   VariableDeclaration.publicSalePaused
   VariableDeclaration.preSalePaused
   VariableDeclaration.vipSalePaused
   VariableDeclaration.revealed
   VariableDeclaration.onlyWhitelisted
   VariableDeclaration.whitelistedAddresses
   VariableDeclaration.addressMintedBalance
   VariableDeclaration.vipMintAmount
   VariableDeclaration.controllers
   EventDefinition.Transfer
   EventDefinition.Approval
   EventDefinition.ApprovalForAll
   EventDefinition.OwnershipTransferred
   ModifierDefinition.onlyOwner
   FunctionDefinition.supportsInterface
   FunctionDefinition.balanceOf
   FunctionDefinition.ownerOf
   FunctionDefinition.safeTransferFrom
   FunctionDefinition.transferFrom
   FunctionDefinition.approve
   FunctionDefinition.getApproved
   FunctionDefinition.setApprovalForAll
   FunctionDefinition.isApprovedForAll
   FunctionDefinition.safeTransferFrom
   FunctionDefinition.totalSupply
   FunctionDefinition.tokenOfOwnerByIndex
   FunctionDefinition.tokenByIndex
   FunctionDefinition.supportsInterface
   FunctionDefinition.toString
   FunctionDefinition.toHexString
   FunctionDefinition.toHexString
   FunctionDefinition.isContract
   FunctionDefinition.sendValue
   FunctionDefinition.functionCall
   FunctionDefinition.functionCall
   FunctionDefinition.functionCallWithValue
   FunctionDefinition.functionCallWithValue
   FunctionDefinition.functionStaticCall
   FunctionDefinition.functionStaticCall
   FunctionDefinition.functionDelegateCall
   FunctionDefinition.functionDelegateCall
   FunctionDefinition.verifyCallResult
   FunctionDefinition.name
   FunctionDefinition.symbol
   FunctionDefinition.tokenURI
   FunctionDefinition.onERC721Received
   FunctionDefinition._msgSender
   FunctionDefinition._msgData
   FunctionDefinition.constructor
   FunctionDefinition.supportsInterface
   FunctionDefinition.balanceOf
   FunctionDefinition.ownerOf
   FunctionDefinition.name
   FunctionDefinition.symbol
   FunctionDefinition.tokenURI
   FunctionDefinition._baseURI
   FunctionDefinition.approve
   FunctionDefinition.getApproved
   FunctionDefinition.setApprovalForAll
   FunctionDefinition.isApprovedForAll
   FunctionDefinition.transferFrom
   FunctionDefinition.safeTransferFrom
   FunctionDefinition.safeTransferFrom
   FunctionDefinition._safeTransfer
   FunctionDefinition._exists
   FunctionDefinition._isApprovedOrOwner
   FunctionDefinition._safeMint
   FunctionDefinition._safeMint
   FunctionDefinition._mint
   FunctionDefinition._burn
   FunctionDefinition._transfer
   FunctionDefinition._approve
   FunctionDefinition._checkOnERC721Received
   FunctionDefinition._beforeTokenTransfer
   FunctionDefinition.supportsInterface
   FunctionDefinition.tokenOfOwnerByIndex
   FunctionDefinition.totalSupply
   FunctionDefinition.tokenByIndex
   FunctionDefinition._beforeTokenTransfer
   FunctionDefinition._addTokenToOwnerEnumeration
   FunctionDefinition._addTokenToAllTokensEnumeration
   FunctionDefinition._removeTokenFromOwnerEnumeration
   FunctionDefinition._removeTokenFromAllTokensEnumeration
   FunctionDefinition.constructor
   FunctionDefinition.owner
   FunctionDefinition.renounceOwnership
   FunctionDefinition.transferOwnership
   FunctionDefinition._setOwner
   FunctionDefinition.constructor
   FunctionDefinition._baseURI
   FunctionDefinition.vipSaleMint
   FunctionDefinition.preSaleMint
   FunctionDefinition.publicSaleMint
   FunctionDefinition.isWhitelisted
   FunctionDefinition.walletOfOwner
   FunctionDefinition.tokenURI
   FunctionDefinition.publicSaleIsActive
   FunctionDefinition.preSaleIsActive
   FunctionDefinition.vipSaleIsActive
   FunctionDefinition.checkVIPMintAmount
   FunctionDefinition.reveal
   FunctionDefinition.setNftPerAddressLimit
   FunctionDefinition.setCost
   FunctionDefinition.setmaxMintAmount
   FunctionDefinition.setcurrentPhaseMintMaxAmount
   FunctionDefinition.setPublicSaleStart
   FunctionDefinition.setPreSaleStart
   FunctionDefinition.setVIPSaleStart
   FunctionDefinition.setBaseURI
   FunctionDefinition.setBaseExtension
   FunctionDefinition.setNotRevealedURI
   FunctionDefinition.setPreSalePause
   FunctionDefinition.setVIPSalePause
   FunctionDefinition.setVIPMintAmount
   FunctionDefinition.setPublicSalePause
   FunctionDefinition.setOnlyWhitelisted
   FunctionDefinition.whitelistUsers
   FunctionDefinition.addController
   FunctionDefinition.removeController
   FunctionDefinition.withdraw

```

### <a name="NC-24"></a>[NC-24] Use Underscores for Number Literals (add an underscore every 3 digits)

*Instances (4)*:
```solidity
File: example/CarMan.sol

1242:   uint256 public maxSupply = 2000;

1247:   uint32 public publicSaleStart = 1647136800;

1248:   uint32 public preSaleStart = 1646964000;

1249:   uint32 public vipSaleStart = 1646618400;

```

### <a name="NC-25"></a>[NC-25] Internal and private variables and functions names should begin with an underscore
According to the Solidity Style Guide, Non-`external` variable and function names should begin with an [underscore](https://docs.soliditylang.org/en/latest/style-guide.html#underscore-prefix-for-non-external-functions-and-variables)

*Instances (18)*:
```solidity
File: example/CarMan.sol

259:         while (value != 0) {

286:     function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

303: pragma solidity ^0.8.0;

340:      * `recipient`, forwarding all available gas and reverting on errors.

366:      * If `target` reverts with a revert reason, it is bubbled up by this

393:     ) internal returns (bytes memory) {

404:      * - the called Solidity function must be `payable`.

422:     function functionCallWithValue(

436:      * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],

455:     ) internal view returns (bytes memory) {

466:      * _Available since v3.4._

482:     ) internal returns (bytes memory) {

491:      * revert reason using the provided one.

509:                     revert(add(32, returndata), returndata_size)

1277:   function _baseURI() internal view virtual override returns (string memory) {

1278:     return baseURI;

1282:   function vipSaleMint(uint256 _mintAmount) public {

1283:     require(_mintAmount > 0, "Mint Amount should be bigger than 0");

```

### <a name="NC-26"></a>[NC-26] Event is missing `indexed` fields
Index event fields make the field more quickly accessible to off-chain tools that parse events. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Each event should use three indexed fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three fields, all of the fields should be indexed.

*Instances (1)*:
```solidity
File: example/CarMan.sol

75:      * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients

```

### <a name="NC-27"></a>[NC-27] `public` functions not called by the contract should be declared `external` instead

*Instances (26)*:
```solidity
File: example/CarMan.sol

1290:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1313:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1338:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1380:     

1405:   }

1409:     require(controllers[msg.sender], "Only controllers can operate this function");

1414:     require(controllers[msg.sender], "Only controllers can operate this function");

1419:     require(controllers[msg.sender], "Only controllers can operate this function");

1423:   function setmaxMintAmount(uint256 _newmaxMintAmount) public {

1426:   }

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;

1434:     require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");

1447: 

1453:   function setBaseExtension(string memory _newBaseExtension) public {

1455:     baseExtension = _newBaseExtension;

1460:     notRevealedUri = _notRevealedURI;

1465:     preSalePaused = _state;

1472: 

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");

1478:       vipMintAmount[_accounts[i]]=_amounts[i];

1484:     publicSalePaused = _state;

1495:     whitelistedAddresses = _users;

1504:   function addController(address controller) external onlyOwner {

1510:    * @param controller the address to disbale

1520: }

```

### <a name="NC-28"></a>[NC-28] Variables need not be initialized to zero
The default value for variables is zero, so initializing them to zero is superfluous.

*Instances (3)*:
```solidity
File: example/CarMan.sol

275:         uint256 length = 0;

1356:     for (uint i = 0; i < whitelistedAddresses.length; i++) {

1477:     for (uint256 i = 0; i < _accounts.length; ++i) {

```


## Low Issues


| |Issue|Instances|
|-|:-|:-:|
| [L-1](#L-1) | Use a 2-step ownership transfer pattern | 1 |
| [L-2](#L-2) | Missing checks for `address(0)` when assigning values to address state variables | 1 |
| [L-3](#L-3) | `abi.encodePacked()` should not be used with dynamic types when passing the result to a hash function such as `keccak256()` | 2 |
| [L-4](#L-4) | External call recipient may consume all transaction gas | 3 |
| [L-5](#L-5) | Signature use at deadlines should be allowed | 6 |
| [L-6](#L-6) | Prevent accidentally burning tokens | 21 |
| [L-7](#L-7) | NFT ownership doesn't support hard forks | 1 |
| [L-8](#L-8) | Use `Ownable2Step.transferOwnership` instead of `Ownable.transferOwnership` | 1 |
| [L-9](#L-9) | Unspecific compiler version pragma | 1 |
### <a name="L-1"></a>[L-1] Use a 2-step ownership transfer pattern
Recommend considering implementing a two step process where the owner or admin nominates an account and the nominated account needs to call an `acceptOwnership()` function for the transfer of ownership to fully succeed. This ensures the nominated EOA account is a valid and active account. Lack of two-step procedure for critical operations leaves them error-prone. Consider adding two step procedure on the critical functions.

*Instances (1)*:
```solidity
File: example/CarMan.sol

1235: contract CarMan is ERC721Enumerable, Ownable {

```

### <a name="L-2"></a>[L-2] Missing checks for `address(0)` when assigning values to address state variables

*Instances (1)*:
```solidity
File: example/CarMan.sol

1247:   uint32 public publicSaleStart = 1647136800;

```

### <a name="L-3"></a>[L-3] `abi.encodePacked()` should not be used with dynamic types when passing the result to a hash function such as `keccak256()`
Use `abi.encode()` instead which will pad items to 32 bytes, which will [prevent hash collisions](https://docs.soliditylang.org/en/v0.8.13/abi-spec.html#non-standard-packed-mode) (e.g. `abi.encodePacked(0x123,0x456)` => `0x123456` => `abi.encodePacked(0x1,0x23456)`, but `abi.encode(0x123,0x456)` => `0x0...1230...456`). "Unless there is a compelling reason, `abi.encode` should be preferred". If there is only one argument to `abi.encodePacked()` it can often be cast to `bytes()` or `bytes32()` [instead](https://ethereum.stackexchange.com/questions/30912/how-to-compare-strings-in-solidity#answer-82739).
If all arguments are strings and or bytes, `bytes.concat()` should be used instead

*Instances (2)*:
```solidity
File: example/CarMan.sol

699:         address owner = ERC721.ownerOf(tokenId);

1403:   function checkVIPMintAmount(address _account) public view returns (uint256) {

```

### <a name="L-4"></a>[L-4] External call recipient may consume all transaction gas
There is no limit specified on the amount of gas used, so the recipient can use up all of the transaction's gas, causing it to revert. Use `addr.call{gas: <amount>}("")` or [this](https://github.com/nomad-xyz/ExcessivelySafeCall) library instead.

*Instances (3)*:
```solidity
File: example/CarMan.sol

357:         (bool success, ) = recipient.call{value: amount}("");

431:         (bool success, bytes memory returndata) = target.call{value: value}(data);

1517:     (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");

```

### <a name="L-5"></a>[L-5] Signature use at deadlines should be allowed
According to [EIP-2612](https://github.com/ethereum/EIPs/blob/71dc97318013bf2ac572ab63fab530ac9ef419ca/EIPS/eip-2612.md?plain=1#L58), signatures used on exactly the deadline timestamp are supposed to be allowed. While the signature may or may not be used for the exact EIP-2612 use case (transfer approvals), for consistency's sake, all deadlines should follow this semantic. If the timestamp is an expiration rather than a deadline, consider whether it makes more sense to include the expiration timestamp as a valid timestamp, as is done for deadlines.

*Instances (6)*:
```solidity
File: example/CarMan.sol

1284:     require((!vipSalePaused)&&(vipSaleStart <= block.timestamp), "Not Reach VIP Sale Time");

1307:     require((!preSalePaused)&&(preSaleStart <= block.timestamp), "Not Reach Pre Sale Time");

1332:     require((!publicSalePaused)&&(publicSaleStart <= block.timestamp), "Not Reach Public Sale Time");

1392:     return ( (publicSaleStart <= block.timestamp) && (!publicSalePaused) );

1396:     return ( (preSaleStart <= block.timestamp) && (!preSalePaused) );

1400:     return ( (vipSaleStart <= block.timestamp) && (!vipSalePaused) );

```

### <a name="L-6"></a>[L-6] Prevent accidentally burning tokens
Minting and burning tokens to address(0) prevention

*Instances (21)*:
```solidity
File: example/CarMan.sol

869:     function _mint(address to, uint256 tokenId) internal virtual {

1292:     require(vipMintAmount[msg.sender] != 0, "user is not VIP");

1296:     require(ownerMintedCount + _mintAmount <= vipMintCount, "max VIP Mint Amount exceeded");

1297:     require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");

1300:         addressMintedBalance[msg.sender]++;

1307:     require((!preSalePaused)&&(preSaleStart <= block.timestamp), "Not Reach Pre Sale Time");

1310:     require(_mintAmount > 0, "need to mint at least 1 NFT");

1315:     if (msg.sender != owner()) {

1318:             uint256 ownerMintedCount = addressMintedBalance[msg.sender];

1319:             require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");

1321:         require(msg.value >= cost * _mintAmount, "insufficient funds");

1324:     for (uint256 i = 1; i <= _mintAmount; i++) {

1332:     require((!publicSalePaused)&&(publicSaleStart <= block.timestamp), "Not Reach Public Sale Time");

1335:     require(_mintAmount > 0, "need to mint at least 1 NFT");

1340:     if (msg.sender != owner()) {

1343:             uint256 ownerMintedCount = addressMintedBalance[msg.sender];

1344:             require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");

1346:         require(msg.value >= cost * _mintAmount, "insufficient funds");

1349:     for (uint256 i = 1; i <= _mintAmount; i++) {

1358:           return true;

1364:   function walletOfOwner(address _owner) public view returns (uint256[] memory)

```

### <a name="L-7"></a>[L-7] NFT ownership doesn't support hard forks
To ensure clarity regarding the ownership of the NFT on a specific chain, it is recommended to add `require(block.chainid == 1, "Invalid Chain")` or the desired chain ID in the functions below.

Alternatively, consider including the chain ID in the URI itself. By doing so, any confusion regarding the chain responsible for owning the NFT will be eliminated.

*Instances (1)*:
```solidity
File: example/CarMan.sol

560:      * by `operator` from `from`, this function is called.

```

### <a name="L-8"></a>[L-8] Use `Ownable2Step.transferOwnership` instead of `Ownable.transferOwnership`
Use [Ownable2Step.transferOwnership](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable2Step.sol) which is safer. Use it as it is more secure due to 2-stage ownership transfer.

**Recommended Mitigation Steps**

Use <a href="https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable2Step.sol">Ownable2Step.sol</a>
  
  ```solidity
      function acceptOwnership() external {
          address sender = _msgSender();
          require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
          _transferOwnership(sender);
      }
```

*Instances (1)*:
```solidity
File: example/CarMan.sol

1221:     function transferOwnership(address newOwner) public virtual onlyOwner {

```

### <a name="L-9"></a>[L-9] Unspecific compiler version pragma

*Instances (1)*:
```solidity
File: example/CarMan.sol

1233: pragma solidity >=0.7.0 <0.9.0;

```


## Medium Issues


| |Issue|Instances|
|-|:-|:-:|
| [M-1](#M-1) | Centralization Risk for trusted owners | 7 |
| [M-2](#M-2) | `_safeMint()` should be used rather than `_mint()` wherever possible | 1 |
| [M-3](#M-3) | Library function isn't `internal` or `private` | 88 |
| [M-4](#M-4) | Direct `supportsInterface()` calls may cause caller to revert | 2 |
### <a name="M-1"></a>[M-1] Centralization Risk for trusted owners

#### Impact:
Contracts have owners with privileged rights to perform admin tasks and need to be trusted to not perform malicious updates or drain funds.

*Instances (7)*:
```solidity
File: example/CarMan.sol

1179: abstract contract Ownable is Context {

1213:     function renounceOwnership() public virtual onlyOwner {

1221:     function transferOwnership(address newOwner) public virtual onlyOwner {

1235: contract CarMan is ERC721Enumerable, Ownable {

1504:   function addController(address controller) external onlyOwner {

1512:   function removeController(address controller) external onlyOwner {

1516:   function withdraw() public onlyOwner {

```

### <a name="M-2"></a>[M-2] `_safeMint()` should be used rather than `_mint()` wherever possible
`_mint()` is [discouraged](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4d8d2ed9798cc3383912a23b5e8d5cb602f7d4b/contracts/token/ERC721/ERC721.sol#L271) in favor of `_safeMint()` which ensures that the recipient is either an EOA or implements `IERC721Receiver`. Both open [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4d8d2ed9798cc3383912a23b5e8d5cb602f7d4b/contracts/token/ERC721/ERC721.sol#L238-L250) and [solmate](https://github.com/Rari-Capital/solmate/blob/4eaf6b68202e36f67cab379768ac6be304c8ebde/src/tokens/ERC721.sol#L180) have versions of this function so that NFTs aren't lost if they're minted to contracts that cannot transfer them back out.

Be careful however to respect the CEI pattern or add a re-entrancy guard as `_safeMint` adds a callback-check (`_checkOnERC721Received`) and a malicious `onERC721Received` could be exploited if not careful.

Reading material:

- <https://blocksecteam.medium.com/when-safemint-becomes-unsafe-lessons-from-the-hypebears-security-incident-2965209bda2a>
- <https://samczsun.com/the-dangers-of-surprising-code/>
- <https://github.com/KadenZipfel/smart-contract-attack-vectors/blob/master/vulnerabilities/unprotected-callback.md>

*Instances (1)*:
```solidity
File: example/CarMan.sol

850:         _mint(to, tokenId);

```

### <a name="M-3"></a>[M-3] Library function isn't `internal` or `private`
In a library, using an external or public visibility means that we won't be going through the library with a DELEGATECALL but with a CALL. This changes the context and should be done carefully.

*Instances (88)*:
```solidity
File: example/CarMan.sol

51:      * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.

51:      * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.

79:      *

79:      *

83:      * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.

83:      * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.

104:      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.

104:      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.

125:      * Emits an {Approval} event.

125:      * Emits an {Approval} event.

144:      * - The `operator` cannot be the caller.

144:      * - The `operator` cannot be the caller.

151:      * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.

151:      * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.

164:      * - `tokenId` token must exist and be owned by `from`.

164:      * - `tokenId` token must exist and be owned by `from`.

166:      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.

166:      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.

189:     function totalSupply() external view returns (uint256);

189:     function totalSupply() external view returns (uint256);

201:     function tokenByIndex(uint256 index) external view returns (uint256);

201:     function tokenByIndex(uint256 index) external view returns (uint256);

210:  * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check

210:  * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check

215:  *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);

215:  *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);

554:  * @dev Interface for any contract that wants to support safeTransfers

554:  * @dev Interface for any contract that wants to support safeTransfers

559:      * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}

559:      * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}

560:      * by `operator` from `from`, this function is called.

560:      * by `operator` from `from`, this function is called.

581:  * manner, since when dealing with meta-transactions the account sending and

581:  * manner, since when dealing with meta-transactions the account sending and

1290:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1290:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1313:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1313:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1338:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1338:     require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

1369:       tokenIds[i] = tokenOfOwnerByIndex(_owner, i);

1369:       tokenIds[i] = tokenOfOwnerByIndex(_owner, i);

1380:     

1380:     

1405:   }

1405:   }

1409:     require(controllers[msg.sender], "Only controllers can operate this function");

1409:     require(controllers[msg.sender], "Only controllers can operate this function");

1414:     require(controllers[msg.sender], "Only controllers can operate this function");

1414:     require(controllers[msg.sender], "Only controllers can operate this function");

1419:     require(controllers[msg.sender], "Only controllers can operate this function");

1419:     require(controllers[msg.sender], "Only controllers can operate this function");

1423:   function setmaxMintAmount(uint256 _newmaxMintAmount) public {

1423:   function setmaxMintAmount(uint256 _newmaxMintAmount) public {

1426:   }

1426:   }

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;

1430:     currentPhaseMintMaxAmount = _newPhaseAmount;

1434:     require(controllers[msg.sender], "Only controllers can operate this function");

1434:     require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");

1439:     require(controllers[msg.sender], "Only controllers can operate this function");

1447: 

1447: 

1453:   function setBaseExtension(string memory _newBaseExtension) public {

1453:   function setBaseExtension(string memory _newBaseExtension) public {

1455:     baseExtension = _newBaseExtension;

1455:     baseExtension = _newBaseExtension;

1460:     notRevealedUri = _notRevealedURI;

1460:     notRevealedUri = _notRevealedURI;

1465:     preSalePaused = _state;

1465:     preSalePaused = _state;

1472: 

1472: 

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");

1475:     require(_accounts.length == _amounts.length, "accounts and amounts array length mismatch");

1478:       vipMintAmount[_accounts[i]]=_amounts[i];

1478:       vipMintAmount[_accounts[i]]=_amounts[i];

1484:     publicSalePaused = _state;

1484:     publicSalePaused = _state;

1495:     whitelistedAddresses = _users;

1495:     whitelistedAddresses = _users;

1504:   function addController(address controller) external onlyOwner {

1504:   function addController(address controller) external onlyOwner {

1510:    * @param controller the address to disbale

1510:    * @param controller the address to disbale

1520: }

1520: }

```

### <a name="M-4"></a>[M-4] Direct `supportsInterface()` calls may cause caller to revert
Calling `supportsInterface()` on a contract that doesn't implement the ERC-165 standard will result in the call reverting. Even if the caller does support the function, the contract may be malicious and consume all of the transaction's available gas. Call it via a low-level [staticcall()](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f959d7e4e6ee0b022b41e5b644c79369869d8411/contracts/utils/introspection/ERC165Checker.sol#L119), with a fixed amount of gas, and check the return code, or use OpenZeppelin's [`ERC165Checker.supportsInterface()`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f959d7e4e6ee0b022b41e5b644c79369869d8411/contracts/utils/introspection/ERC165Checker.sol#L36-L39).

*Instances (2)*:
```solidity
File: example/CarMan.sol

642:             super.supportsInterface(interfaceId);

1030:         return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);

```

