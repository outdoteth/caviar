# StolenNftFilterOracle
[Git Source](https://github.com/outdoteth/Caviar/blob/1be83e69941dba34e584304f87901ad3aa5a1710/src/StolenNftFilterOracle.sol)

**Inherits:**
ReservoirOracle, Owned

**Author:**
out.eth (@outdoteth)

A contract to check that a set of NFTs are not stolen.


## State Variables
### TOKEN_TYPE_HASH

```solidity
bytes32 private constant TOKEN_TYPE_HASH = keccak256("Token(address contract,uint256 tokenId)");
```


### cooldownPeriod

```solidity
uint256 public cooldownPeriod = 0;
```


### validFor

```solidity
uint256 public validFor = 60 minutes;
```


## Functions
### constructor


```solidity
constructor() Owned(msg.sender) ReservoirOracle(0xAeB1D03929bF87F69888f381e73FBf75753d75AF);
```

### setCooldownPeriod

Sets the cooldown period.


```solidity
function setCooldownPeriod(uint256 _cooldownPeriod) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_cooldownPeriod`|`uint256`|The cooldown period.|


### setValidFor

Sets the valid for period.


```solidity
function setValidFor(uint256 _validFor) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_validFor`|`uint256`|The valid for period.|


### updateReservoirOracleAddress


```solidity
function updateReservoirOracleAddress(address newReservoirOracleAddress) public override onlyOwner;
```

### validateTokensAreNotStolen

Checks that a set of NFTs are not stolen.


```solidity
function validateTokensAreNotStolen(address tokenAddress, uint256[] calldata tokenIds, Message[] calldata messages)
    public
    view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenAddress`|`address`|The address of the NFT contract.|
|`tokenIds`|`uint256[]`|The ids of the NFTs.|
|`messages`|`Message[]`|The messages signed by the reservoir oracle.|


