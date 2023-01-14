// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "reservoir-oracle/ReservoirOracle.sol";

import "../../shared/Fixture.t.sol";
import "../../../src/Caviar.sol";

contract NftSellTest is Fixture {
    uint256 public minOutputAmount;
    uint256[] public tokenIds;
    bytes32[][] public proofs;
    ReservoirOracle.Message[] public messages;

    function setUp() public {
        uint256 baseTokenAmount = 69.69e18;
        uint256 fractionalTokenAmount = 420.42e18;

        deal(address(usd), address(this), baseTokenAmount, true);
        deal(address(p), address(this), fractionalTokenAmount, true);
        usd.approve(address(p), type(uint256).max);

        uint256 minLpTokenAmount = Math.sqrt(baseTokenAmount * fractionalTokenAmount) - 1000;
        p.add(baseTokenAmount, fractionalTokenAmount, minLpTokenAmount, 0, type(uint256).max, 0);

        for (uint256 i = 0; i < 5; i++) {
            bayc.mint(address(this), i);
            tokenIds.push(i);
        }

        bayc.setApprovalForAll(address(p), true);

        minOutputAmount = (tokenIds.length * 1e18 * 990 * p.baseTokenReserves())
            / (p.fractionalTokenReserves() * 1000 + tokenIds.length * 1e18 * 990);
    }

    function testItReturnsOutputAmount() public {
        // arrange
        uint256 expectedOutputAmount = minOutputAmount;

        // act
        uint256 outputAmount = p.nftSell(tokenIds, expectedOutputAmount, 0, proofs, messages);

        // assert
        assertEq(outputAmount, expectedOutputAmount, "Should have returned output amount");
    }

    function testItTransfersBaseTokens() public {
        // arrange
        uint256 balanceBefore = usd.balanceOf(address(p));
        uint256 thisBalanceBefore = usd.balanceOf(address(this));

        // act
        p.nftSell(tokenIds, minOutputAmount, 0, proofs, messages);

        // assert
        assertEq(
            balanceBefore - usd.balanceOf(address(p)), minOutputAmount, "Should have transferred base tokens from pair"
        );

        assertEq(
            usd.balanceOf(address(this)) - thisBalanceBefore,
            minOutputAmount,
            "Should have transferred base tokens to sender"
        );
    }

    function testItTransfersNfts() public {
        // act
        p.nftSell(tokenIds, minOutputAmount, 0, proofs, messages);

        // assert
        for (uint256 i = 0; i < tokenIds.length; i++) {
            assertEq(bayc.ownerOf(i), address(p), "Should have sent bayc to pair");
        }
    }

    function testItRevertsSlippageOnSell() public {
        // arrange
        minOutputAmount += 1; // add 1 to cause revert

        // act
        vm.expectRevert("Slippage: amount out");
        p.nftSell(tokenIds, minOutputAmount, 0, proofs, messages);
    }

    function testItRevertsIfDeadlinePassed() public {
        // arrange
        skip(100);
        uint256 deadline = block.timestamp - 1;

        // act
        vm.expectRevert("Expired");
        p.nftSell(tokenIds, minOutputAmount, deadline, proofs, messages);
    }

    function testItMintsFractionalTokens() public {
        // arrange
        uint256 totalSupplyBefore = p.totalSupply();
        uint256 balanceBefore = p.balanceOf(address(p));

        // act
        p.nftSell(tokenIds, minOutputAmount, 0, proofs, messages);

        // assert
        assertEq(p.totalSupply() - totalSupplyBefore, tokenIds.length * 1e18, "Should have minted fractional tokens");
        assertEq(
            p.balanceOf(address(p)) - balanceBefore,
            tokenIds.length * 1e18,
            "Should have minted fractional tokens to pair"
        );
    }

    function testItSellsWithMerkleProof() public {
        Pair pair = createPairScript.create(address(bayc), address(usd), "YEET-mids.json", address(c));

        uint256 baseTokenAmount = 69.69e18;
        uint256 fractionalTokenAmount = 420.42e18;

        deal(address(usd), address(this), baseTokenAmount, true);
        deal(address(pair), address(this), fractionalTokenAmount, true);
        usd.approve(address(pair), type(uint256).max);

        uint256 minLpTokenAmount = Math.sqrt(baseTokenAmount * fractionalTokenAmount) - 1000;
        pair.add(baseTokenAmount, fractionalTokenAmount, minLpTokenAmount, 0, type(uint256).max, 0);

        proofs = createPairScript.generateMerkleProofs("YEET-mids.json", tokenIds);
        bayc.setApprovalForAll(address(pair), true);

        // act
        pair.nftSell(tokenIds, minOutputAmount, 0, proofs, messages);

        // assert
        for (uint256 i = 0; i < tokenIds.length; i++) {
            assertEq(bayc.ownerOf(tokenIds[i]), address(pair), "Should have sent bayc to pair");
        }
    }
}
