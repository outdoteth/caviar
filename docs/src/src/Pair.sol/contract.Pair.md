# Pair
[Git Source](https://github.com/outdoteth/Caviar/blob/fe772f95d422ab3b2897f7403c37b8326c5a1bbf/src/Pair.sol)

**Inherits:**
ERC20, ERC721TokenReceiver

**Author:**
out.eth (@outdoteth)

A pair of an NFT and a base token that can be used to create and trade fractionalized NFTs.


## State Variables
### CLOSE_GRACE_PERIOD

```solidity
uint256 public constant CLOSE_GRACE_PERIOD = 7 days;
```


### ONE

```solidity
uint256 private constant ONE = 1e18;
```


### MINIMUM_LIQUIDITY

```solidity
uint256 private constant MINIMUM_LIQUIDITY = 100_000;
```


### nft

```solidity
address public immutable nft;
```


### baseToken

```solidity
address public immutable baseToken;
```


### merkleRoot

```solidity
bytes32 public immutable merkleRoot;
```


### lpToken

```solidity
LpToken public immutable lpToken;
```


### caviar

```solidity
Caviar public immutable caviar;
```


### closeTimestamp

```solidity
uint256 public closeTimestamp;
```


## Functions
### constructor


```solidity
constructor(
    address _nft,
    address _baseToken,
    bytes32 _merkleRoot,
    string memory pairSymbol,
    string memory nftName,
    string memory nftSymbol
) ERC20(string.concat(nftName, " fractional token"), string.concat("f", nftSymbol), 18);
```

### add

Adds liquidity to the pair.


```solidity
function add(
    uint256 baseTokenAmount,
    uint256 fractionalTokenAmount,
    uint256 minLpTokenAmount,
    uint256 minPrice,
    uint256 maxPrice,
    uint256 deadline
) public payable returns (uint256 lpTokenAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`baseTokenAmount`|`uint256`|The amount of base tokens to add.|
|`fractionalTokenAmount`|`uint256`|The amount of fractional tokens to add.|
|`minLpTokenAmount`|`uint256`|The minimum amount of LP tokens to mint.|
|`minPrice`|`uint256`|The minimum price that the pool should currently be at.|
|`maxPrice`|`uint256`|The maximum price that the pool should currently be at.|
|`deadline`|`uint256`|The deadline before the trade expires.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`lpTokenAmount`|`uint256`|The amount of LP tokens minted.|


### remove

Removes liquidity from the pair.


```solidity
function remove(
    uint256 lpTokenAmount,
    uint256 minBaseTokenOutputAmount,
    uint256 minFractionalTokenOutputAmount,
    uint256 deadline
) public returns (uint256 baseTokenOutputAmount, uint256 fractionalTokenOutputAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`lpTokenAmount`|`uint256`|The amount of LP tokens to burn.|
|`minBaseTokenOutputAmount`|`uint256`|The minimum amount of base tokens to receive.|
|`minFractionalTokenOutputAmount`|`uint256`|The minimum amount of fractional tokens to receive.|
|`deadline`|`uint256`|The deadline before the trade expires.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`baseTokenOutputAmount`|`uint256`|The amount of base tokens received.|
|`fractionalTokenOutputAmount`|`uint256`|The amount of fractional tokens received.|


### buy

Buys fractional tokens from the pair.


```solidity
function buy(uint256 outputAmount, uint256 maxInputAmount, uint256 deadline)
    public
    payable
    returns (uint256 inputAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`outputAmount`|`uint256`|The amount of fractional tokens to buy.|
|`maxInputAmount`|`uint256`|The maximum amount of base tokens to spend.|
|`deadline`|`uint256`|The deadline before the trade expires.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`inputAmount`|`uint256`|The amount of base tokens spent.|


### sell

Sells fractional tokens to the pair.


```solidity
function sell(uint256 inputAmount, uint256 minOutputAmount, uint256 deadline) public returns (uint256 outputAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`inputAmount`|`uint256`|The amount of fractional tokens to sell.|
|`minOutputAmount`|`uint256`|The minimum amount of base tokens to receive.|
|`deadline`|`uint256`|The deadline before the trade expires.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`outputAmount`|`uint256`|The amount of base tokens received.|


### wrap

Wraps NFTs into fractional tokens.


```solidity
function wrap(uint256[] calldata tokenIds, bytes32[][] calldata proofs, ReservoirOracle.Message[] calldata messages)
    public
    returns (uint256 fractionalTokenAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenIds`|`uint256[]`|The ids of the NFTs to wrap.|
|`proofs`|`bytes32[][]`|The merkle proofs for the NFTs proving that they can be used in the pair.|
|`messages`|`Message.ReservoirOracle[]`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`fractionalTokenAmount`|`uint256`|The amount of fractional tokens minted.|


### unwrap

Unwraps fractional tokens into NFTs.


```solidity
function unwrap(uint256[] calldata tokenIds, bool withFee) public returns (uint256 fractionalTokenAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenIds`|`uint256[]`|The ids of the NFTs to unwrap.|
|`withFee`|`bool`|Whether to pay a fee for unwrapping or not.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`fractionalTokenAmount`|`uint256`|The amount of fractional tokens burned.|


### nftAdd

nftAdd Adds liquidity to the pair using NFTs.


```solidity
function nftAdd(
    uint256 baseTokenAmount,
    uint256[] calldata tokenIds,
    uint256 minLpTokenAmount,
    uint256 minPrice,
    uint256 maxPrice,
    uint256 deadline,
    bytes32[][] calldata proofs,
    ReservoirOracle.Message[] calldata messages
) public payable returns (uint256 lpTokenAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`baseTokenAmount`|`uint256`|The amount of base tokens to add.|
|`tokenIds`|`uint256[]`|The ids of the NFTs to add.|
|`minLpTokenAmount`|`uint256`|The minimum amount of lp tokens to receive.|
|`minPrice`|`uint256`|The minimum price of the pair.|
|`maxPrice`|`uint256`|The maximum price of the pair.|
|`deadline`|`uint256`|The deadline for the transaction.|
|`proofs`|`bytes32[][]`|The merkle proofs for the NFTs.|
|`messages`|`Message.ReservoirOracle[]`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`lpTokenAmount`|`uint256`|The amount of lp tokens minted.|


### nftRemove

Removes liquidity from the pair using NFTs.


```solidity
function nftRemove(
    uint256 lpTokenAmount,
    uint256 minBaseTokenOutputAmount,
    uint256 deadline,
    uint256[] calldata tokenIds,
    bool withFee
) public returns (uint256 baseTokenOutputAmount, uint256 fractionalTokenOutputAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`lpTokenAmount`|`uint256`|The amount of lp tokens to remove.|
|`minBaseTokenOutputAmount`|`uint256`|The minimum amount of base tokens to receive.|
|`deadline`|`uint256`|The deadline before the trade expires.|
|`tokenIds`|`uint256[]`|The ids of the NFTs to remove.|
|`withFee`|`bool`|Whether to pay a fee for unwrapping or not.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`baseTokenOutputAmount`|`uint256`|The amount of base tokens received.|
|`fractionalTokenOutputAmount`|`uint256`|The amount of fractional tokens received.|


### nftBuy

Buys NFTs from the pair using base tokens.


```solidity
function nftBuy(uint256[] calldata tokenIds, uint256 maxInputAmount, uint256 deadline)
    public
    payable
    returns (uint256 inputAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenIds`|`uint256[]`|The ids of the NFTs to buy.|
|`maxInputAmount`|`uint256`|The maximum amount of base tokens to spend.|
|`deadline`|`uint256`|The deadline before the trade expires.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`inputAmount`|`uint256`|The amount of base tokens spent.|


### nftSell

Sells NFTs to the pair for base tokens.


```solidity
function nftSell(
    uint256[] calldata tokenIds,
    uint256 minOutputAmount,
    uint256 deadline,
    bytes32[][] calldata proofs,
    ReservoirOracle.Message[] calldata messages
) public returns (uint256 outputAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenIds`|`uint256[]`|The ids of the NFTs to sell.|
|`minOutputAmount`|`uint256`|The minimum amount of base tokens to receive.|
|`deadline`|`uint256`|The deadline before the trade expires.|
|`proofs`|`bytes32[][]`|The merkle proofs for the NFTs.|
|`messages`|`Message.ReservoirOracle[]`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`outputAmount`|`uint256`|The amount of base tokens received.|


### close

Closes the pair to new wraps.

*Can only be called by the caviar owner. This is used as an emergency exit in case
the caviar owner suspects that the pair has been compromised.*


```solidity
function close() public;
```

### withdraw

Withdraws a particular NFT from the pair.

*Can only be called by the caviar owner after the close grace period has passed. This
is used to auction off the NFTs in the pair in case NFTs get stuck due to liquidity
imbalances. Proceeds from the auction should be distributed pro rata to fractional
token holders. See documentation for more details.*


```solidity
function withdraw(uint256 tokenId) public;
```

### baseTokenReserves


```solidity
function baseTokenReserves() public view returns (uint256);
```

### fractionalTokenReserves


```solidity
function fractionalTokenReserves() public view returns (uint256);
```

### price

The current price of one fractional token in base tokens with 18 decimals of precision.

*Calculated by dividing the base token reserves by the fractional token reserves.*


```solidity
function price() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|price The price of one fractional token in base tokens * 1e18.|


### buyQuote

The amount of base tokens required to buy a given amount of fractional tokens.

*Calculated using the xyk invariant and a 30bps fee.*


```solidity
function buyQuote(uint256 outputAmount) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`outputAmount`|`uint256`|The amount of fractional tokens to buy.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|inputAmount The amount of base tokens required.|


### sellQuote

The amount of base tokens received for selling a given amount of fractional tokens.

*Calculated using the xyk invariant and a 30bps fee.*


```solidity
function sellQuote(uint256 inputAmount) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`inputAmount`|`uint256`|The amount of fractional tokens to sell.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|outputAmount The amount of base tokens received.|


### addQuote

The amount of lp tokens received for adding a given amount of base tokens and fractional tokens.

*Calculated as a share of existing deposits. If there are no existing deposits, then initializes to
sqrt(baseTokenAmount * fractionalTokenAmount).*


```solidity
function addQuote(uint256 baseTokenAmount, uint256 fractionalTokenAmount, uint256 lpTokenSupply)
    public
    view
    returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`baseTokenAmount`|`uint256`|The amount of base tokens to add.|
|`fractionalTokenAmount`|`uint256`|The amount of fractional tokens to add.|
|`lpTokenSupply`|`uint256`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|lpTokenAmount The amount of lp tokens received.|


### removeQuote

The amount of base tokens and fractional tokens received for burning a given amount of lp tokens.

*Calculated as a share of existing deposits.*


```solidity
function removeQuote(uint256 lpTokenAmount) public view returns (uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`lpTokenAmount`|`uint256`|The amount of lp tokens to burn.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|baseTokenAmount The amount of base tokens received.|
|`<none>`|`uint256`|fractionalTokenAmount The amount of fractional tokens received.|


### _transferFrom


```solidity
function _transferFrom(address from, address to, uint256 amount) internal returns (bool);
```

### _validateTokensAreNotStolen


```solidity
function _validateTokensAreNotStolen(uint256[] calldata tokenIds, ReservoirOracle.Message[] calldata messages)
    internal
    view;
```

### _validateTokenIds

*Validates that the given tokenIds are valid for the contract's merkle root. Reverts
if any of the tokenId proofs are invalid.*


```solidity
function _validateTokenIds(uint256[] calldata tokenIds, bytes32[][] calldata proofs) internal view;
```

### _baseTokenReserves

*Returns the current base token reserves. If the base token is ETH then it ignores
the msg.value that is being sent in the current call context - this is to ensure the
xyk math is correct in the buy() and add() functions.*


```solidity
function _baseTokenReserves() internal view returns (uint256);
```

## Events
### Add

```solidity
event Add(uint256 indexed baseTokenAmount, uint256 indexed fractionalTokenAmount, uint256 indexed lpTokenAmount);
```

### Remove

```solidity
event Remove(uint256 indexed baseTokenAmount, uint256 indexed fractionalTokenAmount, uint256 indexed lpTokenAmount);
```

### Buy

```solidity
event Buy(uint256 indexed inputAmount, uint256 indexed outputAmount);
```

### Sell

```solidity
event Sell(uint256 indexed inputAmount, uint256 indexed outputAmount);
```

### Wrap

```solidity
event Wrap(uint256[] indexed tokenIds);
```

### Unwrap

```solidity
event Unwrap(uint256[] indexed tokenIds);
```

### Close

```solidity
event Close(uint256 indexed closeTimestamp);
```

### Withdraw

```solidity
event Withdraw(uint256 indexed tokenId);
```

