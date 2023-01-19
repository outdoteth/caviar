// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../../shared/Fixture.t.sol";
import "../../../src/Caviar.sol";

contract BuySellTest is Fixture {
    function setUp() public {
        uint256 baseTokenAmount = 100e18;
        uint256 fractionalTokenAmount = 100e18;

        deal(address(usd), address(this), baseTokenAmount, true);
        deal(address(p), address(this), fractionalTokenAmount, true);

        usd.approve(address(p), type(uint256).max);

        uint256 minLpTokenAmount = Math.sqrt(baseTokenAmount * fractionalTokenAmount) - 100_000;
        p.add(baseTokenAmount, fractionalTokenAmount, minLpTokenAmount, 0, type(uint256).max, 0);

        deal(address(ethPair), address(this), fractionalTokenAmount, true);
        ethPair.add{value: baseTokenAmount}(
            baseTokenAmount, fractionalTokenAmount, minLpTokenAmount, 0, type(uint256).max, 0
        );
    }

    function testItBuysSellsEqualAmounts(uint256 outputAmount) public {
        outputAmount = bound(outputAmount, 1e2, p.fractionalTokenReserves() - 1e18);
        uint256 maxInputAmount =
            (outputAmount * p.baseTokenReserves() * 1000) / ((p.fractionalTokenReserves() - outputAmount) * 990) + 1;
        deal(address(usd), address(this), maxInputAmount, true);

        // act
        p.buy(outputAmount, maxInputAmount, 0);
        p.sell(outputAmount, 0, 0);

        // assert
        assertApproxEqAbs(
            usd.balanceOf(address(this)),
            maxInputAmount,
            maxInputAmount - (((maxInputAmount * 990) / 1000) * 990) / 1000 + 1, // allow margin of error for approx. fee amount
            "Should have bought and sold equal amounts of assets"
        );

        assertGt(
            maxInputAmount, usd.balanceOf(address(this)), "Should have less usd than starting with because of fees"
        );
    }
}
