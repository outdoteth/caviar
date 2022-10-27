// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../shared/Fixture.t.sol";
import "../../src/Caviar.sol";

contract AddTest is Fixture {
    uint256 baseTokenAmount = 100;
    uint256 fractionalTokenAmount = 30;

    function setUp() public {
        deal(address(usd), address(this), baseTokenAmount, true);
        deal(address(p), address(this), fractionalTokenAmount, true);

        usd.approve(address(p), type(uint256).max);
    }

    function testItInitMintsLpTokensToSender() public {
        // arrange
        uint256 minLpTokenAmount = baseTokenAmount * fractionalTokenAmount;
        uint256 expectedLpTokenAmount = baseTokenAmount * fractionalTokenAmount;

        // act
        uint256 lpTokenAmount = p.add(baseTokenAmount, fractionalTokenAmount, minLpTokenAmount);

        // assert
        assertEq(lpTokenAmount, expectedLpTokenAmount, "Should have returned correct lp token amount");
        assertEq(lpToken.balanceOf(address(this)), expectedLpTokenAmount, "Should have minted lp tokens");
        assertEq(lpToken.totalSupply(), expectedLpTokenAmount, "Should have increased lp supply");
    }

    function testItTransfersBaseTokens() public {
        // arrange
        uint256 minLpTokenAmount = baseTokenAmount * fractionalTokenAmount;
        uint256 balanceBefore = usd.balanceOf(address(this));

        // act
        p.add(baseTokenAmount, fractionalTokenAmount, minLpTokenAmount);

        // assert
        uint256 balanceAfter = usd.balanceOf(address(this));
        assertEq(balanceBefore - balanceAfter, baseTokenAmount, "Should transferred base tokens from sender");
        assertEq(usd.balanceOf(address(p)), baseTokenAmount, "Should have transferred base tokens to pair");
    }

    function testItTransfersFractionalTokens() public {
        // arrange
        uint256 minLpTokenAmount = baseTokenAmount * fractionalTokenAmount;
        uint256 balanceBefore = p.balanceOf(address(this));

        // act
        p.add(baseTokenAmount, fractionalTokenAmount, minLpTokenAmount);

        // assert
        assertEq(p.balanceOf(address(p)), fractionalTokenAmount, "Should have transferred fractional tokens to pair");
        assertEq(
            balanceBefore - p.balanceOf(address(this)),
            fractionalTokenAmount,
            "Should transferred fractional tokens from sender"
        );
    }

    function testItRevertsSlippageOnInitMint() public {
        // arrange
        uint256 minLpTokenAmount = (baseTokenAmount * fractionalTokenAmount) + 1; // increase 1 to cause revert

        // act
        vm.expectRevert("Slippage: Insufficient lp token output amount");
        p.add(baseTokenAmount, fractionalTokenAmount, minLpTokenAmount);
    }

    function testItMintsLpTokensAfterInit() public {
        // arrange
        uint256 minLpTokenAmount = baseTokenAmount * fractionalTokenAmount;
        p.add(baseTokenAmount, fractionalTokenAmount, minLpTokenAmount); // initial add
        uint256 lpTokenSupplyBefore = lpToken.totalSupply();

        uint256 expectedLpTokenAmount = baseTokenAmount * fractionalTokenAmount * 17;
        minLpTokenAmount = expectedLpTokenAmount;
        baseTokenAmount = baseTokenAmount * 17;
        fractionalTokenAmount = fractionalTokenAmount * 17;
        deal(address(usd), babe, baseTokenAmount, true);
        deal(address(p), babe, fractionalTokenAmount, true);

        // act
        vm.startPrank(babe);
        usd.approve(address(p), type(uint256).max);
        uint256 lpTokenAmount = p.add(baseTokenAmount, fractionalTokenAmount, minLpTokenAmount);
        vm.stopPrank();

        // assert
        assertEq(lpTokenAmount, expectedLpTokenAmount, "Should have returned correct lp token amount");
        assertEq(lpToken.balanceOf(babe), expectedLpTokenAmount, "Should have minted lp tokens");
        assertEq(lpToken.totalSupply() - lpTokenSupplyBefore, expectedLpTokenAmount, "Should have increased lp supply");
    }

    function testItRevertsSlippageAfterInitMint() public {
        // arrange
        uint256 minLpTokenAmount = baseTokenAmount * fractionalTokenAmount;
        p.add(baseTokenAmount, fractionalTokenAmount, minLpTokenAmount); // initial add

        minLpTokenAmount = (baseTokenAmount * fractionalTokenAmount * 17) + 1; // add 1 to cause a revert
        baseTokenAmount = baseTokenAmount * 17;
        fractionalTokenAmount = fractionalTokenAmount * 17;

        // act
        vm.expectRevert("Slippage: Insufficient lp token output amount");
        p.add(baseTokenAmount, fractionalTokenAmount, minLpTokenAmount);
    }
}
