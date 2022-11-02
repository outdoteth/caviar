// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "solmate/tokens/ERC20.sol";

import "./Pair.sol";
import "./lib/SafeERC20Namer.sol";

contract Caviar {
    using SafeERC20Namer for address;

    // pairs[nft][baseToken][merkleRoot] -> pair
    mapping(address => mapping(address => mapping(bytes32 => address))) public pairs;

    function create(address nft, address baseToken, bytes32 merkleRoot) public returns (Pair) {
        // check that the pair doesn't already exist
        require(pairs[nft][baseToken][merkleRoot] == address(0), "Pair already exists");

        // deploy the pair
        string memory baseTokenSymbol = baseToken == address(0) ? "ETH" : baseToken.tokenSymbol();
        string memory nftSymbol = nft.tokenSymbol();
        string memory nftName = nft.tokenName();
        string memory pairSymbol = string.concat(nftSymbol, ":", baseTokenSymbol);
        Pair pair = new Pair(nft, baseToken, merkleRoot, pairSymbol, nftName, nftSymbol);

        // save the pair
        pairs[nft][baseToken][merkleRoot] = address(pair);

        return pair;
    }
}
