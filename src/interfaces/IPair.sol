// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IPair {
    function nftBuy(uint256[] calldata tokenIds, uint256 maxInputAmount, bytes32[][] calldata proofs)
        external
        payable
        returns (uint256);

    function nftSell(uint256[] calldata tokenIds, uint256 minOutputAmount, bytes32[][] calldata proofs)
        external
        returns (uint256);
}
