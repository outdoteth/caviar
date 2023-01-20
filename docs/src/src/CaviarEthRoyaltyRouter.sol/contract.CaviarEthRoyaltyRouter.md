# CaviarEthRoyaltyRouter
[Git Source](https://github.com/outdoteth/Caviar/blob/fe772f95d422ab3b2897f7403c37b8326c5a1bbf/src/CaviarEthRoyaltyRouter.sol)

**Inherits:**
Owned, ERC721TokenReceiver

**Author:**
out.eth

This contract is used to swap NFTs and pay royalties.


## State Variables
### royaltyRegistry
The royalty registry from manifold.xyz.


```solidity
IRoyaltyRegistry public royaltyRegistry;
```


## Functions
### constructor


```solidity
constructor(address _royaltyRegistry) Owned(msg.sender);
```

### receive


```solidity
receive() external payable;
```

### setRoyaltyRegistry

Set the royalty registry.


```solidity
function setRoyaltyRegistry(address _royaltyRegistry) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_royaltyRegistry`|`address`|The new royalty registry.|


### nftBuy

Make a buy and pay royalties.


```solidity
function nftBuy(address pair, uint256[] calldata tokenIds, uint256 maxInputAmount, uint256 deadline)
    public
    payable
    returns (uint256 inputAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pair`|`address`|The pair address.|
|`tokenIds`|`uint256[]`|The tokenIds to buy.|
|`maxInputAmount`|`uint256`|The maximum amount of ETH to spend.|
|`deadline`|`uint256`|The deadline for the swap.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`inputAmount`|`uint256`|The amount of ETH spent.|


### nftSell

Sell NFTs and pay royalties.


```solidity
function nftSell(
    address pair,
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
|`pair`|`address`|The pair address.|
|`tokenIds`|`uint256[]`|The tokenIds to sell.|
|`minOutputAmount`|`uint256`|The minimum amount of ETH to receive.|
|`deadline`|`uint256`|The deadline for the swap.|
|`proofs`|`bytes32[][]`|The proofs for the NFTs.|
|`messages`|`Message.ReservoirOracle[]`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`outputAmount`|`uint256`|The amount of ETH received.|


### getRoyaltyRate

Get the royalty rate with 18 decimals of precision for a specific NFT collection.


```solidity
function getRoyaltyRate(address tokenAddress) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenAddress`|`address`|The NFT address.|


### _approve

Approves the pair for transfering NFTs from this contract.


```solidity
function _approve(address tokenAddress, address pair) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenAddress`|`address`|The NFT address.|
|`pair`|`address`|The pair address.|


### _payRoyalties

Pay royalties for a list of NFTs at a specified price for each NFT.


```solidity
function _payRoyalties(address tokenAddress, uint256[] calldata tokenIds, uint256 salePrice)
    internal
    returns (uint256 totalRoyaltyAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenAddress`|`address`|The NFT address.|
|`tokenIds`|`uint256[]`|The tokenIds to pay royalties for.|
|`salePrice`|`uint256`|The sale price for each NFT.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`totalRoyaltyAmount`|`uint256`|The total amount of royalties paid.|


### _getRoyalty

Get the royalty for a specific NFT.


```solidity
function _getRoyalty(address lookupAddress, uint256 tokenId, uint256 salePrice)
    internal
    view
    returns (address recipient, uint256 royaltyAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`lookupAddress`|`address`|The lookup address for the NFT royalty info.|
|`tokenId`|`uint256`|The tokenId to get the royalty for.|
|`salePrice`|`uint256`|The sale price for the NFT.|


