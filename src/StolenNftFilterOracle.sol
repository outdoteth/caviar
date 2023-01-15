// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "reservoir-oracle/ReservoirOracle.sol";

/// @title StolenNftFilterOracle
/// @author out.eth (@outdoteth)
/// @notice A contract to check that a set of NFTs are not stolen.
contract StolenNftFilterOracle is ReservoirOracle {
    bytes32 private constant TOKEN_TYPE_HASH = keccak256("Token(address contract,uint256 tokenId)");

    constructor() ReservoirOracle(0x32dA57E736E05f75aa4FaE2E9Be60FD904492726) {}

    /// @notice Checks that a set of NFTs are not stolen.
    /// @param tokenAddress The address of the NFT contract.
    /// @param tokenIds The ids of the NFTs.
    /// @param messages The messages signed by the reservoir oracle.
    function validateTokensAreNotStolen(address tokenAddress, uint256[] calldata tokenIds, Message[] calldata messages)
        public
        view
    {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            Message calldata message = messages[i];

            // check that the signer is correct and message id matches token id + token address
            uint256 validFor = 60 minutes;
            bytes32 expectedMessageId = keccak256(abi.encode(TOKEN_TYPE_HASH, tokenAddress, tokenIds[i]));
            require(_verifyMessage(expectedMessageId, validFor, message), "Message has invalid signature");

            (bool isFlagged,) = abi.decode(message.payload, (bool, uint256));

            // check that the NFT is not stolen
            require(!isFlagged, "NFT is flagged as suspicious");
        }
    }
}
