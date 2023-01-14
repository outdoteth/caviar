// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../../shared/Fixture.t.sol";
import "../../../src/Caviar.sol";
import "reservoir-oracle/ReservoirOracle.sol";

contract UnwrapTest is Fixture {
    event Unwrap(uint256[] indexed tokenIds);

    uint256[] public tokenIds;
    bytes32[][] public proofs;
    ReservoirOracle.Message[] public messages;

    function setUp() public {
        bayc.setApprovalForAll(address(p), true);

        for (uint256 i = 0; i < 5; i++) {
            bayc.mint(address(this), i);
            tokenIds.push(i);
        }

        p.wrap(tokenIds, proofs, messages);
    }

    function testItTransfersTokens() public {
        // act
        p.unwrap(tokenIds, false);

        // assert
        for (uint256 i = 0; i < tokenIds.length; i++) {
            assertEq(bayc.ownerOf(i), address(this), "Should have sent bayc to sender");
        }
    }

    function testItBurnsFractionalTokens() public {
        // arrange
        uint256 expectedFractionalTokensBurned = tokenIds.length * 1e18;
        uint256 balanceBefore = p.balanceOf(address(this));
        uint256 totalSupplyBefore = p.totalSupply();

        // act
        p.unwrap(tokenIds, false);

        // assert
        assertEq(
            balanceBefore - p.balanceOf(address(this)),
            expectedFractionalTokensBurned,
            "Should have burned fractional tokens from sender"
        );

        assertEq(
            totalSupplyBefore - p.totalSupply(), expectedFractionalTokensBurned, "Should have burned fractional tokens"
        );
    }

    function testItUnwrapsWithFee() public {
        // arrange
        tokenIds.pop();
        uint256 expectedFractionalTokensBurned = tokenIds.length * 1e18;
        uint256 pairBalanceBefore = p.balanceOf(address(p));
        uint256 balanceBefore = p.balanceOf(address(this));
        uint256 totalSupplyBefore = p.totalSupply();
        uint256 fee = (expectedFractionalTokensBurned * 3) / 1000;

        // act
        p.unwrap(tokenIds, true);

        // assert
        assertEq(
            balanceBefore - p.balanceOf(address(this)),
            expectedFractionalTokensBurned + fee,
            "Should have burned fractional tokens from sender"
        );

        assertEq(p.balanceOf(address(p)) - pairBalanceBefore, fee, "Should have transferred fee to pair");

        assertEq(
            totalSupplyBefore - p.totalSupply(), expectedFractionalTokensBurned, "Should have burned fractional tokens"
        );
    }

    function testItEmitsUnwrapEvent() public {
        // act
        vm.expectEmit(true, true, true, true);
        emit Unwrap(tokenIds);
        p.unwrap(tokenIds, false);
    }
}
