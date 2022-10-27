// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../shared/Fixture.t.sol";
import "../../src/Caviar.sol";

contract SellTest is Fixture {
    uint256 public inputAmount = 10;
    uint256 public minOutputAmount;

    function setUp() public {
        uint256 baseTokenAmount = 100;
        uint256 fractionalTokenAmount = 30;

        deal(address(usd), address(this), baseTokenAmount, true);
        deal(address(p), address(this), fractionalTokenAmount, true);

        usd.approve(address(p), type(uint256).max);

        uint256 minLpTokenAmount = baseTokenAmount * fractionalTokenAmount;
        p.add(baseTokenAmount, fractionalTokenAmount, minLpTokenAmount);

        minOutputAmount = (inputAmount * p.fractionalTokenReserves()) / (p.baseTokenReserves() + inputAmount);
        deal(address(p), address(this), inputAmount, true);
    }

    function testItReturnsOutputAmount() public {
        // arrange
        uint256 expectedOutputAmount = minOutputAmount;

        // act
        uint256 outputAmount = p.sell(inputAmount, expectedOutputAmount);

        // assert
        assertEq(outputAmount, expectedOutputAmount, "Should have returned output amount");
    }

    function testItTransfersBaseTokens() public {
        // arrange
        uint256 balanceBefore = usd.balanceOf(address(p));
        uint256 thisBalanceBefore = usd.balanceOf(address(this));

        // act
        p.sell(inputAmount, minOutputAmount);

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

    function testItTransfersFractionalTokens() public {
        // arrange
        uint256 balanceBefore = p.balanceOf(address(p));
        uint256 thisBalanceBefore = p.balanceOf(address(this));

        // act
        p.sell(inputAmount, minOutputAmount);

        // assert
        assertEq(
            thisBalanceBefore - p.balanceOf(address(this)),
            inputAmount,
            "Should have transferred fractional tokens from sender"
        );
        assertEq(
            p.balanceOf(address(p)) - balanceBefore, inputAmount, "Should have transferred fractional tokens to pair"
        );
    }

    function testItRevertsSlippageOnSell() public {
        // arrange
        minOutputAmount += 1; // add 1 to cause revert

        // act
        vm.expectRevert("Slippage: amount out is too small");
        p.sell(inputAmount, minOutputAmount);
    }
}
