// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../shared/Fixture.t.sol";
import "../../src/Caviar.sol";

contract BuyTest is Fixture {
    uint256 public outputAmount = 10;
    uint256 public maxInputAmount;

    function setUp() public {
        uint256 baseTokenAmount = 100;
        uint256 fractionalTokenAmount = 30;

        deal(address(usd), address(this), baseTokenAmount, true);
        deal(address(p), address(this), fractionalTokenAmount, true);

        usd.approve(address(p), type(uint256).max);

        uint256 minLpTokenAmount = baseTokenAmount * fractionalTokenAmount;
        p.add(baseTokenAmount, fractionalTokenAmount, minLpTokenAmount);

        maxInputAmount = (outputAmount * p.baseTokenReserves()) / (p.fractionalTokenReserves() - outputAmount);
        deal(address(usd), address(this), maxInputAmount, true);
    }

    function testItReturnsAmountIn() public {
        // arrange
        uint256 expectedInputAmount = maxInputAmount;

        // act
        uint256 inputAmount = p.buy(outputAmount, maxInputAmount);

        // assert
        assertEq(inputAmount, expectedInputAmount, "Should have returned input amount");
    }

    function testItTransfersBaseTokens() public {
        // arrange
        uint256 balanceBefore = usd.balanceOf(address(p));
        uint256 thisBalanceBefore = usd.balanceOf(address(this));

        // act
        p.buy(outputAmount, maxInputAmount);

        // assert
        assertEq(usd.balanceOf(address(p)) - balanceBefore, maxInputAmount, "Should have transferred base tokens in");
        assertEq(
            thisBalanceBefore - usd.balanceOf(address(this)), maxInputAmount, "Should have transferred base tokens out"
        );
    }

    function testItTransfersFractionalTokens() public {
        // arrange
        uint256 balanceBefore = p.balanceOf(address(p));
        uint256 thisBalanceBefore = p.balanceOf(address(this));

        // act
        p.buy(outputAmount, maxInputAmount);

        // assert
        assertEq(
            p.balanceOf(address(this)) - thisBalanceBefore,
            outputAmount,
            "Should have transferred fractional tokens out"
        );
        assertEq(balanceBefore - p.balanceOf(address(p)), outputAmount, "Should have transferred fractional tokens in");
    }

    function testItRevertsSlippageOnBuy() public {
        // arrange
        maxInputAmount -= 1; // subtract 1 to cause revert

        // act
        vm.expectRevert("Slippage: amount in is too large");
        p.buy(outputAmount, maxInputAmount);
    }
}
