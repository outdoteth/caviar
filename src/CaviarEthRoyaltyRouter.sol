// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "solmate/auth/Owned.sol";
import {IRoyaltyRegistry} from "royalty-registry-solidity/IRoyaltyRegistry.sol";
import "openzeppelin/interfaces/IERC2981.sol";
import "solmate/utils/SafeTransferLib.sol";

import "./Pair.sol";

contract CaviarEthRoyaltyRouter is Owned, ERC721TokenReceiver {
    using SafeTransferLib for address;

    IRoyaltyRegistry public royaltyRegistry;

    constructor(address _royaltyRegistry) Owned(msg.sender) {
        royaltyRegistry = IRoyaltyRegistry(_royaltyRegistry);
    }

    receive() external payable {}

    function setRoyaltyRegistry(address _royaltyRegistry) public onlyOwner {
        royaltyRegistry = IRoyaltyRegistry(_royaltyRegistry);
    }

    function nftBuy(address pair, uint256[] calldata tokenIds, uint256 maxInputAmount, uint256 deadline)
        public
        payable
        returns (uint256 inputAmount)
    {
        // make the swap
        inputAmount = Pair(pair).nftBuy{value: maxInputAmount}(tokenIds, maxInputAmount, deadline);

        // payout the royalties
        address nft = Pair(pair).nft();
        uint256 salePrice = inputAmount / tokenIds.length;
        uint256 totalRoyaltyAmount = _payRoyalties(nft, tokenIds, salePrice);
        inputAmount += totalRoyaltyAmount;

        // transfer the NFTs to the msg.sender
        for (uint256 i = 0; i < tokenIds.length; i++) {
            ERC721(nft).safeTransferFrom(address(this), msg.sender, tokenIds[i]);
        }

        // Refund any surplus ETH
        if (address(this).balance > 0) {
            msg.sender.safeTransferETH(address(this).balance);
        }
    }

    function nftSell(
        address pair,
        uint256[] calldata tokenIds,
        uint256 minOutputAmount,
        uint256 deadline,
        bytes32[][] calldata proofs
    ) public returns (uint256 outputAmount) {
        // transfer the NFTs to this contract
        address nft = Pair(pair).nft();
        for (uint256 i = 0; i < tokenIds.length; i++) {
            ERC721(nft).safeTransferFrom(msg.sender, address(this), tokenIds[i]);
        }

        // approve the pair to transfer nfts from this contract
        _approve(address(nft), pair);

        // make the swap
        outputAmount = Pair(pair).nftSell(tokenIds, minOutputAmount, deadline, proofs);

        // payout the royalties
        uint256 salePrice = outputAmount / tokenIds.length;
        uint256 totalRoyaltyAmount = _payRoyalties(nft, tokenIds, salePrice);
        outputAmount -= totalRoyaltyAmount;

        // Transfer ETH to sender
        msg.sender.safeTransferETH(address(this).balance);
    }

    function _approve(address tokenAddress, address pair) internal {
        if (!ERC721(tokenAddress).isApprovedForAll(address(this), pair)) {
            ERC721(tokenAddress).setApprovalForAll(pair, true);
        }
    }

    function _payRoyalties(address tokenAddress, uint256[] calldata tokenIds, uint256 salePrice)
        internal
        returns (uint256 totalRoyaltyAmount)
    {
        address lookupAddress = royaltyRegistry.getRoyaltyLookupAddress(tokenAddress);

        address recipient;
        totalRoyaltyAmount;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            (address _recipient, uint256 royaltyAmount) = _getRoyalty(lookupAddress, tokenIds[i], salePrice);
            totalRoyaltyAmount += royaltyAmount;
            recipient = _recipient;
        }

        if (totalRoyaltyAmount > 0 && recipient != address(0)) {
            recipient.safeTransferETH(totalRoyaltyAmount);
        }
    }

    function _getRoyalty(address lookupAddress, uint256 tokenId, uint256 salePrice)
        internal
        view
        returns (address recipient, uint256 royaltyAmount)
    {
        if (IERC2981(lookupAddress).supportsInterface(type(IERC2981).interfaceId)) {
            (recipient, royaltyAmount) = IERC2981(lookupAddress).royaltyInfo(tokenId, salePrice);
        }
    }
}
