// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../shared/Fixture.t.sol";

contract NftSellCaviarEthRoyaltyTest is Fixture {
    uint256 public minOutputAmount;
    uint256[] public tokenIds;
    bytes32[][] public proofs;

    function setUp() public {
        uint256 baseTokenAmount = 69.69e18;
        uint256 fractionalTokenAmount = 420.42e18;

        deal(address(this), type(uint256).max / 10);
        deal(address(ethPair), address(this), fractionalTokenAmount, true);

        uint256 minLpTokenAmount = Math.sqrt(baseTokenAmount * fractionalTokenAmount) - 1000;
        ethPair.add{value: baseTokenAmount}(
            baseTokenAmount, fractionalTokenAmount, minLpTokenAmount, 0, type(uint256).max, 0
        );

        for (uint256 i = 0; i < 5; i++) {
            bayc.mint(address(this), i);
            tokenIds.push(i);
        }

        bayc.setApprovalForAll(address(router), true);

        minOutputAmount = (tokenIds.length * 1e18 * 990 * ethPair.baseTokenReserves())
            / (ethPair.fractionalTokenReserves() * 1000 + tokenIds.length * 1e18 * 990);
    }

    function testItReturnsOutputAmount() public {
        // arrange
        uint256 royalty = minOutputAmount / 10;
        uint256 expectedOutputAmount = minOutputAmount - royalty;

        // act
        uint256 outputAmount = router.nftSell(address(ethPair), tokenIds, expectedOutputAmount, 0, proofs);

        // assert
        assertApproxEqAbs(outputAmount, expectedOutputAmount, 20, "Should have returned output amount");
    }

    function testItReturnsEth() public {
        // arrange
        uint256 royalty = minOutputAmount / 10;
        uint256 expectedOutputAmount = minOutputAmount - royalty;
        uint256 balanceBefore = address(this).balance;

        // act
        router.nftSell(address(ethPair), tokenIds, minOutputAmount, 0, proofs);

        // assert
        assertApproxEqAbs(address(this).balance - balanceBefore, expectedOutputAmount, 20, "Should have returned eth");
    }

    function testItTransfersRoyalties() public {
        // arrange
        uint256 royalty = minOutputAmount / 10;

        // act
        router.nftSell(address(ethPair), tokenIds, minOutputAmount, 0, proofs);

        // assert
        assertApproxEqAbs(address(0xbeefbeef).balance, royalty, 20, "Should have sent eth to royalty recipient");
    }
}
