# Caviar

[Caviar](https://goerli.caviar.sh) is a fully on-chain NFT AMM that allows you to trade every NFT in a collection (from floors to superrares). You can also trade fractional amounts of each NFT too.
It's designed with a heavy emphasis on composability, flexibility and usability. Docs are available [here](https://docs.caviar.sh/technical-reference/high-level-overview).

## Getting started

```
yarn
forge install
forge test --gas-report
```

## Example

```
forge install outdoteth/caviar transmissions11/solmate
```

```solidity
pragma solidity ^0.8.17;

import "caviar/Caviar.sol";
import "caviar/Pair.sol";
import "solmate/tokens/ERC721.sol";

contract ExampleSwapper {
    Pair pair;
    ERC721 nft;

    constructor(address _nft, address _caviar) {
        nft = ERC721(_nft);
        pair = Pair(Caviar(_caviar).pairs(_nft, address(0), bytes32(0)));
    }

    function buyAndSell(uint256[] memory tokenIds, uint256 maxInput, uint256 minOutput) public payable {
        // buy nfts
        pair.nftBuy{value: maxInput}(tokenIds, maxInput);

        // sell nfts
        bytes32[][] memory proofs  = new bytes32[][](0);
        nft.setApprovalForAll(address(pair), true);
        pair.nftSell(tokenIds, minOutput, proofs);
    }
}
```

## Contracts overview

| Contract                   | LOC | Description                                                           |
| -------------------------- | --- | --------------------------------------------------------------------- |
| Caviar.sol                 | 36  | Factory contract that creates pairs and maintains a registry          |
| Pair.sol                   | 294 | Pair contract that contains ERC20 AMM, NFT wrapping and NFT AMM logic |
| LpToken.sol                | 15  | ERC20 token which represents liquidity ownership in pair contracts    |
| SafeERC20Namer.sol         | 65  | Helper contract that fetches the name and symbol of an ERC20/ERC721   |
| CaviarEthRoyaltyRouter.sol | 89  | Router contract that swaps NFTs and pays royalties                    |

**Goerli: ([demo app](https://goerli.caviar.sh))**
