# Caviar

[Caviar](https://goerli.caviar.sh) is a fully on-chain NFT AMM that allows you to trade every NFT in a collection (from floors to superrares). You can also trade fractional amounts of each NFT too.
It's designed with a heavy emphasis on composability, flexibility and usability.

## Index

- [Specification](./docs/SPECIFICATION.md)

- [Testing](./docs/TESTING.md)

- [Security considerations](./docs/SECURITY.md)

## Getting started

```
forge install
forge test --gas-report
```

## Contracts overview

| Contract           | LOC | Description                                                           |
| ------------------ | --- | --------------------------------------------------------------------- |
| Caviar.sol         | 26  | Factory contract that creates pairs and maintains a registry          |
| Pair.sol           | 212 | Pair contract that contains ERC20 AMM, NFT wrapping and NFT AMM logic |
| LpToken.sol        | 15  | ERC20 token which represents liquidity ownership in pair contracts    |
| SafeERC20Namer.sol | 65  | Helper contract that fetches the name and symbol of an ERC20/ERC721   |

## Deployments

**Goerli: ([demo app](https://goerli.caviar.sh))**

| Contract              | Address                                                                                                                      |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Caviar                | [0x4442fD4a38c6FBe364AdC6FF2CFA9332F0E7D378](https://goerli.etherscan.io/address/0x4442fD4a38c6FBe364AdC6FF2CFA9332F0E7D378) |
| FBAYC                 | [0xC1A308D95344716054d4C078831376FC78c4fd72](https://goerli.etherscan.io/address/0xC1A308D95344716054d4C078831376FC78c4fd72) |
| Pair (Rare FBAYC:ETH) | [0x7033A7A1980e019BA6A2016a14b3CD783e35300a](https://goerli.etherscan.io/address/0x7033A7A1980e019BA6A2016a14b3CD783e35300a) |
| LP Token (FBAYC:ETH)  | [0x96E6B35Cc73070FCDB42Abe5a39BfD7f16c37cFc](https://goerli.etherscan.io/address/0x96E6B35Cc73070FCDB42Abe5a39BfD7f16c37cFc) |
