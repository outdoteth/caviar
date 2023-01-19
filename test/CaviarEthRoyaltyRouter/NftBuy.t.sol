// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "reservoir-oracle/ReservoirOracle.sol";

import "../shared/Fixture.t.sol";

contract NftBuyCaviarEthRoyaltyTest is Fixture {
    uint256 public outputAmount;
    uint256 public maxInputAmount;
    uint256[] public tokenIds;
    bytes32[][] public proofs;
    ReservoirOracle.Message[] public messages;

    function setUp() public {
        for (uint256 i = 0; i < 5; i++) {
            bayc.mint(address(this), i);
            tokenIds.push(i);
        }

        bayc.setApprovalForAll(address(ethPair), true);

        uint256 baseTokenAmount = 3.15e18;
        uint256 minLpTokenAmount = Math.sqrt(baseTokenAmount * tokenIds.length * 1e18) - 100_000;
        deal(address(this), baseTokenAmount);
        ethPair.nftAdd{value: baseTokenAmount}(
            baseTokenAmount, tokenIds, minLpTokenAmount, 0, 0, type(uint256).max, proofs, messages
        );

        tokenIds.pop();
        tokenIds.pop();
        outputAmount = tokenIds.length * 1e18;
        maxInputAmount = (outputAmount * ethPair.baseTokenReserves() * 1000)
            / ((ethPair.fractionalTokenReserves() - outputAmount) * 990) + 1;
        deal(address(this), type(uint256).max / 10);
    }

    function testItReturnsInputAmount() public {
        // arrange
        uint256 royaltyAmount = maxInputAmount * 10 / 100; // 10% royalty fee
        uint256 expectedInputAmount = maxInputAmount + royaltyAmount;

        // act
        uint256 inputAmount =
            router.nftBuy{value: maxInputAmount + royaltyAmount}(address(ethPair), tokenIds, maxInputAmount, 0);

        // assert
        assertApproxEqAbs(inputAmount, expectedInputAmount, 100, "Should have returned input amount");
    }

    function testItTransfersNfts() public {
        // act
        uint256 royaltyAmount = maxInputAmount * 10 / 100; // 10% royalty fee
        router.nftBuy{value: maxInputAmount + royaltyAmount}(address(ethPair), tokenIds, maxInputAmount, 0);

        // assert
        for (uint256 i = 0; i < tokenIds.length; i++) {
            assertEq(bayc.ownerOf(i), address(this), "Should have sent bayc to sender");
        }
    }

    function testItRefundsSurplusEth() public {
        // arrange
        uint256 royaltyAmount = maxInputAmount * 10 / 100; // 10% royalty fee
        uint256 surplus = 1e18;
        uint256 expectedBalance = address(this).balance - (maxInputAmount + royaltyAmount);

        // act
        router.nftBuy{value: maxInputAmount + royaltyAmount + surplus}(address(ethPair), tokenIds, maxInputAmount, 0);

        // assert
        assertApproxEqAbs(address(this).balance, expectedBalance, 100, "Should have refunded surplus eth");
    }

    function testItTransfersRoyalties() public {
        // arrange
        uint256 royaltyAmount = maxInputAmount * 10 / 100; // 10% royalty fee
        uint256 expectedBalance = address(this).balance - (maxInputAmount + royaltyAmount);

        // act
        router.nftBuy{value: maxInputAmount + royaltyAmount}(address(ethPair), tokenIds, maxInputAmount, 0);

        // assert
        assertApproxEqAbs(address(this).balance, expectedBalance, 100, "Should have sent royalty amount");
        assertApproxEqAbs(
            address(0xbeefbeef).balance, royaltyAmount, 100, "Should have sent royalty amount to recipient"
        );
    }
}
