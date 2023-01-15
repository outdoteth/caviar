// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "solmate/tokens/ERC721.sol";

import "../../shared/Fixture.t.sol";
import "../../../src/Caviar.sol";
import "reservoir-oracle/ReservoirOracle.sol";

contract WrapTest is Fixture {
    event Wrap(uint256[] indexed tokenIds);

    uint256[] public tokenIds;
    bytes32[][] public proofs;
    ReservoirOracle.Message[] public messages;

    function setUp() public {
        bayc.setApprovalForAll(address(p), true);

        for (uint256 i = 0; i < 5; i++) {
            bayc.mint(address(this), i);
            tokenIds.push(i);
        }
    }

    function testItTransfersTokens() public {
        // act
        p.wrap(tokenIds, proofs, messages);

        // assert
        for (uint256 i = 0; i < tokenIds.length; i++) {
            assertEq(bayc.ownerOf(i), address(p), "Should have sent bayc to pair");
        }
    }

    function testItMintsFractionalTokens() public {
        // arrange
        uint256 expectedFractionalTokens = tokenIds.length * 1e18;

        // act
        p.wrap(tokenIds, proofs, messages);

        // assert
        assertEq(p.balanceOf(address(this)), expectedFractionalTokens, "Should have minted fractional tokens to sender");
        assertEq(p.totalSupply(), expectedFractionalTokens, "Should have minted fractional tokens");
    }

    function testItEmitsWrapEvent() public {
        // act
        vm.expectEmit(true, true, true, true);
        emit Wrap(tokenIds);
        p.wrap(tokenIds, proofs, messages);
    }

    function testItAddsWithMerkleProof() public {
        // arrange
        Pair pair = createPairScript.create(address(bayc), address(usd), "YEET-mids.json", address(c));
        proofs = createPairScript.generateMerkleProofs("YEET-mids.json", tokenIds);
        bayc.setApprovalForAll(address(pair), true);

        // act
        pair.wrap(tokenIds, proofs, messages);

        // assert
        for (uint256 i = 0; i < tokenIds.length; i++) {
            assertEq(bayc.ownerOf(i), address(pair), "Should have sent bayc to pair");
        }
    }

    function testItValidatesTokensAreNotStolenMessage() public {
        // arrange
        address milady = 0x5Af0D9827E0c53E4799BB226655A1de152A425a5;
        vm.etch(milady, address(bayc).code);
        vm.mockCall(milady, abi.encodeWithSignature("safeTransferFrom(address,address,uint256)"), abi.encode(true));
        c.setStolenNftFilterOracle(address(stolenNftFilterOracle));

        uint256 tokenId = 5;
        Pair pair = c.create(milady, address(0), bytes32(0));

        bytes32 id = 0x48162c6fe421732f8db386e8b17f8d0d5dff7aea3cbc7ea49e9514dfe561b9d6;
        bytes memory payload =
            hex"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000062437f50";
        uint256 timestamp = 1673728205;
        bytes memory signature =
            hex"927564156c1222f49935ef692fd63d2cc2976d7f3b3db55c0cfd0184d47d0308337ae730d740628a92aff17601d7f4982ba8da3b59a03ad62fdab1f8a8ec6f891c";

        vm.warp(timestamp + 1);

        ReservoirOracle.Message[] memory _messages = new ReservoirOracle.Message[](1);
        _messages[0] = ReservoirOracle.Message({id: id, payload: payload, timestamp: timestamp, signature: signature});

        uint256[] memory _tokenIds = new uint256[](1);
        _tokenIds[0] = tokenId;

        // act
        pair.wrap(_tokenIds, proofs, _messages);
    }

    function testItRevertsIfTokensAreStolen() public {
        // arrange
        address _bayc = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;
        vm.etch(_bayc, address(bayc).code);
        vm.mockCall(_bayc, abi.encodeWithSignature("safeTransferFrom(address,address,uint256)"), abi.encode(true));
        c.setStolenNftFilterOracle(address(stolenNftFilterOracle));

        uint256 tokenId = 4688;
        Pair pair = c.create(_bayc, address(0), bytes32(0));

        bytes32 id = 0xc60857351955a28a993550dae0fc27970d8f64edaf49824dbf56f8558433e7b7;
        bytes memory payload =
            hex"00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000062878552";
        uint256 timestamp = 1673730872;
        bytes memory signature =
            hex"1a71945062cdec7e7b13214acb9968da4ff8d4a667d6f440bfa792a99a6a7e2a62e0f1b49e21124e43bc48c318da249b7780bce0a736f95e660f43bd74c9145d1c";

        vm.warp(timestamp + 1);

        ReservoirOracle.Message[] memory _messages = new ReservoirOracle.Message[](1);
        _messages[0] = ReservoirOracle.Message({id: id, payload: payload, timestamp: timestamp, signature: signature});

        uint256[] memory _tokenIds = new uint256[](1);
        _tokenIds[0] = tokenId;

        // act
        vm.expectRevert("NFT is flagged as suspicious");
        pair.wrap(_tokenIds, proofs, _messages);
    }
}
