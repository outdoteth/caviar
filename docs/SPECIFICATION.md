# Specification

The AMM is split into three distinct logical parts. The core AMM, NFT wrapping, and the NFT AMM itself. The core AMM is a stripped down version of [UNI-V2](https://github.com/Uniswap/v2-core) that handles swapping between a base token (such as WETH or USDC) and a fractional NFT token. The NFT wrapping logic lets you wrap NFTs and receive ERC20 fractional tokens - or vice versa. The NFT AMM logic is a set of helper functions that wrap around the core AMM and the NFT wrapping logic.

## Core AMM

The core AMM is comprised of four functions:

```solidity
add(uint256 baseTokenAmount, uint256 fractionalTokenAmount, uint256 minLpTokenAmount)
remove(uint256 lpTokenAmount, uint256 minBaseTokenOutputAmount, uint256 minFractionalTokenOutputAmount)
buy(uint256 outputAmount, uint256 maxInputAmount)
sell(uint256 inputAmount, uint256 minOutputAmount)
```

A liquidity provider can add liquidity by depositing some amount of base tokens and ERC20 fractional tokens.
In return they are minted some amount of an LP token to represent their share of liquidity in the pool.

They can also remove base tokens and fractional tokens by burning their LP token.

Traders can buy from the pool by sending an amount of base tokens. In return they will receive fractional ERC20 tokens.

Traders can sell from the pool by sending an amount of fractional tokens. In return they will receive base tokens.

Traders pay a 30bps (0.3%) fee each time they buy or sell. This fee accrues to the liquidity providers and acts as an incentive for people to deposit liquidity.

## NFT wrapping

NFT Wrapping consists of two functions:

```
wrap(uint256[] calldata tokenIds)
unwrap(uint256[] calldata tokenIds)
```

Users can wrap their NFTs and receive ERC20 tokens. 1e18 tokens are minted for each NFT that is wrapped.
Users can unwrap their fractional ERC20 tokens by burning them. In return they will receive N amount of NFTs from the contract.

## NFT AMM

The NFT AMM acts as a container around both the core AMM logic and the NFT wrapping logic.
It is composed of four functions:

```
nftAdd(uint256 baseTokenAmount, uint256[] calldata tokenIds, uint256 minLpTokenAmount, bytes32[][] calldata proofs)
nftRemove(uint256 lpTokenAmount, uint256 minBaseTokenOutputAmount, uint256[] calldata tokenIds, bytes32[][] calldata proofs)
nftBuy(uint256[] calldata tokenIds, uint256 maxInputAmount, bytes32[][] calldata proofs)
nftSell(uint256[] calldata tokenIds, uint256 minOutputAmount, bytes32[][] calldata proofs)
```

Liquidity providers can add their NFTs and base ERC20 tokens as liquidity. They specify which token ids they would like to LP and provide a set of merkle proofs that show the particular tokenIds exist in the merkle root for the pair. In return they are minted some LP tokens.

They can also remove NFTs and base tokens from the pool in a similar fashion - except this time, burning fractional tokens instead of minting them.

Traders can specify which NFTs they would like to buy from the pool, along with a set of proofs showing that those tokenIds are valid. They must send some amount of base tokens to cover the cost of buying. And vice versa for selling.
