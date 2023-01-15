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
        address milady = 0xF0a8d1c9eB9FCde3221FEAfA4BD525771687BD10;
        vm.etch(milady, address(bayc).code);
        vm.mockCall(milady, abi.encodeWithSignature("safeTransferFrom(address,address,uint256)"), abi.encode(true));
        c.setStolenNftFilterOracle(address(stolenNftFilterOracle));

        uint256 tokenId = 63;
        Pair pair = c.create(milady, address(0), bytes32(0));

        bytes32 id = 0x026b8d21dd591b867de9a6dfab63e879ab848dadd218fb7d8f30a40847786c12;
        bytes memory payload =
            hex"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        uint256 timestamp = 1673822403;
        bytes memory signature =
            hex"a7538e541c899f54c4e016c3f971f0ca47e9a8e99ad677835b63210c9187565701283bf2d457cdd964f6b457d1d8887266c57fc5624a76a121b20b9fb98e09981c";

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
