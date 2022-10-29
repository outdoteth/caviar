// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "solmate/tokens/ERC20.sol";
import "forge-std/console.sol";

import "./Pair.sol";
import "./SafeERC20Namer.sol";

contract Caviar {
    using SafeERC20Namer for address;

    function create(address nft, address baseToken) public returns (Pair) {
        string memory baseTokenSymbol = baseToken == address(0) ? "ETH" : baseToken.tokenSymbol();
        string memory nftSymbol = nft.tokenSymbol();
        string memory nftName = nft.tokenName();
        string memory pairSymbol = string.concat(nftSymbol, ":", baseTokenSymbol);

        return new Pair(nft, baseToken, pairSymbol, nftName, nftSymbol);
    }
}
