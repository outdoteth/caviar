# Caviar
[Git Source](https://github.com/outdoteth/Caviar/blob/fe772f95d422ab3b2897f7403c37b8326c5a1bbf/src/Caviar.sol)

**Inherits:**
Owned

**Author:**
out.eth (@outdoteth)

An AMM for creating and trading fractionalized NFTs.


## State Variables
### pairs
*pairs[nft][baseToken][merkleRoot] -> pair*


```solidity
mapping(address => mapping(address => mapping(bytes32 => address))) public pairs;
```


### stolenNftFilterOracle
*The stolen nft filter oracle address*


```solidity
address public stolenNftFilterOracle;
```


## Functions
### constructor


```solidity
constructor(address _stolenNftFilterOracle) Owned(msg.sender);
```

### setStolenNftFilterOracle

Sets the stolen nft filter oracle address.


```solidity
function setStolenNftFilterOracle(address _stolenNftFilterOracle) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stolenNftFilterOracle`|`address`|The stolen nft filter oracle address.|


### create

Creates a new pair.


```solidity
function create(address nft, address baseToken, bytes32 merkleRoot) public returns (Pair pair);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`nft`|`address`|The NFT contract address.|
|`baseToken`|`address`|The base token contract address.|
|`merkleRoot`|`bytes32`|The merkle root for the valid tokenIds.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`pair`|`Pair`|The address of the new pair.|


### destroy

Deletes the pair for the given NFT, base token, and merkle root.


```solidity
function destroy(address nft, address baseToken, bytes32 merkleRoot) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`nft`|`address`|The NFT contract address.|
|`baseToken`|`address`|The base token contract address.|
|`merkleRoot`|`bytes32`|The merkle root for the valid tokenIds.|


## Events
### SetStolenNftFilterOracle

```solidity
event SetStolenNftFilterOracle(address indexed stolenNftFilterOracle);
```

### Create

```solidity
event Create(address indexed nft, address indexed baseToken, bytes32 indexed merkleRoot);
```

### Destroy

```solidity
event Destroy(address indexed nft, address indexed baseToken, bytes32 indexed merkleRoot);
```

