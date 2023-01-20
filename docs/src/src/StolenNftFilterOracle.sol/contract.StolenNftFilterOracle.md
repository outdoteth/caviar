# StolenNftFilterOracle
[Git Source](https://github.com/outdoteth/Caviar/blob/fe772f95d422ab3b2897f7403c37b8326c5a1bbf/src/StolenNftFilterOracle.sol)

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
constructor() Owned(msg.sender) ReservoirOracle(0x32dA57E736E05f75aa4FaE2E9Be60FD904492726);
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


