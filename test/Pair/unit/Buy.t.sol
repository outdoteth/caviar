// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../../shared/Fixture.t.sol";
import "../../../src/Caviar.sol";

contract BuyTest is Fixture {
    using stdStorage for StdStorage;

    event Buy(uint256 indexed inputAmount, uint256 indexed outputAmount);

    uint256 public outputAmount = 0.1e18;
    uint256 public maxInputAmount;

    function setUp() public {
        uint256 baseTokenAmount = 100e18;
        uint256 fractionalTokenAmount = 30.123e18;

        deal(address(usd), address(this), baseTokenAmount, true);
        deal(address(p), address(this), fractionalTokenAmount, true);

        usd.approve(address(p), type(uint256).max);

        uint256 minLpTokenAmount = Math.sqrt(baseTokenAmount * fractionalTokenAmount) - 1000;
        p.add(baseTokenAmount, fractionalTokenAmount, minLpTokenAmount, 0, type(uint256).max, 0);

        maxInputAmount =
            (outputAmount * p.baseTokenReserves() * 1000) / ((p.fractionalTokenReserves() - outputAmount) * 990) + 1;
        deal(address(usd), address(this), maxInputAmount, true);

        deal(address(ethPair), address(this), fractionalTokenAmount, true);
        ethPair.add{value: baseTokenAmount}(
            baseTokenAmount, fractionalTokenAmount, minLpTokenAmount, 0, type(uint256).max, 0
        );
    }

    function testItReturnsInputAmount() public {
        // arrange
        uint256 expectedInputAmount = maxInputAmount;

        // act
        uint256 inputAmount = p.buy(outputAmount, maxInputAmount, 0);

        // assert
        assertEq(inputAmount, expectedInputAmount, "Should have returned input amount");
    }

    function testItRevertsIfDeadlinePassed() public {
        // arrange
        skip(100);
        uint256 deadline = block.timestamp - 1;

        // act
        vm.expectRevert("Expired");
        p.buy(outputAmount, maxInputAmount, deadline);
    }

    function testItTransfersBaseTokens() public {
        // arrange
        uint256 balanceBefore = usd.balanceOf(address(p));
        uint256 thisBalanceBefore = usd.balanceOf(address(this));

        // act
        p.buy(outputAmount, maxInputAmount, 0);

        // assert
        assertEq(
            usd.balanceOf(address(p)) - balanceBefore, maxInputAmount, "Should have transferred base tokens to pair"
        );
        assertEq(
            thisBalanceBefore - usd.balanceOf(address(this)),
            maxInputAmount,
            "Should have transferred base tokens from sender"
        );
    }

    function testItTransfersFractionalTokens() public {
        // arrange
        uint256 balanceBefore = p.balanceOf(address(p));
        uint256 thisBalanceBefore = p.balanceOf(address(this));

        // act
        p.buy(outputAmount, maxInputAmount, 0);

        // assert
        assertEq(
            p.balanceOf(address(this)) - thisBalanceBefore,
            outputAmount,
            "Should have transferred fractional tokens from sender"
        );
        assertEq(
            balanceBefore - p.balanceOf(address(p)), outputAmount, "Should have transferred fractional tokens to pair"
        );
    }

    function testItRevertsSlippageOnBuy() public {
        // arrange
        maxInputAmount -= 1; // subtract 1 to cause revert

        // act
        vm.expectRevert("Slippage: amount in");
        p.buy(outputAmount, maxInputAmount, 0);
    }

    function testItRevertsIfValueIsGreaterThanZeroAndBaseTokenIsNot0() public {
        // act
        vm.expectRevert("Invalid ether input");
        p.buy{value: maxInputAmount}(outputAmount, maxInputAmount, 0);
    }

    function testItTransfersEther() public {
        // arrange
        uint256 balanceBefore = address(ethPair).balance;
        uint256 thisBalanceBefore = address(this).balance;

        // act
        ethPair.buy{value: maxInputAmount}(outputAmount, maxInputAmount, 0);

        // assert
        assertEq(address(ethPair).balance - balanceBefore, maxInputAmount, "Should have transferred ether to pair");
        assertEq(thisBalanceBefore - address(this).balance, maxInputAmount, "Should have transferred ether from sender");
    }

    function testItRefundsSurplusEther() public {
        // arrange
        uint256 surplus = 500;
        maxInputAmount += surplus;
        uint256 balanceBefore = address(ethPair).balance;
        uint256 thisBalanceBefore = address(this).balance;

        // act
        ethPair.buy{value: maxInputAmount}(outputAmount, maxInputAmount, 0);

        // assert
        assertEq(
            address(ethPair).balance - balanceBefore, maxInputAmount - surplus, "Should have transferred ether to pair"
        );
        assertEq(
            thisBalanceBefore - address(this).balance,
            maxInputAmount - surplus,
            "Should have transferred ether from sender"
        );
    }

    function testItRevertsIfMaxInputAmountIsNotEqualToValue() public {
        // act
        vm.expectRevert("Invalid ether input");
        ethPair.buy{value: maxInputAmount + 100}(outputAmount, maxInputAmount, 0);
    }

    function testItEmitsBuyEvent() public {
        // act
        vm.expectEmit(true, true, true, true);
        emit Buy(maxInputAmount, outputAmount);
        p.buy(outputAmount, maxInputAmount, 0);
    }

    function testItRoundsUpBuyQuote() public {
        // arrange
        uint256 baseTokenReserves = 10;
        uint256 fractionalTokenReserves = 10;
        outputAmount = 9;

        // (9 * 1000 * 10) / ((10 - 9) * 990) = 90.27
        uint256 expectedInputAmount = 91;

        // forgefmt: disable-next-item
        stdstore
            .target(address(usd))
            .sig("balanceOf(address)")
            .with_key(address(p))
            .checked_write(baseTokenReserves);

        // forgefmt: disable-next-item
        stdstore
            .target(address(p))
            .sig("balanceOf(address)")
            .with_key(address(p))
            .checked_write(fractionalTokenReserves);

        // act
        uint256 inputAmount = p.buyQuote(outputAmount);

        // assert
        assertEq(inputAmount, expectedInputAmount, "Should have rounded up");
    }
}
